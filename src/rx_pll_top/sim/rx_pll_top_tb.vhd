-- ----------------------------------------------------------------------------
-- FILE:          rx_pll_top_tb.vhd
-- DESCRIPTION:   
-- DATE:          12:26 PM Monday, January 15, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity rx_pll_top_tb is
end rx_pll_top_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of rx_pll_top_tb is
   constant clk0_period    : time := 200 ns;
   constant clk1_period    : time := 32.552 ns; 
   --signals
   signal clk0,clk1        : std_logic;
   signal reset_n          : std_logic; 
      --PLL input 
   signal dut0_pll_areset  : std_logic;
   signal dut0_inv_c0      : std_logic;

   signal dut0_clk_ena           : std_logic_vector(1 downto 0) := "11";--clock output enable
   signal dut0_drct_clk_en       : std_logic_vector(1 downto 0);--1- Direct clk, 0 - PLL clocks 
   signal dut0_rcnfig_areset     : std_logic;
   signal dut0_rcnfig_en         : std_logic;
   --Reconfigure to 5MHz In and 5MHz output 
   signal dut0_rcnfig_data       : std_logic_vector(143 downto 0) := x"00004000100006592C964B2592C00C060070";
   signal dut0_rcnfig_status     : std_logic;
   signal dut0_dynps_mode        : std_logic;
   signal dut0_dynps_en          : std_logic;
   signal dut0_dynps_dir         : std_logic := '1';
   signal dut0_dynps_cnt_sel     : std_logic_vector(2 downto 0) := "010";
   signal dut0_dynps_phase       : std_logic_vector(9 downto 0);-- := "0000000001"; --90 deg at 5MHz = "0110110000"
   signal dut0_smpl_cmp_en       : std_logic;
   signal dut0_smpl_cmp_done     : std_logic;
   signal dut0_smpl_cmp_error    : std_logic;
   signal dut0_busy              : std_logic;
   signal dut0_pll_locked        : std_logic;
   signal dut0_dynps_done        : std_logic;
   signal dut0_dynps_status      : std_logic;
   
   signal dyn_ps_areset          : std_logic;
   
   
   
   
   
  
begin 
  
      clock0: process is
   begin
      clk0 <= '0'; wait for clk0_period/2;
      clk0 <= '1'; wait for clk0_period/2;
   end process clock0;

      clock: process is
   begin
      clk1 <= '0'; wait for clk1_period/2;
      clk1 <= '1'; wait for clk1_period/2;
   end process clock;
   
      res: process is
   begin
      reset_n <= '0'; wait for 20 ns;
      reset_n <= '1'; wait;
   end process res;
   
   
   --trigger pll reconfiguration
   process is
   begin
      dut0_rcnfig_en <= '0'; wait until reset_n = '1';
      wait until rising_edge(clk1);
      wait until rising_edge(clk1);
      wait until rising_edge(clk1);
      wait until rising_edge(clk1);
      wait until rising_edge(clk1);
      dut0_rcnfig_en <= '1';
      wait until rising_edge(clk1);
      wait until rising_edge(clk1);
      wait until rising_edge(clk1);
      wait until rising_edge(clk1);
      wait until rising_edge(clk1);
      dut0_rcnfig_en <= '0';
      wait;
   end process;
   
   process is
   begin
   
      --begin manual phase shift operation
      dut0_dynps_phase <= "0000000011";
      dut0_dynps_mode <= '0';
      dut0_dynps_en  <= '0';
      dyn_ps_areset <= '0'; wait until dut0_pll_locked = '1';
      wait until rising_edge(clk1);
      dyn_ps_areset <= '1';
      wait until rising_edge(clk1);
      dyn_ps_areset <= '0';
      wait until dut0_pll_locked = '1';
      dut0_dynps_en  <= '1';
      wait until dut0_dynps_done = '1';
      wait until rising_edge(clk1);
      dut0_dynps_en  <= '0';
      wait until rising_edge(clk1);
      --begin auto phase shift operation
      dut0_dynps_mode <= '1';
      dut0_dynps_en  <= '1';
      dut0_dynps_phase <= "0000000111";
      wait until dut0_dynps_done = '1';
      wait until rising_edge(clk1);
      dut0_dynps_mode <= '1';
      dut0_dynps_en  <= '0';
      
      wait;
   end process;
   
   process
   begin
      --throw error
      for i in 0 to 7 loop
         dut0_smpl_cmp_done   <= '0';
         dut0_smpl_cmp_error  <= '0';
         wait until dut0_smpl_cmp_en = '1';
         wait until rising_edge(clk1);
         dut0_smpl_cmp_done   <= '1';
         dut0_smpl_cmp_error  <= '1';
         wait until dut0_smpl_cmp_en = '0';
         dut0_smpl_cmp_done   <= '0';
         dut0_smpl_cmp_error  <= '0';
      end loop;
      
      --no error
      for i in 0 to 6 loop
         wait until dut0_smpl_cmp_en = '1';
         wait until rising_edge(clk1);
         dut0_smpl_cmp_done   <= '1';
         dut0_smpl_cmp_error  <= '0';
         wait until dut0_smpl_cmp_en = '0';
         dut0_smpl_cmp_done   <= '0';
         dut0_smpl_cmp_error  <= '0';
      end loop;
      
      --throw error
      for i in 0 to 0 loop
         wait until dut0_smpl_cmp_en = '1';
         wait until rising_edge(clk1);
         dut0_smpl_cmp_done   <= '1';
         dut0_smpl_cmp_error  <= '1';
         wait until dut0_smpl_cmp_en = '0';
         dut0_smpl_cmp_done   <= '0';
         dut0_smpl_cmp_error  <= '0';
      end loop;
      
         --last 
         wait until dut0_smpl_cmp_en = '1';
         wait until rising_edge(clk1);
         dut0_smpl_cmp_done   <= '1';
         dut0_smpl_cmp_error  <= '1';
         wait until dut0_smpl_cmp_en = '0';
         dut0_smpl_cmp_done   <= '0';
         dut0_smpl_cmp_error  <= '0';
      
      wait;
   end process;
   
   
   
   
   dut0_pll_areset      <= (not reset_n) OR dyn_ps_areset;
   dut0_rcnfig_areset   <= not reset_n;
   
   
   
   
      -- design under test  

   rx_pll_top_dut0 : entity work.rx_pll_top 
   generic map(
      bandwidth_type          => "AUTO",
      clk0_divide_by          => 1,
      clk0_duty_cycle         => 50,
      clk0_multiply_by        => 1,
      clk0_phase_shift        => "0",
      clk1_divide_by          => 1,
      clk1_duty_cycle         => 50,
      clk1_multiply_by        => 1,
      clk1_phase_shift        => "0",
      compensate_clock        => "CLK1",
      inclk0_input_frequency  => 6250,
      intended_device_family  => "Cyclone IV E",
      operation_mode          => "SOURCE_SYNCHRONOUS",
      scan_chain_mif_file     => "ip/pll/pll.mif",
      drct_c0_ndly            => 1,
      drct_c1_ndly            => 2
   )
   port map(
   --PLL input 
   pll_inclk         => clk0,
   pll_areset        => dut0_pll_areset,
   pll_logic_reset_n => reset_n,
   inv_c0            => dut0_inv_c0,
   c0                => open, --muxed clock output
   c1                => open, --muxed clock output
   pll_locked        => dut0_pll_locked,
   --Bypass control
   clk_ena           => dut0_clk_ena, --clock output enable
   drct_clk_en       => dut0_drct_clk_en, --1- Direct clk, 0 - PLL clocks 
   --Reconfiguration ports
   rcnfg_clk         => clk1,
   rcnfig_areset     => dut0_rcnfig_areset,
   rcnfig_en         => dut0_rcnfig_en,
   rcnfig_data       => dut0_rcnfig_data,
   rcnfig_status     => dut0_rcnfig_status,
   --Dynamic phase shift ports
   dynps_areset_n    => reset_n,
   dynps_mode        => dut0_dynps_mode,
   dynps_en          => dut0_dynps_en,
   dynps_dir         => dut0_dynps_dir,
   dynps_cnt_sel     => dut0_dynps_cnt_sel,
   -- max phase steps in auto mode, phase steps to shift in manual mode 
   dynps_phase       => dut0_dynps_phase,
   dynps_done        => dut0_dynps_done,
   dynps_status      => dut0_dynps_status,
   --signals from sample compare module (required for automatic phase searching)
   smpl_cmp_en       => dut0_smpl_cmp_en,
   smpl_cmp_done     => dut0_smpl_cmp_done,
   smpl_cmp_error    => dut0_smpl_cmp_error,
   --Overall configuration PLL status
   busy              => dut0_busy
   
   );

end tb_behave;

