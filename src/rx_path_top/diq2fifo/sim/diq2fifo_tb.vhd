-- ----------------------------------------------------------------------------	
-- FILE: 	diq2fifo_tb.vhd
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
entity diq2fifo_tb is
end diq2fifo_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of diq2fifo_tb is
	--Config signals
	constant clk0_period   : time := 6.25 ns;
	constant clk1_period   : time := 6.25 ns; 

	signal inst0_mode			: std_logic:='0'; -- JESD207: 1; TRXIQ: 0
	signal inst0_trxiqpulse	: std_logic:='1'; -- trxiqpulse on: 1; trxiqpulse off: 0
	signal inst0_ddr_en 		: std_logic:='1'; -- DDR: 1; SDR: 0
	signal inst0_mimo_en 	: std_logic:='1'; -- MIMO: 1; SISO: 0
	signal inst1_ch_en		: std_logic_vector(1 downto 0):="10"; --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
	signal inst0_fidm			: std_logic:='0'; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1. 

	-- Data to BB
	signal inst0_DIQ 			: std_logic_vector(11 downto 0);
	signal inst0_fsync		: std_logic; --Frame start

	--ins1 signals

	signal inst1_fifo_wrreq	: std_logic;
	signal inst1_fifo_wdata : std_logic_vector(47 downto 0);



  --signals
	signal clk0,clk1			: std_logic;
	signal reset_n 			: std_logic; 

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
	
  
inst0_LMS7002_DIQ2 : entity work.LMS7002_DIQ2_sim 
generic map (
	file_name => "sim/adc_data.txt",
	data_width => 12
)
port map(
	clk       	=> clk0,
	reset_n   	=> reset_n, 
	mode			=> inst0_mode,
	trxiqpulse	=> inst0_trxiqpulse,
	ddr_en 		=> inst0_ddr_en, 
	mimo_en		=> inst0_mimo_en,
	fidm			=> inst0_fidm, 

	-- Data to BB
	DIQ 			=> inst0_DIQ,
	fsync			=> inst0_fsync
	
    );
    
inst1_diq2fifo : entity work.diq2fifo
	generic map( 
      dev_family				=> "Cyclone IV E",
      iq_width					=> 12,
      invert_input_clocks	=> "OFF"
	)
	port map (
      clk         => clk0,
      reset_n     => reset_n ,
      mode			=> inst0_mode,
		trxiqpulse	=> inst0_trxiqpulse,
		ddr_en 		=> inst0_ddr_en,
		mimo_en		=> inst0_mimo_en,
		ch_en			=> inst1_ch_en,
		fidm			=> inst0_fidm,
      DIQ		 	=> inst0_DIQ,
		fsync	 	   => inst0_fsync,
      fifo_wrreq  => inst1_fifo_wrreq,
      fifo_wfull  => '0',
      fifo_wdata  => inst1_fifo_wdata
     
        );
	

    
	
	end tb_behave;
   
   
  
  


  