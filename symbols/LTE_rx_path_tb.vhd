-- ----------------------------------------------------------------------------	
-- FILE: 	LTE_rx_path_tb.vhd
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
entity LTE_rx_path_tb is
end LTE_rx_path_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of LTE_rx_path_tb is
	constant clk0_period   : time := 10 ns;
	constant clk1_period   : time := 10 ns; 
  --signals
	signal clk0,clk1		: std_logic;
	signal reset_n : std_logic; 


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
	
  
  LTE_rx_path_inst : entity work.rx_path 

GENERIC map (dev_family => "Cyclone IV E",
		diq_width => 12,
		infifo_wrsize => 12,
		outfifo_size => 13
		)
	PORT map
	(
		reset 			=> reset_n,
		en 				=> '1',
		data_src 		=> '1',
		outfifo_full	=> '0',
		DIQ2_IQSEL2 	=> '0',
		mimo_en 			=> '1',
		pct_clr_detect => '0',
		clr_pct_los_flg => '0',
		clr_smpl_nr		=> '0',
		fr_start			=> '0',
		clk				=> clk0,
		ch_en 			=> "0000000000000011",
		DIQ2_D 			=> (others=>'0'),
		outfifo_wusedw => (others=>'0'),
		smpl_width 		=> "10",
		outfifo_wr 		=> open,
		wrrxfifo_wr 	=> open,
		outfifo_data	=> open
	);
	
	end tb_behave;
  
  


  
