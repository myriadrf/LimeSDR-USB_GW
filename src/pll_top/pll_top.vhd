-- ----------------------------------------------------------------------------
-- FILE:          pll_top.vhd
-- DESCRIPTION:   Top wrapper file for PLLs
-- DATE:          10:50 AM Wednesday, May 9, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pllcfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pll_top is
   generic(
      N_PLL                         : integer   := 2;
      -- TX pll parameters
      TXPLL_BANDWIDTH_TYPE          : STRING    := "AUTO";
      TXPLL_CLK0_DIVIDE_BY          : NATURAL   := 1;
      TXPLL_CLK0_DUTY_CYCLE         : NATURAL   := 50;
      TXPLL_CLK0_MULTIPLY_BY        : NATURAL   := 1;
      TXPLL_CLK0_PHASE_SHIFT        : STRING    := "0";
      TXPLL_CLK1_DIVIDE_BY          : NATURAL   := 1;
      TXPLL_CLK1_DUTY_CYCLE         : NATURAL   := 50;
      TXPLL_CLK1_MULTIPLY_BY        : NATURAL   := 1;
      TXPLL_CLK1_PHASE_SHIFT        : STRING    := "0";
      TXPLL_COMPENSATE_CLOCK        : STRING    := "CLK1";
      TXPLL_INCLK0_INPUT_FREQUENCY  : NATURAL   := 6250;
      TXPLL_INTENDED_DEVICE_FAMILY  : STRING    := "Cyclone IV E";
      TXPLL_OPERATION_MODE          : STRING    := "SOURCE_SYNCHRONOUS";
      TXPLL_SCAN_CHAIN_MIF_FILE     : STRING    := "ip/txpll/pll.mif";
      TXPLL_DRCT_C0_NDLY            : integer   := 1;
      TXPLL_DRCT_C1_NDLY            : integer   := 2;
      -- RX pll parameters
      RXPLL_BANDWIDTH_TYPE          : STRING    := "AUTO";
      RXPLL_CLK0_DIVIDE_BY          : NATURAL   := 1;
      RXPLL_CLK0_DUTY_CYCLE         : NATURAL   := 50;
      RXPLL_CLK0_MULTIPLY_BY        : NATURAL   := 1;
      RXPLL_CLK0_PHASE_SHIFT        : STRING    := "0";
      RXPLL_CLK1_DIVIDE_BY          : NATURAL   := 1;
      RXPLL_CLK1_DUTY_CYCLE         : NATURAL   := 50;
      RXPLL_CLK1_MULTIPLY_BY        : NATURAL   := 1;
      RXPLL_CLK1_PHASE_SHIFT        : STRING    := "0";
      RXPLL_COMPENSATE_CLOCK        : STRING    := "CLK1";
      RXPLL_INCLK0_INPUT_FREQUENCY  : NATURAL   := 6250;
      RXPLL_INTENDED_DEVICE_FAMILY  : STRING    := "Cyclone IV E";
      RXPLL_OPERATION_MODE          : STRING    := "SOURCE_SYNCHRONOUS";
      RXPLL_SCAN_CHAIN_MIF_FILE     : STRING    := "ip/pll/pll.mif";
      RXPLL_DRCT_C0_NDLY            : integer   := 1;
      RXPLL_DRCT_C1_NDLY            : integer   := 2

   );
   port (
      -- TX PLL ports
      txpll_inclk          : in  std_logic;
      txpll_reconfig_clk   : in  std_logic;
      txpll_logic_reset_n  : in  std_logic;
      txpll_clk_ena        : in  std_logic_vector(1 downto 0);
      txpll_drct_clk_en    : in  std_logic_vector(1 downto 0);
      txpll_c0             : out std_logic;
      txpll_c1             : out std_logic;
      txpll_locked         : out std_logic;
      --
      txpll_smpl_cmp_en    : out std_logic;
      txpll_smpl_cmp_done  : in  std_logic;
      txpll_smpl_cmp_error : in  std_logic;
      txpll_smpl_cmp_cnt   : out std_logic_vector(15 downto 0);
      -- RX pll ports
      rxpll_inclk          : in  std_logic;
      rxpll_reconfig_clk   : in  std_logic;
      rxpll_logic_reset_n  : in  std_logic;
      rxpll_clk_ena        : in  std_logic_vector(1 downto 0);
      rxpll_drct_clk_en    : in  std_logic_vector(1 downto 0); 
      rxpll_c0             : out std_logic;
      rxpll_c1             : out std_logic;
      rxpll_locked         : out std_logic;
      --
      rxpll_smpl_cmp_en    : out std_logic;      
      rxpll_smpl_cmp_done  : in  std_logic;
      rxpll_smpl_cmp_error : in  std_logic;
      rxpll_smpl_cmp_cnt   : out std_logic_vector(15 downto 0);
      -- pllcfg ports
      to_pllcfg            : out t_TO_PLLCFG;
      from_pllcfg          : in t_FROM_PLLCFG
      );
end pll_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pll_top is
--declare signals,  components here
--inst0
signal inst0_pll_locked    : std_logic;
signal inst0_smpl_cmp_en   : std_logic;
signal inst0_busy          : std_logic;
signal inst0_dynps_done    : std_logic;
signal inst0_dynps_status  : std_logic;
signal inst0_rcnfig_status : std_logic;

--inst1
signal inst1_pll_locked    : std_logic;
signal inst1_smpl_cmp_en   : std_logic;
signal inst1_busy          : std_logic;
signal inst1_dynps_done    : std_logic;
signal inst1_dynps_status  : std_logic;
signal inst1_rcnfig_status : std_logic;

--inst2
signal inst2_pllcfg_busy      : std_logic_vector(N_PLL-1 downto 0);
signal inst2_pllcfg_done      : std_logic_vector(N_PLL-1 downto 0);
signal inst2_pll_lock         : std_logic_vector(N_PLL-1 downto 0);
signal inst2_phcfg_start      : std_logic_vector(N_PLL-1 downto 0);
signal inst2_pllcfg_start     : std_logic_vector(N_PLL-1 downto 0);
signal inst2_pllrst_start     : std_logic_vector(N_PLL-1 downto 0);
signal inst2_auto_phcfg_done  : std_logic_vector(N_PLL-1 downto 0);
signal inst2_auto_phcfg_err   : std_logic_vector(N_PLL-1 downto 0);
signal inst2_phcfg_mode       : std_logic;
signal inst2_phcfg_tst        : std_logic;
signal inst2_phcfg_updn       : std_logic;
signal inst2_cnt_ind          : std_logic_vector(4 downto 0);
signal inst2_cnt_phase        : std_logic_vector(15 downto 0);
signal inst2_pllcfg_data      : std_logic_vector(143 downto 0);
signal inst2_auto_phcfg_smpls : std_logic_vector(15 downto 0);
signal inst2_auto_phcfg_step  : std_logic_vector(15 downto 0);

signal pllcfg_busy            : std_logic;
signal pllcfg_done            : std_logic;

  
begin

-- ----------------------------------------------------------------------------
-- TX PLL instance
-- ----------------------------------------------------------------------------
tx_pll_top_inst0 : entity work.tx_pll_top
   generic map(
      bandwidth_type          => TXPLL_BANDWIDTH_TYPE,
      clk0_divide_by          => TXPLL_CLK0_DIVIDE_BY,
      clk0_duty_cycle         => TXPLL_CLK0_DUTY_CYCLE,
      clk0_multiply_by        => TXPLL_CLK0_MULTIPLY_BY,
      clk0_phase_shift        => TXPLL_CLK0_PHASE_SHIFT,
      clk1_divide_by          => TXPLL_CLK1_DIVIDE_BY,
      clk1_duty_cycle         => TXPLL_CLK1_DUTY_CYCLE,
      clk1_multiply_by        => TXPLL_CLK1_MULTIPLY_BY,
      clk1_phase_shift        => TXPLL_CLK1_PHASE_SHIFT,
      compensate_clock        => TXPLL_COMPENSATE_CLOCK,
      inclk0_input_frequency  => TXPLL_INCLK0_INPUT_FREQUENCY,
      intended_device_family  => TXPLL_INTENDED_DEVICE_FAMILY,
      operation_mode          => TXPLL_OPERATION_MODE,
      scan_chain_mif_file     => TXPLL_SCAN_CHAIN_MIF_FILE,
      drct_c0_ndly            => TXPLL_DRCT_C0_NDLY,
      drct_c1_ndly            => TXPLL_DRCT_C1_NDLY
   )
   port map(
   --PLL input 
   pll_inclk         => txpll_inclk,
   pll_areset        => inst2_pllrst_start(0),
   pll_logic_reset_n => txpll_logic_reset_n,
   inv_c0            => '0',
   c0                => txpll_c0, --muxed clock output
   c1                => txpll_c1, --muxed clock output
   pll_locked        => inst0_pll_locked,
   --Bypass control
   clk_ena           => txpll_clk_ena,       --clock output enable
   drct_clk_en       => txpll_drct_clk_en,   --1 - Direct clk, 0 - PLL clocks 
   --Reconfiguration ports
   rcnfg_clk         => txpll_reconfig_clk,
   rcnfig_areset     => inst2_pllrst_start(0),
   rcnfig_en         => inst2_pllcfg_start(0),
   rcnfig_data       => inst2_pllcfg_data,
   rcnfig_status     => inst0_rcnfig_status,
   --Dynamic phase shift ports
   dynps_areset_n    => not inst2_pllrst_start(0),
   dynps_mode        => inst2_phcfg_mode, -- 0 - manual, 1 - auto
   dynps_en          => inst2_phcfg_start(0),
   dynps_tst         => inst2_phcfg_tst,
   dynps_dir         => inst2_phcfg_updn,
   dynps_cnt_sel     => inst2_cnt_ind(2 downto 0),
   -- max phase steps in auto mode, phase steps to shift in manual mode
   dynps_phase       => inst2_cnt_phase(9 downto 0),
   dynps_step_size   => inst2_auto_phcfg_step(9 downto 0),
   dynps_busy        => open,
   dynps_done        => inst0_dynps_done,
   dynps_status      => inst0_dynps_status,
   --signals from sample compare module (required for automatic phase searching)
   smpl_cmp_en       => inst0_smpl_cmp_en,
   smpl_cmp_done     => txpll_smpl_cmp_done,
   smpl_cmp_error    => txpll_smpl_cmp_error,
   --Overall configuration PLL status
   busy              => inst0_busy   
   );
   
-- ----------------------------------------------------------------------------
-- RX PLL instance
-- ----------------------------------------------------------------------------
rx_pll_top_inst0 : entity work.rx_pll_top
   generic map(
      bandwidth_type          => RXPLL_BANDWIDTH_TYPE,
      clk0_divide_by          => RXPLL_CLK0_DIVIDE_BY,
      clk0_duty_cycle         => RXPLL_CLK0_DUTY_CYCLE,
      clk0_multiply_by        => RXPLL_CLK0_MULTIPLY_BY,
      clk0_phase_shift        => RXPLL_CLK0_PHASE_SHIFT,
      clk1_divide_by          => RXPLL_CLK1_DIVIDE_BY,
      clk1_duty_cycle         => RXPLL_CLK1_DUTY_CYCLE,
      clk1_multiply_by        => RXPLL_CLK1_MULTIPLY_BY,
      clk1_phase_shift        => RXPLL_CLK1_PHASE_SHIFT,
      compensate_clock        => RXPLL_COMPENSATE_CLOCK,
      inclk0_input_frequency  => RXPLL_INCLK0_INPUT_FREQUENCY,
      intended_device_family  => RXPLL_INTENDED_DEVICE_FAMILY,
      operation_mode          => RXPLL_OPERATION_MODE,
      scan_chain_mif_file     => RXPLL_SCAN_CHAIN_MIF_FILE,
      drct_c0_ndly            => RXPLL_DRCT_C0_NDLY,
      drct_c1_ndly            => RXPLL_DRCT_C1_NDLY
   )
   port map(
   --PLL input 
   pll_inclk         => rxpll_inclk,
   pll_areset        => inst2_pllrst_start(1),
   pll_logic_reset_n => rxpll_logic_reset_n,
   inv_c0            => '0',
   c0                => rxpll_c0, --muxed clock output
   c1                => rxpll_c1, --muxed clock output
   pll_locked        => inst1_pll_locked,
   --Bypass control
   clk_ena           => rxpll_clk_ena,       --clock output enable
   drct_clk_en       => rxpll_drct_clk_en,   --1 - Direct clk, 0 - PLL clocks 
   --Reconfiguration ports
   rcnfg_clk         => rxpll_reconfig_clk,
   rcnfig_areset     => inst2_pllrst_start(1),
   rcnfig_en         => inst2_pllcfg_start(1),
   rcnfig_data       => inst2_pllcfg_data,
   rcnfig_status     => inst1_rcnfig_status,
   --Dynamic phase shift ports
   dynps_areset_n    => not inst2_pllrst_start(1),
   dynps_mode        => inst2_phcfg_mode, -- 0 - manual, 1 - auto
   dynps_en          => inst2_phcfg_start(1),
   dynps_tst         => inst2_phcfg_tst,
   dynps_dir         => inst2_phcfg_updn,
   dynps_cnt_sel     => inst2_cnt_ind(2 downto 0),
   -- max phase steps in auto mode, phase steps to shift in manual mode
   dynps_phase       => inst2_cnt_phase(9 downto 0),
   dynps_step_size   => inst2_auto_phcfg_step(9 downto 0),
   dynps_busy        => open,
   dynps_done        => inst1_dynps_done,
   dynps_status      => inst1_dynps_status,
   --signals from sample compare module (required for automatic phase searching)
   smpl_cmp_en       => inst1_smpl_cmp_en,
   smpl_cmp_done     => rxpll_smpl_cmp_done,
   smpl_cmp_error    => rxpll_smpl_cmp_error,
   --Overall configuration PLL status
   busy              => inst1_busy   
   );

  
   pllcfg_busy <= inst1_busy OR inst0_busy;
   pllcfg_done <= not pllcfg_busy;
   
   
-- ----------------------------------------------------------------------------
-- pllcfg_top instance
-- ----------------------------------------------------------------------------
   process(pllcfg_busy) 
      begin 
         inst2_pllcfg_busy <= (others=>'0');
         inst2_pllcfg_busy(0) <= pllcfg_busy;
   end process;
   
   process(pllcfg_done) 
      begin 
         inst2_pllcfg_done <= (others=>'1');
         inst2_pllcfg_done(0) <= pllcfg_done;
   end process;
   
   inst2_pll_lock          <= inst1_pll_locked     & inst0_pll_locked;   
   inst2_auto_phcfg_done   <= inst1_dynps_done     & inst0_dynps_done; 
   inst2_auto_phcfg_err    <= inst1_dynps_status   & inst0_dynps_status;

   pll_ctrl_inst2 : entity work.pll_ctrl 
   generic map(
      n_pll	=> N_PLL
   )
   port map(
      to_pllcfg         => to_pllcfg,
      from_pllcfg       => from_pllcfg,
         -- Status Inputs
      pllcfg_busy       => inst2_pllcfg_busy,
      pllcfg_done       => inst2_pllcfg_done,
         -- PLL Lock flags
      pll_lock          => inst2_pll_lock,
         -- PLL Configuration Related
      phcfg_mode        => inst2_phcfg_mode,
      phcfg_tst         => inst2_phcfg_tst,
      phcfg_start       => inst2_phcfg_start,   --
      pllcfg_start      => inst2_pllcfg_start,  --
      pllrst_start      => inst2_pllrst_start,  --
      phcfg_updn        => inst2_phcfg_updn,
      cnt_ind           => inst2_cnt_ind,       --
      cnt_phase         => inst2_cnt_phase,     --
      pllcfg_data       => inst2_pllcfg_data,
      auto_phcfg_done   => inst2_auto_phcfg_done,
      auto_phcfg_err    => inst2_auto_phcfg_err,
      auto_phcfg_smpls  => inst2_auto_phcfg_smpls,
      auto_phcfg_step   => inst2_auto_phcfg_step
        
      );
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------  
txpll_locked         <= inst0_pll_locked;
txpll_smpl_cmp_en    <= inst0_smpl_cmp_en;
txpll_smpl_cmp_cnt   <= inst2_auto_phcfg_smpls;

rxpll_locked         <= inst1_pll_locked;
rxpll_smpl_cmp_en    <= inst1_smpl_cmp_en;
rxpll_smpl_cmp_cnt   <= inst2_auto_phcfg_smpls;


end arch;   


