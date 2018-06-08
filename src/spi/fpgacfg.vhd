-- ----------------------------------------------------------------------------	
-- FILE:	fpgacfg.vhd
-- DESCRIPTION:	Serial configuration interface to control TX modules
-- DATE:	June 07, 2007
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:	
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_package.all;
use work.revisions.all;
use work.fpgacfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity fpgacfg is
   port (
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress    : in  std_logic_vector(9 downto 0);
      mimo_en     : in  std_logic;   -- MIMO enable, from TOP SPI (always 1)
   
      -- Serial port IOs
      sdin        : in  std_logic;  -- Data in
      sclk        : in  std_logic;  -- Data clock
      sen         : in  std_logic;  -- Enable signal (active low)
      sdout       : out std_logic;  -- Data out
   
      -- Signals coming from the pins or top level serial interface
      lreset      : in  std_logic;  -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset      : in  std_logic;  -- Memory reset signal, resets configuration memory only (use only one reset)
      
      oen         : out std_logic;  --nc
      stateo      : out std_logic_vector(5 downto 0);
      
      to_fpgacfg  : in  t_TO_FPGACFG;
      from_fpgacfg: out t_FROM_FPGACFG
      
      
   );
end fpgacfg;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture fpgacfg_arch of fpgacfg is

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
   
   signal BOARD_ID_reg        : std_logic_vector(15 downto 0);
   signal MAJOR_REV_reg       : std_logic_vector(15 downto 0);
   signal COMPILE_REV_reg     : std_logic_vector(7 downto 0);

   attribute noprune          : boolean;
   attribute noprune of BOARD_ID_reg      : signal is true;
   attribute noprune of MAJOR_REV_reg     : signal is true;
   attribute noprune of COMPILE_REV_reg   : signal is true;
   
   -- Components
   use work.mcfg_components.mcfg32wm_fsm;
   for all: mcfg32wm_fsm use entity work.mcfg32wm_fsm(mcfg32wm_fsm_arch);

begin

   ---------------------------------------------------------------------------------------------
   -- To avoid optimizations
   -- ---------------------------------------------------------------------------------------------
   process(sclk, lreset)
   begin
      if lreset = '0' then
         BOARD_ID_reg      <= BOARD_ID;
         MAJOR_REV_reg     <= std_logic_vector(to_unsigned(MAJOR_REV, 16));
         COMPILE_REV_reg   <= std_logic_vector(to_unsigned(COMPILE_REV, 8));
      elsif sclk'event and sclk = '1' then
         BOARD_ID_reg      <= BOARD_ID;
         MAJOR_REV_reg     <= std_logic_vector(to_unsigned(MAJOR_REV, 16));
         COMPILE_REV_reg   <= std_logic_vector(to_unsigned(COMPILE_REV, 8));
      end if;
   end process;


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
            case inst_reg(4 downto 0) is  -- mux read-only outputs
               when "00000" => dout_reg <= BOARD_ID_reg;
               when "00001" => dout_reg <= MAJOR_REV_reg;
               when "00010" => dout_reg <= (15 downto 8 => '0') & COMPILE_REV_reg;
               when "00011" => dout_reg <= (15 downto 9 => '0') & to_fpgacfg.PWR_SRC & to_fpgacfg.BOM_VER & to_fpgacfg.HW_VER;
               when others  => dout_reg <= mem(to_integer(unsigned(inst_reg(4 downto 0))));
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
         --Read only registers
         mem(0)   <= "0000000000000000";  -- 00 free, Board ID
         mem(1)   <= "0000000000000000";  -- 00 free, GW version
         mem(2)   <= "0000000000000000";  -- 00 free, GW revision
         mem(3)   <= "0000000000000000";  --  9 free, BOM_VER[6:4],HW_VER[3:0]
         --FPGA direct clocking
         mem(4)   <= "0000000000000000";  --  0 free, phase_reg_sel
         mem(5)   <= "0000000000000000";  --  0 free, drct_clk_en, 
         mem(6)   <= "0000000000000000";  --  5 free, load_phase_reg, cnt_ind[4:0], clk_ind[4:0]
         --Interface Config
         mem(7)   <= "0000000000000011";  --  0 free, ch_en[15:0]
         mem(8)   <= "0000000100000010";  --  6 free, sync_mode,synch_dis, mimo_int_en, trxiq_pulse, ddr_en, mode, reserved[2:0], smpl_width[1:0]
         mem(9)   <= "0000000000000011";  -- 14 free, txpct_loss_clr, smpl_nr_clr,
         mem(10)  <= "0000000000000000";  -- 14 free, tx_en, rx_en,
         mem(11)  <= "0000000000000000";  -- 16 free, 
         mem(12)  <= "0000000000000011";  --  0 free, wfm_ch_en
         mem(13)  <= "0000000000000000";  --  0 free, Reserved,wfm_load,wfm_play,Reserved
         mem(14)  <= "0000000000000010";  -- 14 free, Reserved,wfm_smpl_width
         mem(15)  <= x"03FC";             -- 16 free, sync_size
         --Peripheral config
         mem(16)  <= x"0001";             -- 16 free, txant_pre
         mem(17)  <= x"0001";             -- 16 free, txant_post
         mem(18)  <= "1111111111111111";  --  0 free, SPI_SS[15:0]
         mem(19)  <= "0110111101101011";  --  0 free, rsrvd,LMS2_RXEN,LMS2_TXEN,LMS2_TXNRX2,LMS2_TXNRX1,LMS2_CORE_LDO_EN,LMS2_RESET,LMS2_SS,rsrvd,LMS1_RXEN,LMS1_TXEN,LMS1_TXNRX2,LMS1_TXNRX1,LMS1_CORE_LDO_EN,LMS1_RESET,LMS1_SS
         mem(20)  <= "0000000000000011";  --  0 free, (Reserved LMS control)
         mem(21)  <= "0000000000000000";  --  0 free, (Reserved LMS control)
         mem(22)  <= "0000000000000000";  --  0 free, (Reserved LMS control)
         mem(23)  <= "0001000101000100";  --  0 free, (Reserved), GPIO[6:0]
         mem(24)  <= "0000000000000000";  -- 16 free, (Reserved) 
         mem(25)  <= "0000000000000000";  -- 16 free, (Reserved)
         mem(26)  <= "0000000000000000";  --  0 free, Reserved[15:8],FPGA_LED2_G,FPGA_LED2_R,FPGA_LED2_OVRD,Reserved,FPGA_LED1_G,FPGA_LED1_R,FPGA_LED1_OVRD
         mem(27)  <= "0000000000000000";  --  0 free, Reserved[15:0]
         mem(28)  <= "0000000000000000";  --  0 free, Reserved[15:4],FX3_LED_G,FX3_LED_R,FX3_LED_OVRD
         mem(29)  <= "0000000000001111";  --  0 free, CLK_ENA[1:0]
         mem(30)  <= x"0003";             --  0 free, sync_pulse_period MSb 
         mem(31)  <= x"D090";             --  0 free, sync_pulse_period LSb
         
      elsif sclk'event and sclk = '1' then
            if mem_we = '1' then
               mem(to_integer(unsigned(inst_reg(4 downto 0)))) <= din_reg(14 downto 0) & sdin;
            end if;
            
            if dout_reg_len = '0' then
--               for_loop : for i in 0 to 3 loop
--                  mem(3)(i+4) <= not mem(3)(i);
--               end loop;
            end if;
            
      end if;
   end process ram;
   
   -- ---------------------------------------------------------------------------------------------
   -- Decoding logic
   -- ---------------------------------------------------------------------------------------------
         --FPGA direct clocking
      from_fpgacfg.phase_reg_sel       <= mem(4);
      from_fpgacfg.drct_clk_en         <= mem(5);
      from_fpgacfg.clk_ind             <= mem(6) (4 downto 0);
      from_fpgacfg.cnt_ind             <= mem(6) (9 downto 5);
      from_fpgacfg.load_phase_reg      <= mem(6) (10);
      --Interface Config
      from_fpgacfg.ch_en               <= mem(7);
      from_fpgacfg.smpl_width          <= mem(8) (1 downto 0);
      from_fpgacfg.mode                <= mem(8) (5);
      from_fpgacfg.ddr_en              <= mem(8) (6);
      from_fpgacfg.trxiq_pulse         <= mem(8) (7);
      from_fpgacfg.mimo_int_en         <= mem(8) (8);
      from_fpgacfg.synch_dis           <= mem(8) (9);
      from_fpgacfg.synch_mode          <= mem(8) (10);
      from_fpgacfg.smpl_nr_clr         <= mem(9) (0);
      from_fpgacfg.txpct_loss_clr      <= mem(9) (1);
      from_fpgacfg.rx_en               <= mem(10) (0);
      from_fpgacfg.tx_en               <= mem(10) (1);
      from_fpgacfg.rx_ptrn_en          <= mem(10) (8);
      from_fpgacfg.tx_ptrn_en          <= mem(10) (9);
      from_fpgacfg.tx_cnt_en           <= mem(10) (10);
      
      from_fpgacfg.wfm_ch_en           <= mem(12) (15 downto 0);
      from_fpgacfg.wfm_play            <= mem(13) (1);
      from_fpgacfg.wfm_load            <= mem(13) (2);
      from_fpgacfg.wfm_smpl_width      <= mem(13) (1 downto 0);
      
      from_fpgacfg.sync_size           <= mem(15) (15 downto 0);
      from_fpgacfg.txant_pre           <= mem(16) (15 downto 0);
      from_fpgacfg.txant_post          <= mem(17) (15 downto 0);

      for_loop : for i in 0 to 15 generate --to prevent SPI_SS to go low on same time as sen
         from_fpgacfg.SPI_SS(i)<= mem(18)(i) OR (NOT sen);
      end generate;
      
      from_fpgacfg.LMS1_SS             <= mem(19)(0) OR (NOT sen); --to prevent SPI_SS to go low on same time as sen
      from_fpgacfg.LMS1_RESET          <= mem(19)(1);
      from_fpgacfg.LMS1_CORE_LDO_EN    <= mem(19)(2);
      from_fpgacfg.LMS1_TXNRX1         <= mem(19)(3); 
      from_fpgacfg.LMS1_TXNRX2         <= mem(19)(4);
      from_fpgacfg.LMS1_TXEN           <= mem(19)(5); 
      from_fpgacfg.LMS1_RXEN           <= mem(19)(6);

--    from_fpgacfg.LMS2_SS             <= mem(19)(8) OR (NOT sen); --to prevent SPI_SS to go low on same time as sen
--    from_fpgacfg.LMS2_RESET          <= mem(19)(9);
--    from_fpgacfg.LMS2_CORE_LDO_EN    <= mem(19)(10); 
--    from_fpgacfg.LMS2_TXNRX1         <= mem(19)(11);
--    from_fpgacfg.LMS2_TXNRX2         <= mem(19)(12);
--    from_fpgacfg.LMS2_TXEN           <= mem(19)(13);
--    from_fpgacfg.LMS2_RXEN           <= mem(19)(14);
      from_fpgacfg.GPIO                <= mem(23)(15 downto 0);
      from_fpgacfg.FPGA_LED1_CTRL      <= mem(26)(2 downto 0);
      from_fpgacfg.FPGA_LED2_CTRL      <= mem(26)(6 downto 4);
      from_fpgacfg.FX3_LED_CTRL        <= mem(28)(2 downto 0);
      from_fpgacfg.CLK_ENA             <= mem(29)(3 downto 0);
      from_fpgacfg.sync_pulse_period   <= mem(30)(15 downto 0) & mem(31)(15 downto 0);


end fpgacfg_arch;
