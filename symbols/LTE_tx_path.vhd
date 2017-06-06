-- Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus Prime License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 15.1.2 Build 193 02/01/2016 SJ Standard Edition"
-- CREATED		"Sat Jun  3 22:42:17 2017"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY LTE_tx_path IS 
GENERIC (dev_family : STRING := "Cyclone IV E"
		);
	PORT
	(
		rxpll_locked :  IN  STD_LOGIC;
		txpll_locked :  IN  STD_LOGIC;
		rxpath_wr :  IN  STD_LOGIC;
		stream_rxen :  IN  STD_LOGIC;
		lte_synch_dis :  IN  STD_LOGIC;
		lte_mimo_en :  IN  STD_LOGIC;
		pct_wr :  IN  STD_LOGIC;
		pct_wrclk :  IN  STD_LOGIC;
		RX_clk :  IN  STD_LOGIC;
		TX_clk :  IN  STD_LOGIC;
		fr_start :  IN  STD_LOGIC;
		rx_cap_en :  IN  STD_LOGIC;
		tx_reset_req :  IN  STD_LOGIC;
		lte_clr_smpl_nr :  IN  STD_LOGIC;
		lte_ch_en :  IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		lte_smpl_width :  IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		pct_data :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		pct_fifo_rdy :  OUT  STD_LOGIC;
		pct_cleared :  OUT  STD_LOGIC;
		dd_data_h :  OUT  STD_LOGIC_VECTOR(12 DOWNTO 0);
		dd_data_l :  OUT  STD_LOGIC_VECTOR(12 DOWNTO 0)
	);
END LTE_tx_path;

ARCHITECTURE bdf_type OF LTE_tx_path IS 

COMPONENT sample_nr_cnt_mimo
GENERIC (ch_num : INTEGER
			);
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 en : IN STD_LOGIC;
		 fifo_wr : IN STD_LOGIC;
		 mimo_en : IN STD_LOGIC;
		 clr_smpl_nr : IN STD_LOGIC;
		 ch_en : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 sample_nr : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sync_fifo_rw
GENERIC (data_w : INTEGER;
			dev_family : STRING
			);
	PORT(wclk : IN STD_LOGIC;
		 rclk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 sync_en : IN STD_LOGIC;
		 sync_data : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
		 sync_q : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
	);
END COMPONENT;

COMPONENT synchronizer
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 signal_in : IN STD_LOGIC;
		 signal_sinch : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT tx_synchronizers
	PORT(clk0 : IN STD_LOGIC;
		 clk0_reset_n : IN STD_LOGIC;
		 clk1 : IN STD_LOGIC;
		 clk1_reset_n : IN STD_LOGIC;
		 clk1_d1 : IN STD_LOGIC;
		 clk1_d2 : IN STD_LOGIC;
		 clk1_d3 : IN STD_LOGIC;
		 clk2 : IN STD_LOGIC;
		 clk2_reset_n : IN STD_LOGIC;
		 clk2_d0 : IN STD_LOGIC;
		 clk0_d0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 clk1_d0 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 clk1_s1 : OUT STD_LOGIC;
		 clk1_s2 : OUT STD_LOGIC;
		 clk1_s3 : OUT STD_LOGIC;
		 clk2_s0 : OUT STD_LOGIC;
		 clk0_s0 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 clk1_s0 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT tx_pct_data_mimo_v3
GENERIC (dcmpr_fifo : INTEGER;
			dev_family : STRING;
			fifo_size : INTEGER;
			num_of_fifo : INTEGER;
			pct_size : INTEGER;
			smpl_width : INTEGER
			);
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 reset_n_fifo_wclk : IN STD_LOGIC;
		 fifo_wclk : IN STD_LOGIC;
		 fifo_wrreq : IN STD_LOGIC;
		 fifo_rclk : IN STD_LOGIC;
		 tx_en : IN STD_LOGIC;
		 lte_synch_dis : IN STD_LOGIC;
		 mimo_en : IN STD_LOGIC;
		 fr_start : IN STD_LOGIC;
		 ch_en : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 fifo_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 pct_samplenr : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
		 sample_width : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 tx_outfifo_rdy : OUT STD_LOGIC;
		 tst_aclr_ext : OUT STD_LOGIC;
		 dd_data_h : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		 dd_data_l : OUT STD_LOGIC_VECTOR(12 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	H :  STD_LOGIC;
SIGNAL	L :  STD_LOGIC;
SIGNAL	lte_ch_en_mclk2rx_pll :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	lte_mimo_en_lmlclk :  STD_LOGIC;
SIGNAL	lte_mimo_en_mclk2rxpll :  STD_LOGIC;
SIGNAL	lte_smpl_width_lmlclk :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	lte_synch_dis_lmlclk :  STD_LOGIC;
SIGNAL	mclk1tx_locked :  STD_LOGIC;
SIGNAL	pct_buff_aclr :  STD_LOGIC;
SIGNAL	pct_samplenr :  STD_LOGIC_VECTOR(63 DOWNTO 0);
SIGNAL	rxen_pct_clk :  STD_LOGIC;
SIGNAL	stream_rxen_lmlclk :  STD_LOGIC;
SIGNAL	stream_rxen_mclk2rxpll :  STD_LOGIC;
SIGNAL	tx_outfifo_rdy :  STD_LOGIC;
SIGNAL	wrrxfifo_wr :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(63 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;


BEGIN 




b2v_inst1 : sample_nr_cnt_mimo
GENERIC MAP(ch_num => 16
			)
PORT MAP(clk => RX_clk,
		 reset_n => stream_rxen_mclk2rxpll,
		 en => stream_rxen_mclk2rxpll,
		 fifo_wr => wrrxfifo_wr,
		 mimo_en => lte_mimo_en_mclk2rxpll,
		 clr_smpl_nr => lte_clr_smpl_nr,
		 ch_en => lte_ch_en_mclk2rx_pll,
		 sample_nr => SYNTHESIZED_WIRE_0);



b2v_inst24 : sync_fifo_rw
GENERIC MAP(data_w => 64,
			dev_family => "Cyclone IV E"
			)
PORT MAP(wclk => RX_clk,
		 rclk => TX_clk,
		 reset_n => stream_rxen_lmlclk,
		 sync_en => stream_rxen_lmlclk,
		 sync_data => SYNTHESIZED_WIRE_0,
		 sync_q => pct_samplenr);


b2v_inst28 : synchronizer
PORT MAP(clk => RX_clk,
		 reset_n => rxpll_locked,
		 signal_in => stream_rxen,
		 signal_sinch => SYNTHESIZED_WIRE_1);


stream_rxen_mclk2rxpll <= rx_cap_en AND SYNTHESIZED_WIRE_1;


rxen_pct_clk <= SYNTHESIZED_WIRE_2 AND SYNTHESIZED_WIRE_3;


SYNTHESIZED_WIRE_2 <= NOT(tx_reset_req);



b2v_inst74 : tx_synchronizers
PORT MAP(clk0 => RX_clk,
		 clk0_reset_n => rxpll_locked,
		 clk1 => TX_clk,
		 clk1_reset_n => mclk1tx_locked,
		 clk1_d1 => rxen_pct_clk,
		 clk1_d2 => lte_synch_dis,
		 clk1_d3 => lte_mimo_en,
		 clk2 => L,
		 clk2_reset_n => L,
		 clk2_d0 => L,
		 clk0_d0 => lte_ch_en,
		 clk1_d0 => lte_smpl_width,
		 clk1_s1 => stream_rxen_lmlclk,
		 clk1_s2 => lte_synch_dis_lmlclk,
		 clk1_s3 => lte_mimo_en_lmlclk,
		 clk0_s0 => lte_ch_en_mclk2rx_pll,
		 clk1_s0 => lte_smpl_width_lmlclk);


b2v_inst77 : synchronizer
PORT MAP(clk => pct_wrclk,
		 reset_n => H,
		 signal_in => stream_rxen,
		 signal_sinch => SYNTHESIZED_WIRE_3);


b2v_inst8 : synchronizer
PORT MAP(clk => RX_clk,
		 reset_n => rxpll_locked,
		 signal_in => lte_mimo_en,
		 signal_sinch => lte_mimo_en_mclk2rxpll);


b2v_inst9 : tx_pct_data_mimo_v3
GENERIC MAP(dcmpr_fifo => 10,
			dev_family => "Cyclone IV E",
			fifo_size => 10,
			num_of_fifo => 3,
			pct_size => 2048,
			smpl_width => 12
			)
PORT MAP(clk => TX_clk,
		 reset_n => stream_rxen_lmlclk,
		 reset_n_fifo_wclk => rxen_pct_clk,
		 fifo_wclk => pct_wrclk,
		 fifo_wrreq => pct_wr,
		 fifo_rclk => TX_clk,
		 tx_en => stream_rxen_lmlclk,
		 lte_synch_dis => lte_synch_dis_lmlclk,
		 mimo_en => lte_mimo_en_lmlclk,
		 fr_start => fr_start,
		 ch_en => lte_ch_en(1 DOWNTO 0),
		 fifo_data => pct_data,
		 pct_samplenr => pct_samplenr,
		 sample_width => lte_smpl_width_lmlclk,
		 tx_outfifo_rdy => tx_outfifo_rdy,
		 tst_aclr_ext => pct_buff_aclr,
		 dd_data_h => dd_data_h,
		 dd_data_l => dd_data_l);

pct_fifo_rdy <= tx_outfifo_rdy;
mclk1tx_locked <= txpll_locked;
wrrxfifo_wr <= rxpath_wr;
pct_cleared <= pct_buff_aclr;

H <= '1';
L <= '0';
END bdf_type;