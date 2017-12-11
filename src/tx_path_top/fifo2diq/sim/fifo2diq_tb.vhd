-- ----------------------------------------------------------------------------	
-- FILE: 	fifo2diq_tb.vhd
-- DESCRIPTION:	
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity fifo2diq_tb is
end fifo2diq_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of fifo2diq_tb is
   --Config signals
   constant clk0_period    : time := 6.25 ns;
   constant clk1_period    : time := 6.25 ns; 
   
   signal inst0_mode       : std_logic:='0'; -- JESD207: 1; TRXIQ: 0
   signal inst0_trxiqpulse : std_logic:='0'; -- trxiqpulse on: 1; trxiqpulse off: 0
   signal inst0_ddr_en     : std_logic:='1'; -- DDR: 1; SDR: 0
   signal inst0_mimo_en    : std_logic:='1'; -- MIMO: 1; SISO: 0
   signal inst0_ch_en      : std_logic_vector(1 downto 0):="01"; --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
   signal inst0_fidm       : std_logic:='0'; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1. 

   -- Data to BB
   signal inst0_txant_cyc_before_en : std_logic_vector(15 downto 0) := x"0000";
   signal inst0_txant_cyc_after_en  : std_logic_vector(15 downto 0) := x"0000";
   signal inst0_DIQ                 : std_logic_vector(11 downto 0);
   signal inst0_fsync               : std_logic; --Frame start
   signal inst0_fifo_rdreq          : std_logic;
   signal inst0_pct_sync_mode       : std_logic := '1'; 
   signal inst0_pct_sync_size       : std_logic_vector(15 downto 0) := x"0008";
   signal inst0_pct_buff_rdy        : std_logic;
   
   --inst1 signals
   signal inst1_en         : std_logic;
   signal inst1_AI         : std_logic_vector(11 downto 0);	
   signal inst1_AQ         : std_logic_vector(11 downto 0);	
   signal inst1_BI         : std_logic_vector(11 downto 0);	
   signal inst1_BQ         : std_logic_vector(11 downto 0);
   
   --ins2 signals   
   signal inst2_data       : std_logic_vector(47 downto 0);   
   signal inst2_rdreq      : std_logic;     
   signal inst2_q          : std_logic_vector(47 downto 0);  
   signal inst2_rdempty    : std_logic; 
   signal inst2_wrreq      : std_logic;
   signal inst2_rdusedw    : std_logic_vector(10 downto 0);
   
   --inst3
   signal inst3_pulse      : std_logic; 
   signal inst3_wait_cycles: std_logic_vector(31 downto 0) := x"000000FF";

  --signals
   signal clk0,clk1        : std_logic;
   signal reset_n          : std_logic; 

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
   
    inst0en: process is
   begin
      inst1_en <= '0'; wait until reset_n = '1';
      inst1_en <= '0'; wait until rising_edge(clk0);
      inst1_en <= '1'; wait;
   end process inst0en;
   
 
inst0_diq2fifo : entity work.fifo2diq
   generic map( 
      dev_family           => "Cyclone IV E",
      iq_width             => 12
   )
   port map (
      clk                  => clk0,
      reset_n              => reset_n ,
      mode                 => inst0_mode,
      trxiqpulse           => inst0_trxiqpulse,
      ddr_en               => inst0_ddr_en,
      mimo_en              => inst0_mimo_en,
      ch_en                => inst0_ch_en,
      fidm                 => inst0_fidm,
      pct_sync_mode        => inst0_pct_sync_mode, 
      pct_sync_pulse       => inst3_pulse,
      pct_sync_size        => inst0_pct_sync_size,
      pct_buff_rdy         => inst0_pct_buff_rdy,
      txant_cyc_before_en  => inst0_txant_cyc_before_en,
      txant_cyc_after_en   => inst0_txant_cyc_after_en,
      txant_en             => open,
      DIQ                  => inst0_DIQ,
      fsync                => inst0_fsync,
      fifo_rdempty         => inst2_rdempty,
      fifo_rdreq           => inst0_fifo_rdreq,
      fifo_q               => inst2_q
     
        );  
        
inst0_pct_buff_rdy <= '1' when unsigned(inst2_rdusedw) > 256 else '0';
 
inst1_dac_data_sim : entity work.dac_data_sim 
   generic map( 
      file_name   => "sim/dac_data.txt",
      data_width  => 12 
   )
   port map (
      clk         => clk0,
      reset_n     => reset_n,
      en          => inst1_en,
      AI          => inst1_AI,
      AQ          => inst1_AQ,
      BI          => inst1_BI,
      BQ          => inst1_BQ      
        );
        
        
inst2_data <= inst1_AI & inst1_AQ & inst1_BI & inst1_BQ;

process(clk0, reset_n)
begin 
   if reset_n = '0' then 
      inst2_wrreq <= '0';
   elsif rising_edge(clk0) then 
      inst2_wrreq <= inst1_en;
   end if;
end process;
    
inst2_fifo_inst : entity work.fifo_inst
   generic map(
      dev_family      => "Cyclone IV E",
      wrwidth         => 48,
      wrusedw_witdth  => 11, 
      rdwidth         => 48,
      rdusedw_width   => 11,
      show_ahead      => "OFF"
  )
  port map(
      reset_n       => reset_n,
      wrclk         => clk0,
      wrreq         => inst2_wrreq,
      data          => inst2_data,
      wrfull        => open,
      wrempty       => open,
      wrusedw       => open,
      rdclk         => clk0,
      rdreq         => inst0_fifo_rdreq,
      q             => inst2_q,
      rdempty       => inst2_rdempty,
      rdusedw       => inst2_rdusedw 
); 

pulse_gen_inst3 : entity work.pulse_gen
   port map(
      clk         => clk0,
      reset_n     => reset_n,
      wait_cycles => inst3_wait_cycles,
      pulse       => inst3_pulse
   );
   






end tb_behave;
   

  