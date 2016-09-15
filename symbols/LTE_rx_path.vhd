-- Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus II License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 15.0.0 Build 145 04/22/2015 SJ Web Edition"
-- CREATED		"Wed Sep 14 11:34:15 2016"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY LTE_rx_path IS 
GENERIC (dev_family : STRING := "Cyclone IV E";
		diq_width : INTEGER := 12;
		infifo_wrsize : INTEGER := 12;
		outfifo_size : INTEGER := 13
		);
	PORT
	(
		reset :  IN  STD_LOGIC;
		en :  IN  STD_LOGIC;
		data_src :  IN  STD_LOGIC;
		outfifo_full :  IN  STD_LOGIC;
		DIQ2_IQSEL2 :  IN  STD_LOGIC;
		mimo_en :  IN  STD_LOGIC;
		pct_clr_detect :  IN  STD_LOGIC;
		clr_pct_los_flg :  IN  STD_LOGIC;
		clr_smpl_nr :  IN  STD_LOGIC;
		fr_start :  IN  STD_LOGIC;
		clk :  IN  STD_LOGIC;
		ch_en :  IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		DIQ2_D :  IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
		outfifo_wusedw :  IN  STD_LOGIC_VECTOR(12 DOWNTO 0);
		smpl_width :  IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		outfifo_wr :  OUT  STD_LOGIC;
		wrrxfifo_wr :  OUT  STD_LOGIC;
		outfifo_data :  OUT  STD_LOGIC_VECTOR(63 DOWNTO 0)
	);
END LTE_rx_path;

ARCHITECTURE bdf_type OF LTE_rx_path IS 

COMPONENT rx_pct_data_v2
GENERIC (ch_num : INTEGER;
			infifo_rdsize : INTEGER;
			outfifo_wrsize : INTEGER;
			pct_size : INTEGER
			);
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 infifo_empty : IN STD_LOGIC;
		 outfifo_full : IN STD_LOGIC;
		 en : IN STD_LOGIC;
		 mimo_en : IN STD_LOGIC;
		 tx_pct_loss : IN STD_LOGIC;
		 tx_pct_loss_clr : IN STD_LOGIC;
		 clr_smpl_nr : IN STD_LOGIC;
		 ch_en : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 diq0 : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
		 infifo_rdusedw : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		 outfifo_wrusedw : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		 sample_width : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 infifo_rd : OUT STD_LOGIC;
		 outfifo_wr : OUT STD_LOGIC;
		 pct_wr_end : OUT STD_LOGIC;
		 outfifo_data : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
	);
END COMPONENT;

COMPONENT diq2_samples
GENERIC (ch_num : INTEGER;
			dev_family : STRING;
			diq_width : INTEGER;
			fifo_wrsize : INTEGER
			);
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 en : IN STD_LOGIC;
		 rxiqsel : IN STD_LOGIC;
		 data_src : IN STD_LOGIC;
		 fr_start : IN STD_LOGIC;
		 mimo_en : IN STD_LOGIC;
		 fifo_full : IN STD_LOGIC;
		 ch_en : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 fifo_wrusedw : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 rxiq : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 fifo_wr : OUT STD_LOGIC;
		 diq : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
	);
END COMPONENT;

COMPONENT fifo_inst
GENERIC (dev_family : STRING;
			rdusedw_width : INTEGER;
			rdwidth : INTEGER;
			show_ahead : STRING;
			wrusedw_witdth : INTEGER;
			wrwidth : INTEGER
			);
	PORT(reset_n : IN STD_LOGIC;
		 wrclk : IN STD_LOGIC;
		 wrreq : IN STD_LOGIC;
		 rdclk : IN STD_LOGIC;
		 rdreq : IN STD_LOGIC;
		 data : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		 wrfull : OUT STD_LOGIC;
		 wrempty : OUT STD_LOGIC;
		 rdempty : OUT STD_LOGIC;
		 q : OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
		 rdusedw : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
		 wrusedw : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	diq :  STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL	DIQ2_RXD :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	ENABLE_RXIQSEL_2 :  STD_LOGIC;
SIGNAL	fifo24_full :  STD_LOGIC;
SIGNAL	fifo24_q :  STD_LOGIC_VECTOR(47 DOWNTO 0);
SIGNAL	fifo24_rdempty :  STD_LOGIC;
SIGNAL	fifo24_rdusedw :  STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL	L :  STD_LOGIC;
SIGNAL	lte_ch_en :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	lte_txpct_loss_clr :  STD_LOGIC;
SIGNAL	pcie_tx_fifo32_wfull :  STD_LOGIC;
SIGNAL	pcie_tx_fifo32_wusedw :  STD_LOGIC_VECTOR(12 DOWNTO 0);
SIGNAL	pct_buff_aclr :  STD_LOGIC;
SIGNAL	pct_wr_end :  STD_LOGIC;
SIGNAL	rx_en :  STD_LOGIC;
SIGNAL	rx_pct_data :  STD_LOGIC_VECTOR(63 DOWNTO 0);
SIGNAL	rxpct_infiford :  STD_LOGIC;
SIGNAL	rxpct_outfifowr :  STD_LOGIC;
SIGNAL	rxpll_locked :  STD_LOGIC;
SIGNAL	wrrxfifo_wr_ALTERA_SYNTHESIZED :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(0 TO 11);

SIGNAL	GDFX_TEMP_SIGNAL_0 :  STD_LOGIC_VECTOR(63 DOWNTO 0);

BEGIN 
SYNTHESIZED_WIRE_0 <= "000000000000";

GDFX_TEMP_SIGNAL_0 <= (L & L & L & L & L & L & L & L & L & L & L & L & L & L & L & L & fifo24_q(47 DOWNTO 0));


b2v_inst : rx_pct_data_v2
GENERIC MAP(ch_num => 16,
			infifo_rdsize => 11,
			outfifo_wrsize => 13,
			pct_size => 4096
			)
PORT MAP(clk => clk,
		 reset_n => rx_en,
		 infifo_empty => fifo24_rdempty,
		 outfifo_full => pcie_tx_fifo32_wfull,
		 en => rx_en,
		 mimo_en => mimo_en,
		 tx_pct_loss => pct_buff_aclr,
		 tx_pct_loss_clr => lte_txpct_loss_clr,
		 clr_smpl_nr => clr_smpl_nr,
		 ch_en => lte_ch_en,
		 diq0 => GDFX_TEMP_SIGNAL_0,
		 infifo_rdusedw => fifo24_rdusedw,
		 outfifo_wrusedw => pcie_tx_fifo32_wusedw,
		 sample_width => smpl_width,
		 infifo_rd => rxpct_infiford,
		 outfifo_wr => rxpct_outfifowr,
		 outfifo_data => rx_pct_data);


b2v_inst1 : diq2_samples
GENERIC MAP(ch_num => 2,
			dev_family => "Cyclone IV E",
			diq_width => 12,
			fifo_wrsize => 12
			)
PORT MAP(clk => clk,
		 reset_n => rxpll_locked,
		 en => rx_en,
		 rxiqsel => ENABLE_RXIQSEL_2,
		 data_src => data_src,
		 fr_start => fr_start,
		 mimo_en => mimo_en,
		 fifo_full => fifo24_full,
		 ch_en => lte_ch_en(1 DOWNTO 0),
		 fifo_wrusedw => SYNTHESIZED_WIRE_0,
		 rxiq => DIQ2_RXD,
		 fifo_wr => wrrxfifo_wr_ALTERA_SYNTHESIZED,
		 diq => diq);




b2v_inst8 : fifo_inst
GENERIC MAP(dev_family => "Cyclone IV E",
			rdusedw_width => 11,
			rdwidth => 48,
			show_ahead => "ON",
			wrusedw_witdth => 12,
			wrwidth => 24
			)
PORT MAP(reset_n => rx_en,
		 wrclk => clk,
		 wrreq => wrrxfifo_wr_ALTERA_SYNTHESIZED,
		 rdclk => clk,
		 rdreq => rxpct_infiford,
		 data => diq,
		 wrfull => fifo24_full,
		 rdempty => fifo24_rdempty,
		 q => fifo24_q,
		 rdusedw => fifo24_rdusedw);

outfifo_wr <= rxpct_outfifowr;
rx_en <= en;
rxpll_locked <= reset;
ENABLE_RXIQSEL_2 <= DIQ2_IQSEL2;
lte_ch_en <= ch_en;
DIQ2_RXD <= DIQ2_D;
pcie_tx_fifo32_wfull <= outfifo_full;
pct_buff_aclr <= pct_clr_detect;
lte_txpct_loss_clr <= clr_pct_los_flg;
pcie_tx_fifo32_wusedw <= outfifo_wusedw;
wrrxfifo_wr <= wrrxfifo_wr_ALTERA_SYNTHESIZED;
outfifo_data <= rx_pct_data;

L <= '0';
END bdf_type;