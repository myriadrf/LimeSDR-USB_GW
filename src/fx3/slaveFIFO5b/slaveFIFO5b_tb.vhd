-- ----------------------------------------------------------------------------	
-- FILE: 	slaveFIFO5b_tb.vhd
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
entity slaveFIFO5b_tb is
end slaveFIFO5b_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of slaveFIFO5b_tb is
	constant clk0_period   : time := 32.55208 ns;
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
	

  slaveFIFO_inst : entity work.slaveFIFO5b 
generic map (
	num_of_sockets 		=> 1,
	data_width				=> 16,
	data_dma_size			=> 1024,							--data endpoint dma size in bytes
	control_dma_size		=> 1024,							--control endpoint dma size in bytes
	data_pct_size			=> 1024,							--packet size in bytes
	control_pct_size		=> 64,								--packet size in bytes, should be less then max dma size
	socket0_wrusedw_size => 11,
	socket0_rdusedw_size	=> 10,
	socket1_wrusedw_size => 11,
	socket1_rdusedw_size	=> 10,
	socket2_wrusedw_size => 11,
	socket2_rdusedw_size	=> 10,
	socket3_wrusedw_size => 11,
	socket3_rdusedw_size	=> 10
)
port map(
		reset_n 					=> reset_n,
		clk	   				=> clk0, 
		clk_out	   			=> open,
		usb_speed				=> '1', 
		slcs 	   				=> open,
		fdata      				=> open,        
		faddr      				=> open,
		slrd	   				=> open,
		sloe	   				=> open,
		slwr	   				=> open,
                    
      flaga	   				=> '1',                               
		flagb	   				=> '1',
      flagc	   				=> '0',
      flagd	   				=> '0',

		pktend	   			=> open,
		EPSWITCH					=> open,

		socket0_fifo_data		=> open,
		socket0_fifo_q			=> (others=>'1'),
		socket0_fifo_wrusedw	=> (others=>'1'),
		socket0_fifo_rdusedw	=> (others=>'1'),
		socket0_fifo_wr		=> open,
		socket0_fifo_rd		=> open,

		socket1_fifo_data		=> open,
		socket1_fifo_q			=> (others=>'1'),
		socket1_fifo_wrusedw	=> (others=>'1'),
		socket1_fifo_rdusedw	=> (others=>'1'),
		socket1_fifo_wr		=> open,
		socket1_fifo_rd		=> open,

		socket2_fifo_data		=> open,
		socket2_fifo_q			=> (others=>'1'),
		socket2_fifo_wrusedw	=> (others=>'1'),
		socket2_fifo_rdusedw	=> (others=>'1'),
		socket2_fifo_wr		=> open,
		socket2_fifo_rd		=> open,

		socket3_fifo_data		=> open,
		socket3_fifo_q			=> (others=>'1'),
		socket3_fifo_wrusedw	=> (others=>'1'),
		socket3_fifo_rdusedw	=> (others=>'1'),
		socket3_fifo_wr		=> open,
		socket3_fifo_rd		=> open
	
    );
	
	end tb_behave;
  
  


  
