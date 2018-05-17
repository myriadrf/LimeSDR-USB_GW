-- ----------------------------------------------------------------------------
-- FILE:          periphcfg.vhd
-- DESCRIPTION:   Serial configuration interface to control periphery
-- DATE:          4:41 PM Monday, May 7, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_package.all;
use work.periphcfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity periphcfg is
   port (
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress             : in  std_logic_vector(9 downto 0);
      mimo_en              : in  std_logic;     -- MIMO enable, from TOP SPI (always 1)
   
      -- Serial port IOs
      sdin                 : in  std_logic;     -- Data in
      sclk                 : in  std_logic;     -- Data clock
      sen                  : in  std_logic;     -- Enable signal (active low)
      sdout                : out std_logic;     -- Data out
   
      -- Signals coming from the pins or top level serial interface
      lreset               : in  std_logic;     -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset               : in  std_logic;     -- Memory reset signal, resets configuration memory only (use only one reset)
      
      oen                  : out std_logic;     --nc
      stateo               : out std_logic_vector(5 downto 0);
      
      to_periphcfg         : in t_TO_PERIPHCFG;
      from_periphcfg       : out t_FROM_PERIPHCFG
   );
end periphcfg;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture periphcfg_arch of periphcfg is

   signal inst_reg: std_logic_vector(15 downto 0);    -- Instruction register
   signal inst_reg_en: std_logic;
   
   signal din_reg: std_logic_vector(15 downto 0);     -- Data in register
   signal din_reg_en: std_logic;
   
   signal dout_reg: std_logic_vector(15 downto 0);    -- Data out register
   signal dout_reg_sen, dout_reg_len: std_logic;
   
   signal mem: marray32x16;                           -- Config memory
   signal mem_we: std_logic;
   
   signal oe: std_logic;                              -- Tri state buffers control
   signal spi_config_data_rev	: std_logic_vector(143 downto 0);
   
   -- Components
   use work.mcfg_components.mcfg32wm_fsm;
   for all: mcfg32wm_fsm use entity work.mcfg32wm_fsm(mcfg32wm_fsm_arch);

begin


-- ---------------------------------------------------------------------------------------------
-- Finite state machines
-- ---------------------------------------------------------------------------------------------
   fsm: mcfg32wm_fsm port map( 
      address => maddress, mimo_en => mimo_en, inst_reg => inst_reg, sclk => sclk, sen => sen, reset => lreset,
      inst_reg_en => inst_reg_en, din_reg_en => din_reg_en, dout_reg_sen => dout_reg_sen,
      dout_reg_len => dout_reg_len, mem_we => mem_we, oe => oe, stateo => stateo);
      
-- ---------------------------------------------------------------------------------------------
-- Instruction register
-- ---------------------------------------------------------------------------------------------
   inst_reg_proc: process(sclk, lreset)
      variable i: integer;
   begin
      if lreset = '0' then
         inst_reg <= (others => '0');
      elsif sclk'event and sclk = '1' then
         if inst_reg_en = '1' then
            for i in 15 downto 1 loop
               inst_reg(i) <= inst_reg(i-1);
            end loop;
            inst_reg(0) <= sdin;
         end if;
      end if;
   end process inst_reg_proc;

-- ---------------------------------------------------------------------------------------------
-- Data input register
-- ---------------------------------------------------------------------------------------------
   din_reg_proc: process(sclk, lreset)
      variable i: integer;
   begin
      if lreset = '0' then
         din_reg <= (others => '0');
      elsif sclk'event and sclk = '1' then
         if din_reg_en = '1' then
            for i in 15 downto 1 loop
               din_reg(i) <= din_reg(i-1);
            end loop;
            din_reg(0) <= sdin;
         end if;
      end if;
   end process din_reg_proc;

-- ---------------------------------------------------------------------------------------------
-- Data output register
-- ---------------------------------------------------------------------------------------------
   dout_reg_proc: process(sclk, lreset)
      variable i: integer;
   begin
      if lreset = '0' then
         dout_reg <= (others => '0');
      elsif sclk'event and sclk = '0' then
         -- Shift operation
         if dout_reg_sen = '1' then
            for i in 15 downto 1 loop
               dout_reg(i) <= dout_reg(i-1);
            end loop;
            dout_reg(0) <= dout_reg(15);
         -- Load operation
         elsif dout_reg_len = '1' then
            case inst_reg(4 downto 0) is	-- mux read-only outputs
               when "00010" => dout_reg <= to_periphcfg.BOARD_GPIO_RD;
               when "01000" => dout_reg <= to_periphcfg.PERIPH_INPUT_RD_0;
               when "01001" => dout_reg <= to_periphcfg.PERIPH_INPUT_RD_1;
               when others  => dout_reg <= mem(to_integer(unsigned(inst_reg(4 downto 0))));
            end case;
         end if;      
      end if;
   end process dout_reg_proc;
   
   -- Tri state buffer to connect multiple serial interfaces in parallel
   --sdout <= dout_reg(7) when oe = '1' else 'Z';

   -- sdout <= dout_reg(7);
   --oen <= oe;

   sdout <= dout_reg(15) and oe;
   oen <= oe;
-- ---------------------------------------------------------------------------------------------
-- Configuration memory
-- --------------------------------------------------------------------------------------------- 
   ram: process(sclk, mreset)
   begin
      -- Defaults
      if mreset = '0' then	
         mem(0)	<= "1111111111111111"; --  0 free, BOARD_GPIO_OVRD[15:0]
         mem(1)	<= "0000000000000000"; --  0 free, Reserved
         mem(2)	<= "0000000000000000"; --  0 free, BOARD_GPIO_RD[15:0]
         mem(3)	<= "0000000000000000"; --  0 free, Reserved
         mem(4) 	<= "0000000000000000"; --  0 free, BOARD_GPIO_DIR[15:0]
         mem(5)	<= "0000000000000000"; --  0 free, Reserved
         mem(6) 	<= "0000000000000000"; --  0 free, BOARD_GPIO_VAL[15:0]
         mem(7)	<= "0000000000000000"; --  0 free, Reserved
         mem(8)	<= "0000000000000000"; --  0 free, PERIPH_INPUT_RD_0
         mem(9)	<= "0000000000000000"; --  0 free, PERIPH_INPUT_RD_1
         mem(10)	<= "0000000000000000"; --  0 free, Reserved
         mem(11)	<= "0000000000000000"; --  0 free, Reserved			
         mem(12)	<= "0000000000000000"; --  0 free, PERIPH_OUTPUT_OVRD_0
         mem(13)	<= "0000000000000000"; --  0 free, PERIPH_OUTPUT_VAL_0
         mem(14)	<= "0000000000000000"; --  0 free, PERIPH_OUTPUT_OVRD_1
         mem(15)	<= "0000000000000000"; --  0 free, PERIPH_OUTPUT_VAL_1
         mem(16)	<= "0000000000000000"; --  0 free, Reserved
         mem(17)	<= "0000000000000000"; --  0 free, Reserved
         mem(18)	<= "0000000000000000"; --  0 free, Reserved
         mem(19)	<= "0000000000000000"; --  0 free, Reserved
         mem(20)	<= "0000000000000000"; --  0 free, Reserved
         mem(21)	<= "0000000000000000"; --  0 free, Reserved
         mem(22)	<= "0000000000000000"; --  0 free, Reserved
         mem(23)	<= "0000000000000000"; --  0 free, Reserved
         mem(24)	<= "0000000000000000"; --  0 free, Reserved
         mem(25)	<= "0000000000000000"; --  0 free, Reserved
         mem(26)	<= "0000000000000000"; --  0 free, Reserved
         mem(27)	<= "0000000000000000"; --  0 free, Reserved
         mem(28)	<= "0000000000000000"; --  0 free, Reserved
         mem(29)	<= "0000000000000000"; --  0 free, Reserved
         mem(30)	<= "0000000000000000"; --  0 free, Reserved
         mem(31)	<= "0000000000000000"; --  0 free, Reserved

      elsif sclk'event and sclk = '1' then
            if mem_we = '1' then
               mem(to_integer(unsigned(inst_reg(4 downto 0)))) <= din_reg(14 downto 0) & sdin;
            end if;
            
            if dout_reg_len = '0' then
               for_loop : for i in 0 to 3 loop
                  mem(3)(i+4) <= not mem(3)(i);
               end loop;
            end if;
            
      end if;
   end process ram;
   
-- ---------------------------------------------------------------------------------------------
-- Decoding logic
-- ---------------------------------------------------------------------------------------------
      from_periphcfg.BOARD_GPIO_OVRD      <= mem(0) (15 downto 0);
      from_periphcfg.BOARD_GPIO_DIR       <= mem(4) (15 downto 0);
      from_periphcfg.BOARD_GPIO_VAL       <= mem(6) (15 downto 0);
      
      from_periphcfg.PERIPH_OUTPUT_OVRD_0 <= mem(12) (15 downto 0);
      from_periphcfg.PERIPH_OUTPUT_VAL_0  <= mem(13) (15 downto 0);
      from_periphcfg.PERIPH_OUTPUT_OVRD_1 <= mem(14) (15 downto 0);
      from_periphcfg.PERIPH_OUTPUT_VAL_1  <= mem(15) (15 downto 0);

end periphcfg_arch;
