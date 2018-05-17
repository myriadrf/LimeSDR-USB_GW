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
-- VERSION		"Version 15.1.2 Build 193 02/01/2016 SJ Lite Edition"
-- CREATED		"Wed May 09 09:37:56 2018"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY pll_top IS 
	PORT
	(
		LMS_FCLK1 :  OUT  STD_LOGIC;
		LMS_FCLK2 :  OUT  STD_LOGIC
	);
END pll_top;

ARCHITECTURE bdf_type OF pll_top IS 

COMPONENT tx_pll_top
GENERIC (bandwidth_type : STRING;
			clk0_divide_by : INTEGER;
			clk0_duty_cycle : INTEGER;
			clk0_multiply_by : INTEGER;
			clk0_phase_shift : STRING;
			clk1_divide_by : INTEGER;
			clk1_duty_cycle : INTEGER;
			clk1_multiply_by : INTEGER;
			clk1_phase_shift : STRING;
			compensate_clock : STRING;
			drct_c0_ndly : INTEGER;
			drct_c1_ndly : INTEGER;
			inclk0_input_frequency : INTEGER;
			intended_device_family : STRING;
			operation_mode : STRING;
			scan_chain_mif_file : STRING
			);
	PORT(pll_inclk : IN STD_LOGIC;
		 pll_areset : IN STD_LOGIC;
		 pll_logic_reset_n : IN STD_LOGIC;
		 inv_c0 : IN STD_LOGIC;
		 rcnfg_clk : IN STD_LOGIC;
		 rcnfig_areset : IN STD_LOGIC;
		 rcnfig_en : IN STD_LOGIC;
		 dynps_areset_n : IN STD_LOGIC;
		 dynps_mode : IN STD_LOGIC;
		 dynps_en : IN STD_LOGIC;
		 dynps_tst : IN STD_LOGIC;
		 dynps_dir : IN STD_LOGIC;
		 smpl_cmp_done : IN STD_LOGIC;
		 smpl_cmp_error : IN STD_LOGIC;
		 clk_ena : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 drct_clk_en : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 dynps_cnt_sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 dynps_phase : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 dynps_step_size : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 rcnfig_data : IN STD_LOGIC_VECTOR(143 DOWNTO 0);
		 c0 : OUT STD_LOGIC;
		 c1 : OUT STD_LOGIC;
		 pll_locked : OUT STD_LOGIC;
		 rcnfig_status : OUT STD_LOGIC;
		 dynps_busy : OUT STD_LOGIC;
		 dynps_done : OUT STD_LOGIC;
		 dynps_status : OUT STD_LOGIC;
		 smpl_cmp_en : OUT STD_LOGIC;
		 busy : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT rx_pll_top
GENERIC (bandwidth_type : STRING;
			clk0_divide_by : INTEGER;
			clk0_duty_cycle : INTEGER;
			clk0_multiply_by : INTEGER;
			clk0_phase_shift : STRING;
			clk1_divide_by : INTEGER;
			clk1_duty_cycle : INTEGER;
			clk1_multiply_by : INTEGER;
			clk1_phase_shift : STRING;
			compensate_clock : STRING;
			drct_c0_ndly : INTEGER;
			drct_c1_ndly : INTEGER;
			inclk0_input_frequency : INTEGER;
			intended_device_family : STRING;
			operation_mode : STRING;
			scan_chain_mif_file : STRING
			);
	PORT(pll_inclk : IN STD_LOGIC;
		 pll_areset : IN STD_LOGIC;
		 pll_logic_reset_n : IN STD_LOGIC;
		 inv_c0 : IN STD_LOGIC;
		 rcnfg_clk : IN STD_LOGIC;
		 rcnfig_areset : IN STD_LOGIC;
		 rcnfig_en : IN STD_LOGIC;
		 dynps_mode : IN STD_LOGIC;
		 dynps_areset_n : IN STD_LOGIC;
		 dynps_en : IN STD_LOGIC;
		 dynps_tst : IN STD_LOGIC;
		 dynps_dir : IN STD_LOGIC;
		 smpl_cmp_done : IN STD_LOGIC;
		 smpl_cmp_error : IN STD_LOGIC;
		 clk_ena : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 drct_clk_en : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 dynps_cnt_sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 dynps_phase : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 dynps_step_size : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 rcnfig_data : IN STD_LOGIC_VECTOR(143 DOWNTO 0);
		 c0 : OUT STD_LOGIC;
		 c1 : OUT STD_LOGIC;
		 pll_locked : OUT STD_LOGIC;
		 rcnfig_status : OUT STD_LOGIC;
		 dynps_busy : OUT STD_LOGIC;
		 dynps_done : OUT STD_LOGIC;
		 dynps_status : OUT STD_LOGIC;
		 smpl_cmp_en : OUT STD_LOGIC;
		 busy : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT pllcfg_top
GENERIC (n_pll : INTEGER
			);
	PORT(sdinA : IN STD_LOGIC;
		 sclkA : IN STD_LOGIC;
		 senA : IN STD_LOGIC;
		 sdinB : IN STD_LOGIC;
		 sclkB : IN STD_LOGIC;
		 senB : IN STD_LOGIC;
		 lreset : IN STD_LOGIC;
		 mreset : IN STD_LOGIC;
		 auto_phcfg_done : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 auto_phcfg_err : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 pll_lock : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 pllcfg_busy : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 pllcfg_done : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 sdoutA : OUT STD_LOGIC;
		 oenA : OUT STD_LOGIC;
		 sdoutB : OUT STD_LOGIC;
		 oenB : OUT STD_LOGIC;
		 phcfg_mode : OUT STD_LOGIC;
		 phcfg_tst : OUT STD_LOGIC;
		 phcfg_updn : OUT STD_LOGIC;
		 auto_phcfg_smpls : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 auto_phcfg_step : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 cnt_ind : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 cnt_phase : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 phcfg_start : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 pllcfg_data : OUT STD_LOGIC_VECTOR(143 DOWNTO 0);
		 pllcfg_start : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 pllrst_start : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	cnt_ind :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	cnt_phase :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	drc_clk_en :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	fclk1 :  STD_LOGIC;
SIGNAL	fpga_reset :  STD_LOGIC;
SIGNAL	fpga_reset_n :  STD_LOGIC;
SIGNAL	fpgapll_locked :  STD_LOGIC;
SIGNAL	H :  STD_LOGIC;
SIGNAL	L :  STD_LOGIC;
SIGNAL	LMK_CLK :  STD_LOGIC;
SIGNAL	lmlclk :  STD_LOGIC;
SIGNAL	MCLK1TX :  STD_LOGIC;
SIGNAL	mclk1tx_locked :  STD_LOGIC;
SIGNAL	MCLK2RX :  STD_LOGIC;
SIGNAL	MCLK2RX_pll :  STD_LOGIC;
SIGNAL	MCLK2RX_pll_d :  STD_LOGIC;
SIGNAL	phcfg_start :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	phcfg_updn :  STD_LOGIC;
SIGNAL	pllcfg_auto_phcfg_smpls :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	pllcfg_auto_phcfg_step :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	pllcfg_busy :  STD_LOGIC;
SIGNAL	pllcfg_data :  STD_LOGIC_VECTOR(143 DOWNTO 0);
SIGNAL	pllcfg_done :  STD_LOGIC;
SIGNAL	pllcfg_oenA :  STD_LOGIC;
SIGNAL	pllcfg_phcfg_mode :  STD_LOGIC;
SIGNAL	pllcfg_phcfg_tst :  STD_LOGIC;
SIGNAL	pllcfg_sdoutA :  STD_LOGIC;
SIGNAL	pllcfg_start :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	pllrst_start :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	rx_path_smpl_cmp_done :  STD_LOGIC;
SIGNAL	rx_path_smpl_cmp_err :  STD_LOGIC;
SIGNAL	rx_reconfig_status :  STD_LOGIC;
SIGNAL	rxpll_dynps_done :  STD_LOGIC;
SIGNAL	rxpll_dynps_status :  STD_LOGIC;
SIGNAL	rxpll_locked :  STD_LOGIC;
SIGNAL	rxpll_smpcmp_en :  STD_LOGIC;
SIGNAL	rxpllcfg_busy :  STD_LOGIC;
SIGNAL	spi_enables :  STD_LOGIC_VECTOR(1 TO 1);
SIGNAL	spi_lms_external_MOSI :  STD_LOGIC;
SIGNAL	spi_lms_external_SCLK :  STD_LOGIC;
SIGNAL	tx_reconfig_status :  STD_LOGIC;
SIGNAL	txpll_dynps_done :  STD_LOGIC;
SIGNAL	txpll_dynps_status :  STD_LOGIC;
SIGNAL	txpll_smpcmp_en :  STD_LOGIC;
SIGNAL	txpllcfg_busy :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;

SIGNAL	GDFX_TEMP_SIGNAL_5 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_4 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_8 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_7 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_6 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_1 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_0 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_2 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_3 :  STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN 

GDFX_TEMP_SIGNAL_5 <= (rxpll_dynps_status & txpll_dynps_status);
GDFX_TEMP_SIGNAL_4 <= (rxpll_dynps_done & txpll_dynps_done);
GDFX_TEMP_SIGNAL_8 <= (H & pllcfg_done);
GDFX_TEMP_SIGNAL_7 <= (L & pllcfg_busy);
GDFX_TEMP_SIGNAL_6 <= (rxpll_locked & mclk1tx_locked);
GDFX_TEMP_SIGNAL_1 <= (drc_clk_en(0) & drc_clk_en(0));
GDFX_TEMP_SIGNAL_0 <= (H & H);
GDFX_TEMP_SIGNAL_2 <= (H & H);
GDFX_TEMP_SIGNAL_3 <= (drc_clk_en(1) & drc_clk_en(1));


pllcfg_busy <= txpllcfg_busy OR rxpllcfg_busy;


pllcfg_done <= NOT(pllcfg_busy);



b2v_inst32 : tx_pll_top
GENERIC MAP(bandwidth_type => "AUTO",
			clk0_divide_by => 1,
			clk0_duty_cycle => 50,
			clk0_multiply_by => 1,
			clk0_phase_shift => "0",
			clk1_divide_by => 1,
			clk1_duty_cycle => 50,
			clk1_multiply_by => 1,
			clk1_phase_shift => "0",
			compensate_clock => "CLK1",
			drct_c0_ndly => 1,
			drct_c1_ndly => 2,
			inclk0_input_frequency => 6250,
			intended_device_family => "Cyclone IV E",
			operation_mode => "SOURCE_SYNCHRONOUS",
			scan_chain_mif_file => "ip/txpll/txpll.mif"
			)
PORT MAP(pll_inclk => MCLK1TX,
		 pll_areset => pllrst_start(0),
		 pll_logic_reset_n => fpga_reset_n,
		 inv_c0 => L,
		 rcnfg_clk => LMK_CLK,
		 rcnfig_areset => pllrst_start(0),
		 rcnfig_en => pllcfg_start(0),
		 dynps_areset_n => SYNTHESIZED_WIRE_0,
		 dynps_mode => pllcfg_phcfg_mode,
		 dynps_en => phcfg_start(0),
		 dynps_tst => pllcfg_phcfg_tst,
		 dynps_dir => phcfg_updn,
		 smpl_cmp_done => rx_path_smpl_cmp_done,
		 smpl_cmp_error => rx_path_smpl_cmp_err,
		 clk_ena => GDFX_TEMP_SIGNAL_0,
		 drct_clk_en => GDFX_TEMP_SIGNAL_1,
		 dynps_cnt_sel => cnt_ind(2 DOWNTO 0),
		 dynps_phase => cnt_phase(9 DOWNTO 0),
		 dynps_step_size => pllcfg_auto_phcfg_step(9 DOWNTO 0),
		 rcnfig_data => pllcfg_data,
		 c0 => fclk1,
		 pll_locked => mclk1tx_locked,
		 dynps_done => txpll_dynps_done,
		 dynps_status => txpll_dynps_status,
		 busy => txpllcfg_busy);



b2v_inst48 : rx_pll_top
GENERIC MAP(bandwidth_type => "AUTO",
			clk0_divide_by => 1,
			clk0_duty_cycle => 50,
			clk0_multiply_by => 1,
			clk0_phase_shift => "0",
			clk1_divide_by => 1,
			clk1_duty_cycle => 50,
			clk1_multiply_by => 1,
			clk1_phase_shift => "0",
			compensate_clock => "CLK1",
			drct_c0_ndly => 1,
			drct_c1_ndly => 2,
			inclk0_input_frequency => 6250,
			intended_device_family => "Cyclone IV E",
			operation_mode => "SOURCE_SYNCHRONOUS",
			scan_chain_mif_file => "ip/pll/pll.mif"
			)
PORT MAP(pll_inclk => MCLK2RX,
		 pll_areset => pllrst_start(1),
		 pll_logic_reset_n => fpga_reset_n,
		 inv_c0 => L,
		 rcnfg_clk => LMK_CLK,
		 rcnfig_areset => pllrst_start(1),
		 rcnfig_en => pllcfg_start(1),
		 dynps_mode => pllcfg_phcfg_mode,
		 dynps_areset_n => SYNTHESIZED_WIRE_1,
		 dynps_en => phcfg_start(1),
		 dynps_tst => pllcfg_phcfg_tst,
		 dynps_dir => phcfg_updn,
		 smpl_cmp_done => rx_path_smpl_cmp_done,
		 smpl_cmp_error => rx_path_smpl_cmp_err,
		 clk_ena => GDFX_TEMP_SIGNAL_2,
		 drct_clk_en => GDFX_TEMP_SIGNAL_3,
		 dynps_cnt_sel => cnt_ind(2 DOWNTO 0),
		 dynps_phase => cnt_phase(9 DOWNTO 0),
		 dynps_step_size => pllcfg_auto_phcfg_step(9 DOWNTO 0),
		 rcnfig_data => pllcfg_data,
		 c0 => MCLK2RX_pll,
		 pll_locked => rxpll_locked,
		 dynps_done => rxpll_dynps_done,
		 dynps_status => rxpll_dynps_status,
		 busy => rxpllcfg_busy);


SYNTHESIZED_WIRE_1 <= NOT(pllrst_start(1));



SYNTHESIZED_WIRE_0 <= NOT(pllrst_start(0));



b2v_inst9 : pllcfg_top
GENERIC MAP(n_pll => 2
			)
PORT MAP(sdinA => spi_lms_external_MOSI,
		 sclkA => spi_lms_external_SCLK,
		 senA => spi_enables(1),
		 lreset => fpga_reset_n,
		 mreset => fpga_reset_n,
		 auto_phcfg_done => GDFX_TEMP_SIGNAL_4,
		 auto_phcfg_err => GDFX_TEMP_SIGNAL_5,
		 pll_lock => GDFX_TEMP_SIGNAL_6,
		 pllcfg_busy => GDFX_TEMP_SIGNAL_7,
		 pllcfg_done => GDFX_TEMP_SIGNAL_8,
		 phcfg_mode => pllcfg_phcfg_mode,
		 phcfg_tst => pllcfg_phcfg_tst,
		 phcfg_updn => phcfg_updn,
		 auto_phcfg_step => pllcfg_auto_phcfg_step,
		 cnt_ind => cnt_ind,
		 cnt_phase => cnt_phase,
		 phcfg_start => phcfg_start,
		 pllcfg_data => pllcfg_data,
		 pllcfg_start => pllcfg_start,
		 pllrst_start => pllrst_start);

LMS_FCLK1 <= fclk1;
LMS_FCLK2 <= MCLK2RX_pll;

END bdf_type;