-- ----------------------------------------------------------------------------	
-- FILE: 	wfm_player_tb.vhd
-- DESCRIPTION:	
-- DATE:	June 20, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity wfm_player_tb is
end wfm_player_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of wfm_player_tb is
	constant clk0_period   		: time := 6.25 ns; 	-- 160 MHZ as LMS tx interface clk
	constant clk1_period   		: time := 10 ns;  	-- 100 MHz as a FX3 clk
	constant	clk2_period			: time := 12.5 ns;	-- 80 Mhz as DDR2 phy clk
  --signals
	signal clk0,clk1, clk2				: std_logic;
	signal reset_n 				: std_logic; 

	signal pct_wr					: std_logic;
	signal pct_wr_cnt				: unsigned(15 downto 0);


	signal pct_payload_valid 	: std_logic;
	signal pct_payload_data		: std_logic_vector(31 downto 0);

   signal data_fifo_rdreq		: std_logic;
	signal data_fifo_rdempty	: std_logic;
	signal data_fifo_rdusedw	: std_logic_vector(8 downto 0); 

	signal wfm_load				: std_logic;  
	signal wfm_play_stop			: std_logic;
	signal wfm_pct_gen_data		: std_logic_vector(31 downto 0); 
	signal wfm_pct_gen_wr		: std_logic;

	signal wfm_player_infifo_wrusedw 	: std_logic_vector(10downto 0);


 
begin 
  
   	clock0: process is
	begin
		clk0 <= '0'; wait for clk0_period/2;
		clk0 <= '1'; wait for clk0_period/2;
	end process clock0;

   	clock1: process is
	begin
		clk1 <= '0'; wait for clk1_period/2;
		clk1 <= '1'; wait for clk1_period/2;
	end process clock1;

   	clock2: process is
	begin
		clk2 <= '0'; wait for clk2_period/2;
		clk2 <= '1'; wait for clk2_period/2;
	end process clock2;
	
		res: process is
	begin
		reset_n <= '0'; wait for 20 ns;
		reset_n <= '1'; wait;
	end process res;

		load: process is
	begin
		wfm_load <= '0'; wait for 100 ns;
		wfm_load <= '1'; wait for 200 ns;
		wfm_load <= '0'; wait for 1400 ns;
	end process load;

		play_stop: process is
	begin
		wfm_play_stop <= '0'; wait for 1000 ns;
		wfm_play_stop <= '1'; wait for 110 ns;
	end process play_stop;




process (reset_n, clk1) 
	begin 
		if reset_n='0' then 
			pct_wr_cnt<=(others=>'0');
		elsif (clk1'event and clk1='1') then 
			pct_wr_cnt<=pct_wr_cnt+1;
		end if;
end process;


payload_extract_inst : entity work.pct_payload_extrct 
	generic map (data_w			=> 32,
					header_size		=> 16,  --pct header size in bytes 
					pct_size			=> 4096 --pct size in bytes
		)
  port map (
      --input ports 
		clk						=> clk1,
		reset_n					=> reset_n,
		pct_wr					=> wfm_pct_gen_wr,
		pct_data					=> wfm_pct_gen_data, --14
		pct_payload_valid		=> pct_payload_valid,
		pct_payload_data		=> pct_payload_data,
		pct_payload_dest		=> open
        );


wfm_player_top_inst : entity work.wfm_player_top
	generic map(
			dev_family			=> "Cyclone IV E", 
			--DDR2 controller parameters
			cntrl_rate			=> 1, --1 - full rate, 2 - half rate
			cntrl_bus_size		=> 16,
			addr_size			=> 24,
			lcl_bus_size		=> 63,
			lcl_burst_length	=> 2,
			cmd_fifo_size		=> 9,
			--WFM player parameters
			wfm_infifo_size	=> 11,
			wfm_outfifo_size	=> 11, 
			data_width			=> 32,
			iq_width				=> 12
)
  port map (

		ddr2_pll_ref_clk		=> clk2,
		ddr2_reset_n			=> reset_n,


		wcmd_clk					=> clk1,
		wcmd_reset_n			=> reset_n,
		
		rcmd_clk					=> clk0,
		rcmd_reset_n			=> reset_n,

		wfm_load					=> wfm_load,
		wfm_play_stop			=> wfm_play_stop,

		wfm_data					=> pct_payload_data,
		wfm_wr					=> pct_payload_valid,
		wfm_infifo_wrusedw 	=> wfm_player_infifo_wrusedw,

		iq_clk					=> clk0, 
		dd_iq_h					=> open,
		dd_iq_l					=> open,
		mem_odt					=> open,
		mem_cs_n					=> open,
		mem_cke					=> open,
		mem_addr					=> open,
		mem_ba					=> open,
		mem_ras_n				=> open,
		mem_cas_n				=> open,
		mem_we_n					=> open,
		mem_dm					=> open,
		phy_clk					=> open,
		mem_clk					=> open,
		mem_clk_n				=> open,
		mem_dq					=> open,
		mem_dqs					=> open
);


wfm_pct_gen_inst : entity work.wfm_pct_gen
	generic map(
		payload_size			=> 20, 
		dev_family				=> "Cyclone IV E",  
		wfm_infifo_size		=> 11, 
		data_width				=> 32 
)
  port map (
      --input ports 
      clk						=> clk1, 
      reset_n					=> reset_n, 
		wfm_load					=> wfm_load,  
		wfm_play_stop			=> wfm_play_stop, 
		wfm_data					=> wfm_pct_gen_data, 
		wfm_wr					=> wfm_pct_gen_wr, 
		wfm_infifo_wrusedw 	=> wfm_player_infifo_wrusedw

   
        );





	end tb_behave;
  
  


  
