-- ----------------------------------------------------------------------------	
-- FILE: tstcfg.vhd
-- DESCRIPTION: Serial interface with FPGA and testing info
-- DATE: Aug 22, 2016
-- AUTHOR(s): Lime Microsystems
-- REVISIONS: 
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_package.all;
use work.tstcfg_pkg.all;


-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity tstcfg is
   port (
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress             : in std_logic_vector(9 downto 0);
      mimo_en              : in std_logic;   -- MIMO enable, from TOP SPI (always 1)
   
      -- Serial port IOs
      sdin                 : in std_logic;   -- Data in
      sclk                 : in std_logic;   -- Data clock
      sen                  : in std_logic;   -- Enable signal (active low)
      sdout                : out std_logic;  -- Data out
   
      -- Signals coming from the pins or top level serial interface
      lreset               : in std_logic;   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset               : in std_logic;   -- Memory reset signal, resets configuration memory only (use only one reset)
      
      oen                  : out std_logic;  --nc
      stateo               : out std_logic_vector(5 downto 0);
      
      to_tstcfg            : in t_TO_TSTCFG;
      to_tstcfg_from_rxtx  : in t_TO_TSTCFG_FROM_RXTX;
      from_tstcfg          : out t_FROM_TSTCFG

   );
end tstcfg;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of tstcfg is

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
   
   signal GW_TEST_RES : std_logic_vector(3 downto 0);

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
               when "00000" => dout_reg <= (15 downto 8 => '0') & GW_TEST_RES & mem(0)(3 downto 0);
               when "00101" => dout_reg <= (15 downto 6 => '0') & to_tstcfg.TEST_CMPLT(5 downto 0);
               when "00111" => dout_reg <= (15 downto 6 => '0') & to_tstcfg.TEST_REZ(5 downto 0);
               when "01001" => dout_reg <= to_tstcfg.FX3_CLK_CNT;
               when "01010" => dout_reg <= to_tstcfg.Si5351C_CLK0_CNT;
               when "01011" => dout_reg <= to_tstcfg.Si5351C_CLK1_CNT;
               when "01100" => dout_reg <= to_tstcfg.Si5351C_CLK2_CNT;
               when "01101" => dout_reg <= to_tstcfg.Si5351C_CLK3_CNT;
               when "01111" => dout_reg <= to_tstcfg.Si5351C_CLK5_CNT;
               when "10000" => dout_reg <= to_tstcfg.Si5351C_CLK6_CNT;
               when "10001" => dout_reg <= to_tstcfg.Si5351C_CLK7_CNT;
               when "10010" => dout_reg <= to_tstcfg.LMK_CLK_CNT(15 downto 0);
               when "10011" => dout_reg <= (15 downto 8 => '0') & to_tstcfg.LMK_CLK_CNT(23 downto 16);
               when "10100" => dout_reg <= to_tstcfg.ADF_CNT;
               
               when "10110" => dout_reg <= (15 downto 3 => '0') & to_tstcfg_from_rxtx.DDR2_1_STATUS;  -- DDR2_1_STATUS
               when "10111" => dout_reg <= to_tstcfg_from_rxtx.DDR2_1_pnf_per_bit(15 downto 0);       -- DDR2_1_pnf_per_bit_l
               when "11000" => dout_reg <= to_tstcfg_from_rxtx.DDR2_1_pnf_per_bit(31 downto 16);      -- DDR2_1_pnf_per_bit_h
               
               when "11010" => dout_reg <= (15 downto 3 => '0') & to_tstcfg.DDR2_2_STATUS;  -- DDR2_2_STATUS
               when "11011" => dout_reg <= to_tstcfg.DDR2_2_pnf_per_bit(15 downto 0);       -- DDR2_2_pnf_per_bit_l
               when "11100" => dout_reg <= to_tstcfg.DDR2_2_pnf_per_bit(31 downto 16);      -- DDR2_2_pnf_per_bit_h
               when others => dout_reg <= mem(to_integer(unsigned(inst_reg(4 downto 0))));
            end case;
         end if;  
      end if;
   end process dout_reg_proc;
   
   -- Tri state buffer to connect multiple serial interfaces in parallel
   --sdout <= dout_reg(7) when oe = '1' else 'Z';

-- sdout <= dout_reg(7);
-- oen <= oe;

   sdout <= dout_reg(15) and oe;
   oen <= oe;
   -- ---------------------------------------------------------------------------------------------
   -- Configuration memory
   -- --------------------------------------------------------------------------------------------- 
   ram: process(sclk, mreset) --(remap)
   begin
      -- Defaults
      if mreset = '0' then	 
         mem(0)   <= "0000000000000000"; --R/W  0 free, reserved[15:8],SPI_SIGN_REZ[7:4],SPI_SIGN[3:0]
         mem(1)   <= "0000000000000000"; --R/W  0 free, reserved[15:6],DDR2_2_TST_EN,DDR2_1_TST_EN,ADF_TST_EN,VCTCXO_TST_EN,Si5351C_TST_EN,FX3_PCLK_TST_EN
         mem(2)   <= "0000000000000000"; --RD   0 free, reserved
         mem(3)   <= "0000000000000000"; --RD   0 free, reserved[15:6],DDR2_2_TST_FRC_ERR,DDR2_1_TST_FRC_ERR,ADF_TST_FRC_ERR,VCTCXO_TST_FRC_ERR,Si5351C_TST_FRC_ERR,FX3_PCLK_TST_FRC_ERR
         mem(4)   <= "0000000000000000"; --RD   0 free, reserved
         mem(5)   <= "0000000000000000"; --RD   0 free, reserved[15:6],DDR2_2_TST_CMPLT,DDR2_1_TST_CMPLT,ADF_TST_CMPLT,VCTCXO_TST_CMPLT,Si5351C_TST_CMPLT,FX3_PCLK_TST_CMPLT
         mem(6)   <= "0000000000000000"; --RD   0 free, reserved
         mem(7)   <= "0000000000000000"; --RD   0 free, reserved[15:6],DDR2_2_TST_REZ,DDR2_1_TST_REZ,ADF_TST_REZ,VCTCXO_TST_REZ,Si5351C_TST_REZ,FX3_PCLK_TST_REZ
         mem(8)   <= "0000000000000000"; --RD   0 free, reserved
         mem(9)   <= "0000000000000000"; --RD   0 free, FX3_CLK_CNT  
         mem(10)  <= "0000000000000000"; --RD   0 free, Si5351C_CLK7_CNT
         mem(11)  <= "0000000000000000"; --RD   0 free, Si5351C_CLK6_CNT
         mem(12)  <= "0000000000000000"; --RD   0 free, Si5351C_CLK5_CNT
         mem(13)  <= "0000000000000000"; --RD   0 free, reserved
         mem(14)  <= "0000000000000000"; --RD   0 free, Si5351C_CLK3_CNT
         mem(15)  <= "0000000000000000"; --RD   0 free, Si5351C_CLK2_CNT
         mem(16)  <= "0000000000000000"; --RD   0 free, Si5351C_CLK1_CNT
         mem(17)  <= "0000000000000000"; --RD   0 free, Si5351C_CLK0_CNT
         mem(18)  <= "0000000000000000"; --RD   0 free, LMK_CLK_CNT[15:0]  
         mem(19)  <= "0000000000000000"; --RD   0 free, LMK_CLK_CNT[23:16] 
         mem(20)  <= "0000000000000000"; --RD   0 free, ADF_CNT   
         mem(21)  <= "0000000000000000"; --RD   0 free, reserved
         mem(22)  <= "0000000000000000"; --RD   0 free, DDR2_1_STATUS
         mem(23)  <= "0000000000000000"; --RD   0 free, DDR2_1_pnf_per_bit(15 downto 0);
         mem(24)  <= "0000000000000000"; --RD   0 free, DDR2_1_pnf_per_bit(31 downto 16);
         mem(25)  <= "0000000000000000"; --RD/W 0 free, Reserved
         mem(26)  <= "0000000000000000"; --RD   0 free, DDR2_2_STATUS
         mem(27)  <= "0000000000000000"; --RD   0 free, DDR2_2_pnf_per_bit(15 downto 0);
         mem(28)  <= "0000000000000000"; --RD   0 free, DDR2_2_pnf_per_bit(31 downto 16);
         mem(29)  <= "1010101010101010"; --RD/W 0 free, TX_TST_I
         mem(30)  <= "0101010101010101"; --RD/W 0 free, TX_TST_Q
         mem(31)  <= "0000000000000000"; --RD/W 0 free, Reserved
   
      elsif sclk'event and sclk = '1' then
         if mem_we = '1' then
            mem(to_integer(unsigned(inst_reg(4 downto 0)))) <= din_reg(14 downto 0) & sdin;
         end if;
         
         if dout_reg_len = '0' then
         
         end if;
            
      end if;
   end process ram;
   
   process(mem(0)(3 downto 0))
   begin 
      for_loop : for i in 0 to 3 loop  
         GW_TEST_RES(i) <= not mem(0)(i);
      end loop;
   end process;
   
   -- ---------------------------------------------------------------------------------------------
   -- Decoding logic
   -- ---------------------------------------------------------------------------------------------
   
   from_tstcfg.TEST_EN       <= mem(1)(5 downto 0);
   from_tstcfg.TEST_FRC_ERR  <= mem(3)(5 downto 0);
   from_tstcfg.TX_TST_I      <= mem(29)(15 downto 0);
   from_tstcfg.TX_TST_Q      <= mem(30)(15 downto 0);



end arch;
