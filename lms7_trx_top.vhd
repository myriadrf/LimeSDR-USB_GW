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
-- CREATED		"Fri Jun  2 00:39:49 2017"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;



ENTITY lms7_trx_top IS 
GENERIC (dev_family : STRING := "Cyclone IV E";
		diq_width : INTEGER := 12;
		fx3_bus_width : INTEGER := 32;
		fx3_outfifo_rdsize : INTEGER := 13;
		fx3_outfifo_wrsize : INTEGER := 12;
		fx3_outfifo_wrwidth : INTEGER := 64
		);
	PORT
	(
		
	
		EXT_GND :  IN  STD_LOGIC;
		SI_CLK0 :  IN  STD_LOGIC;
		LMS_MCLK2 :  IN  STD_LOGIC;
		LMS_MCLK1 :  IN  STD_LOGIC;
		BRDG_SPI_FPGA_SS :  IN  STD_LOGIC;
		BRDG_SPI_SCLK :  IN  STD_LOGIC;
		BRDG_SPI_MOSI :  IN  std_logic;
		FX3_CTL4 :  IN  STD_LOGIC;
		FX3_CTL5 :  IN  STD_LOGIC;
		LM75_OS :  IN  STD_LOGIC;
		ADF_MUXOUT :  IN  STD_LOGIC;
		SI_CLK3 :  IN  STD_LOGIC;
		SI_CLK5 :  IN  STD_LOGIC;
		SI_CLK6 :  IN  STD_LOGIC;
		SI_CLK7 :  IN  STD_LOGIC;
		LMK_CLK :  IN  STD_LOGIC;
		SI_CLK2 :  IN  STD_LOGIC;
		SI_CLK1 :  IN  STD_LOGIC;
		FPGA_SPI0_MISO :  IN  STD_LOGIC;
		FX3_PCLK :  IN  STD_LOGIC;
		FX3_CTL8 :  IN  STD_LOGIC;
		PWR_SRC :  IN  STD_LOGIC;
		LMS_DIQ2_IQSEL2 :  IN  STD_LOGIC;
		FPGA_I2C_SCL :  INOUT  STD_LOGIC;
		FPGA_I2C_SDA :  INOUT  STD_LOGIC;
		BOM_VER :  IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		DDR2_1_clk :  INOUT  STD_LOGIC_VECTOR(0 TO 0);
		DDR2_1_clk_n :  INOUT  STD_LOGIC_VECTOR(0 TO 0);
		DDR2_1_dq :  INOUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
		DDR2_1_dqs :  INOUT  STD_LOGIC_VECTOR(1 DOWNTO 0);
		DDR2_2_clk :  INOUT  STD_LOGIC_VECTOR(0 TO 0);
		DDR2_2_clk_n :  INOUT  STD_LOGIC_VECTOR(0 TO 0);
		DDR2_2_dq :  INOUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
		DDR2_2_dqs :  INOUT  STD_LOGIC_VECTOR(1 DOWNTO 0);
		FPGA_GPIO :  INOUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		FX3_DQ :  INOUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		HW_VER :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		LMS_DIQ2_D :  IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
		LMS_RESET :  OUT  STD_LOGIC;
		FPGA_LED1_R :  OUT  STD_LOGIC;
		FPGA_LED1_G :  OUT  STD_LOGIC;
		FPGA_LED2_G :  OUT  STD_LOGIC;
		FPGA_LED2_R :  OUT  STD_LOGIC;
		BRDG_SPI_MISO :  OUT  STD_LOGIC;
		LMS_DIQ1_IQSEL :  OUT  STD_LOGIC;
		FX3_CTL0 :  OUT  STD_LOGIC;
		FX3_CTL7 :  OUT  STD_LOGIC;
		FX3_CTL1 :  OUT  STD_LOGIC;
		FX3_CTL2 :  OUT  STD_LOGIC;
		FX3_CTL3 :  OUT  STD_LOGIC;
		FPGA_SPI1_SCLK :  OUT  STD_LOGIC;
		FPGA_SPI1_MOSI :  OUT  STD_LOGIC;
		FPGA_SPI1_DAC_SS :  OUT  STD_LOGIC;
		FPGA_SPI1_ADF_SS :  OUT  STD_LOGIC;
		DDR2_1_ras_n :  OUT  STD_LOGIC;
		DDR2_1_cas_n :  OUT  STD_LOGIC;
		DDR2_1_we_n :  OUT  STD_LOGIC;
		TX2_2_LB_L :  OUT  STD_LOGIC;
		TX2_2_LB_H :  OUT  STD_LOGIC;
		TX2_2_LB_AT :  OUT  STD_LOGIC;
		TX2_2_LB_SH :  OUT  STD_LOGIC;
		TX1_2_LB_L :  OUT  STD_LOGIC;
		TX1_2_LB_H :  OUT  STD_LOGIC;
		TX1_2_LB_AT :  OUT  STD_LOGIC;
		TX1_2_LB_SH :  OUT  STD_LOGIC;
		FX3_LED_G :  OUT  STD_LOGIC;
		FX3_LED_R :  OUT  STD_LOGIC;
		DDR2_2_ras_n :  OUT  STD_LOGIC;
		DDR2_2_cas_n :  OUT  STD_LOGIC;
		DDR2_2_we_n :  OUT  STD_LOGIC;
		FX3_CTL12 :  OUT  STD_LOGIC;
		FX3_CTL11 :  OUT  STD_LOGIC;
		FPGA_SPI0_SCLK :  OUT  STD_LOGIC;
		FPGA_SPI0_MOSI :  OUT  STD_LOGIC;
		FPGA_SPI0_LMS_SS :  OUT  STD_LOGIC;
		LMS_FCLK2 :  OUT  STD_LOGIC;
		LMS_FCLK1 :  OUT  STD_LOGIC;
		FAN_CTRL :  OUT  STD_LOGIC;
		LMS_TXEN :  OUT  STD_LOGIC;
		LMS_RXEN :  OUT  STD_LOGIC;
		LMS_CORE_LDO_EN :  OUT  STD_LOGIC;
		LMS_TXNRX1 :  OUT  STD_LOGIC;
		LMS_TXNRX2 :  OUT  STD_LOGIC;
		DDR2_1_addr :  OUT  STD_LOGIC_VECTOR(12 DOWNTO 0);
		DDR2_1_ba :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0);
		DDR2_1_cke :  OUT  STD_LOGIC_VECTOR(0 TO 0);
		DDR2_1_cs_n :  OUT  STD_LOGIC_VECTOR(0 TO 0);
		DDR2_1_dm :  OUT  STD_LOGIC_VECTOR(1 DOWNTO 0);
		DDR2_1_odt :  OUT  STD_LOGIC_VECTOR(0 TO 0);
		DDR2_2_addr :  OUT  STD_LOGIC_VECTOR(12 DOWNTO 0);
		DDR2_2_ba :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0);
		DDR2_2_cke :  OUT  STD_LOGIC_VECTOR(0 TO 0);
		DDR2_2_cs_n :  OUT  STD_LOGIC_VECTOR(0 TO 0);
		DDR2_2_dm :  OUT  STD_LOGIC_VECTOR(1 DOWNTO 0);
		DDR2_2_odt :  OUT  STD_LOGIC_VECTOR(0 TO 0);
		LMS_DIQ1_D :  OUT  STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END lms7_trx_top;

ARCHITECTURE bdf_type OF lms7_trx_top IS 


COMPONENT stream_switch
GENERIC (data_width : INTEGER;
			wfm_fifo_wrusedw_size : INTEGER;
			wfm_limit : INTEGER
			);
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 data_in_valid : IN STD_LOGIC;
		 dest_sel : IN STD_LOGIC;
		 tx_fifo_rdy : IN STD_LOGIC;
		 wfm_rdy : IN STD_LOGIC;
		 data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wfm_fifo_wrusedw : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 data_in_rdy : OUT STD_LOGIC;
		 tx_fifo_wr : OUT STD_LOGIC;
		 wfm_fifo_wr : OUT STD_LOGIC;
		 tx_fifo_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wfm_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT rstn_pulse
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 resetn_in : IN STD_LOGIC;
		 rstn_pulse_out : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT txiqmux
GENERIC (diq_width : INTEGER
			);
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 test_ptrn_en : IN STD_LOGIC;
		 test_ptrn_fidm : IN STD_LOGIC;
		 test_data_en : IN STD_LOGIC;
		 test_data_mimo_en : IN STD_LOGIC;
		 mux_sel : IN STD_LOGIC;
		 test_ptrn_I : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 test_ptrn_Q : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 tx_diq_h : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		 tx_diq_l : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		 wfm_diq_h : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		 wfm_diq_l : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		 diq_h : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		 diq_l : OUT STD_LOGIC_VECTOR(12 DOWNTO 0)
	);
END COMPONENT;

COMPONENT busy_delay
GENERIC (clock_period : INTEGER;
			delay_time : INTEGER
			);
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 busy_in : IN STD_LOGIC;
		 busy_out : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT fpga_led2_ctrl
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 adf_muxout : IN STD_LOGIC;
		 dac_ss : IN STD_LOGIC;
		 adf_ss : IN STD_LOGIC;
		 led_ctrl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 led_g : OUT STD_LOGIC;
		 led_r : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT opndrn
	PORT(A_IN : IN STD_LOGIC;
		 A_OUT : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT periphcfg
	PORT(mimo_en : IN STD_LOGIC;
		 sdin : IN STD_LOGIC;
		 sclk : IN STD_LOGIC;
		 sen : IN STD_LOGIC;
		 lreset : IN STD_LOGIC;
		 mreset : IN STD_LOGIC;
		 BOARD_GPIO_RD : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 maddress : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 PERIPH_INPUT_RD_0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 PERIPH_INPUT_RD_1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 sdout : OUT STD_LOGIC;
		 oen : OUT STD_LOGIC;
		 BOARD_GPIO_DIR : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 BOARD_GPIO_OVRD : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 BOARD_GPIO_VAL : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 PERIPH_OUTPUT_OVRD_0 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 PERIPH_OUTPUT_OVRD_1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 PERIPH_OUTPUT_VAL_0 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 PERIPH_OUTPUT_VAL_1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 stateo : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
	);
END COMPONENT;

COMPONENT miso_mux
	PORT(fpga_miso : IN STD_LOGIC;
		 ext_miso : IN STD_LOGIC;
		 fpga_cs : IN STD_LOGIC;
		 ext_cs : IN STD_LOGIC;
		 out_miso : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT gpio_ctrl_top
GENERIC (bus_width : INTEGER
			);
	PORT(dir_0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 dir_1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 gpio : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 mux_sel : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 out_val_0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 out_val_1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 gpio_in : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT rx_synchronizers
	PORT(clk1 : IN STD_LOGIC;
		 clk1_reset_n : IN STD_LOGIC;
		 clk1_d0 : IN STD_LOGIC;
		 clk1_d1 : IN STD_LOGIC;
		 clk1_s0 : OUT STD_LOGIC;
		 clk1_s1 : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT fx3_led_ctrl
	PORT(ctrl_led_g : IN STD_LOGIC;
		 ctrl_led_r : IN STD_LOGIC;
		 HW_VER : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 led_ctrl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 led_g : OUT STD_LOGIC;
		 led_r : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT fpgacfg
	PORT(mimo_en : IN STD_LOGIC;
		 sdin : IN STD_LOGIC;
		 sclk : IN STD_LOGIC;
		 sen : IN STD_LOGIC;
		 lreset : IN STD_LOGIC;
		 mreset : IN STD_LOGIC;
		 PWR_SRC : IN STD_LOGIC;
		 BOM_VER : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 HW_VER : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 maddress : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 sdout : OUT STD_LOGIC;
		 oen : OUT STD_LOGIC;
		 load_phase_reg : OUT STD_LOGIC;
		 mimo_int_en : OUT STD_LOGIC;
		 synch_dis : OUT STD_LOGIC;
		 smpl_nr_clr : OUT STD_LOGIC;
		 txpct_loss_clr : OUT STD_LOGIC;
		 rx_en : OUT STD_LOGIC;
		 tx_en : OUT STD_LOGIC;
		 rx_ptrn_en : OUT STD_LOGIC;
		 tx_ptrn_en : OUT STD_LOGIC;
		 tx_cnt_en : OUT STD_LOGIC;
		 wfm_play : OUT STD_LOGIC;
		 wfm_load : OUT STD_LOGIC;
		 LMS1_SS : OUT STD_LOGIC;
		 LMS1_RESET : OUT STD_LOGIC;
		 LMS1_CORE_LDO_EN : OUT STD_LOGIC;
		 LMS1_TXNRX1 : OUT STD_LOGIC;
		 LMS1_TXNRX2 : OUT STD_LOGIC;
		 LMS1_TXEN : OUT STD_LOGIC;
		 LMS1_RXEN : OUT STD_LOGIC;
		 ch_en : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 clk_ind : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 cnt_ind : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 drct_clk_en : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 FCLK_ENA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 FPGA_LED1_CTRL : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 FPGA_LED2_CTRL : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 FX3_LED_CTRL : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 GPIO : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 phase_reg_sel : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 smpl_width : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 SPI_SS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 stateo : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		 wfm_ch_en : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 wfm_smpl_width : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT wfm_player_top
GENERIC (addr_size : INTEGER;
			cmd_fifo_size : INTEGER;
			cntrl_bus_size : INTEGER;
			cntrl_rate : INTEGER;
			data_width : INTEGER;
			dcmpr_fifo_size : INTEGER;
			dev_family : STRING;
			iq_width : INTEGER;
			lcl_burst_length : INTEGER;
			lcl_bus_size : INTEGER;
			wfm_infifo_size : INTEGER;
			wfm_outfifo_size : INTEGER
			);
	PORT(reset_n : IN STD_LOGIC;
		 ddr2_pll_ref_clk : IN STD_LOGIC;
		 wcmd_clk : IN STD_LOGIC;
		 rcmd_clk : IN STD_LOGIC;
		 wfm_load : IN STD_LOGIC;
		 wfm_play_stop : IN STD_LOGIC;
		 wfm_wr : IN STD_LOGIC;
		 fr_start : IN STD_LOGIC;
		 mimo_en : IN STD_LOGIC;
		 iq_clk : IN STD_LOGIC;
		 begin_test : IN STD_LOGIC;
		 insert_error : IN STD_LOGIC;
		 ch_en : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 mem_clk : INOUT STD_LOGIC_VECTOR(0 TO 0);
		 mem_clk_n : INOUT STD_LOGIC_VECTOR(0 TO 0);
		 mem_dq : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 mem_dqs : INOUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 sample_width : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 wfm_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wfm_rdy : OUT STD_LOGIC;
		 mem_ras_n : OUT STD_LOGIC;
		 mem_cas_n : OUT STD_LOGIC;
		 mem_we_n : OUT STD_LOGIC;
		 phy_clk : OUT STD_LOGIC;
		 pass : OUT STD_LOGIC;
		 fail : OUT STD_LOGIC;
		 test_complete : OUT STD_LOGIC;
		 dd_iq_h : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 dd_iq_l : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 mem_addr : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		 mem_ba : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 mem_cke : OUT STD_LOGIC_VECTOR(0 TO 0);
		 mem_cs_n : OUT STD_LOGIC_VECTOR(0 TO 0);
		 mem_dm : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 mem_odt : OUT STD_LOGIC_VECTOR(0 TO 0);
		 pnf_per_bit : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 pnf_per_bit_persist : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wfm_infifo_wrusedw : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END COMPONENT;

COMPONENT fpga_led1_cntrl
	PORT(pll1_locked : IN STD_LOGIC;
		 pll2_locked : IN STD_LOGIC;
		 alive : IN STD_LOGIC;
		 led_ctrl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 led_g : OUT STD_LOGIC;
		 led_r : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT clock_test
	PORT(FX3_clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 Si5351C_clk_0 : IN STD_LOGIC;
		 Si5351C_clk_1 : IN STD_LOGIC;
		 Si5351C_clk_2 : IN STD_LOGIC;
		 Si5351C_clk_3 : IN STD_LOGIC;
		 Si5351C_clk_5 : IN STD_LOGIC;
		 Si5351C_clk_6 : IN STD_LOGIC;
		 Si5351C_clk_7 : IN STD_LOGIC;
		 LMK_CLK : IN STD_LOGIC;
		 ADF_MUXOUT : IN STD_LOGIC;
		 test_en : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 test_frc_err : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 ADF_MUXOUT_cnt : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 FX3_clk_cnt : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 LMK_CLK_cnt : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
		 Si5351C_clk_0_cnt : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 Si5351C_clk_1_cnt : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 Si5351C_clk_2_cnt : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 Si5351C_clk_3_cnt : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 Si5351C_clk_5_cnt : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 Si5351C_clk_6_cnt : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 Si5351C_clk_7_cnt : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 test_cmplt : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 test_rez : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pll_block_rx
	PORT(pll_inclk0 : IN STD_LOGIC;
		 pll_areset : IN STD_LOGIC;
		 clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 phase_ps_en : IN STD_LOGIC;
		 phase_up_dn : IN STD_LOGIC;
		 reconfig_en : IN STD_LOGIC;
		 drct_clk_en : IN STD_LOGIC;
		 FCLK_ENA : IN STD_LOGIC;
		 phase : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 phase_cnt_sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 reconfig_data : IN STD_LOGIC_VECTOR(143 DOWNTO 0);
		 c0 : OUT STD_LOGIC;
		 c1 : OUT STD_LOGIC;
		 pll_locked : OUT STD_LOGIC;
		 reconfig_status : OUT STD_LOGIC;
		 cfg_busy : OUT STD_LOGIC;
		 pll_inclk0_dly : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT pll_block_tx
	PORT(pll_inclk0 : IN STD_LOGIC;
		 pll_areset : IN STD_LOGIC;
		 clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 phase_ps_en : IN STD_LOGIC;
		 phase_up_dn : IN STD_LOGIC;
		 reconfig_en : IN STD_LOGIC;
		 drct_clk_en : IN STD_LOGIC;
		 FCLK_ENA : IN STD_LOGIC;
		 phase : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 phase_cnt_sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 reconfig_data : IN STD_LOGIC_VECTOR(143 DOWNTO 0);
		 c0 : OUT STD_LOGIC;
		 c1 : OUT STD_LOGIC;
		 pll_locked : OUT STD_LOGIC;
		 reconfig_status : OUT STD_LOGIC;
		 cfg_busy : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT lte_tx_path
GENERIC (dev_family : STRING
			);
	PORT(RX_clk : IN STD_LOGIC;
		 rxpll_locked : IN STD_LOGIC;
		 TX_clk : IN STD_LOGIC;
		 txpll_locked : IN STD_LOGIC;
		 pct_wrclk : IN STD_LOGIC;
		 pct_wr : IN STD_LOGIC;
		 rxpath_wr : IN STD_LOGIC;
		 stream_rxen : IN STD_LOGIC;
		 lte_synch_dis : IN STD_LOGIC;
		 lte_mimo_en : IN STD_LOGIC;
		 lte_clr_smpl_nr : IN STD_LOGIC;
		 fr_start : IN STD_LOGIC;
		 rx_cap_en : IN STD_LOGIC;
		 tx_reset_req : IN STD_LOGIC;
		 lte_ch_en : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 lte_smpl_width : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 pct_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 pct_fifo_rdy : OUT STD_LOGIC;
		 pct_cleared : OUT STD_LOGIC;
		 dd_data_h : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		 dd_data_l : OUT STD_LOGIC_VECTOR(12 DOWNTO 0)
	);
END COMPONENT;

COMPONENT rx_path
GENERIC (dev_family : STRING;
			diq_width : INTEGER;
			infifo_wrsize : INTEGER;
			outfifo_size : INTEGER
			);
	PORT(clk_iopll : IN STD_LOGIC;
		 clk_iodirect : IN STD_LOGIC;
		 clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 en : IN STD_LOGIC;
		 DIQ2_IQSEL2 : IN STD_LOGIC;
		 drct_clk_en : IN STD_LOGIC;
		 data_src : IN STD_LOGIC;
		 fr_start : IN STD_LOGIC;
		 mimo_en : IN STD_LOGIC;
		 pct_clr_detect : IN STD_LOGIC;
		 clr_pct_loss_flag : IN STD_LOGIC;
		 clr_smpl_nr : IN STD_LOGIC;
		 outfifo_full : IN STD_LOGIC;
		 ch_en : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 DIQ2 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 outfifo_wrusedw : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 smpl_width : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 outfifo_wr : OUT STD_LOGIC;
		 wrrxfifo_wr : OUT STD_LOGIC;
		 outfifo_data : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
	);
END COMPONENT;

COMPONENT tstcfg
	PORT(mimo_en : IN STD_LOGIC;
		 sdin : IN STD_LOGIC;
		 sclk : IN STD_LOGIC;
		 sen : IN STD_LOGIC;
		 lreset : IN STD_LOGIC;
		 mreset : IN STD_LOGIC;
		 ADF_CNT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 DDR2_1_pnf_per_bit : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 DDR2_1_STATUS : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 DDR2_2_pnf_per_bit : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 DDR2_2_STATUS : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 FX3_CLK_CNT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 LMK_CLK_CNT : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		 maddress : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 Si5351C_CLK0_CNT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 Si5351C_CLK1_CNT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 Si5351C_CLK2_CNT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 Si5351C_CLK3_CNT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 Si5351C_CLK5_CNT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 Si5351C_CLK6_CNT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 Si5351C_CLK7_CNT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 TEST_CMPLT : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 TEST_REZ : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 sdout : OUT STD_LOGIC;
		 oen : OUT STD_LOGIC;
		 stateo : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		 TEST_EN : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		 TEST_FRC_ERR : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		 TX_TST_I : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 TX_TST_Q : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT alive
	PORT(rst : IN STD_LOGIC;
		 clk : IN STD_LOGIC;
		 beat : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT fx3_slavefifo5b_top
GENERIC (data_width : INTEGER;
			dev_family : STRING;
			EP01_rwidth : INTEGER;
			EP0F_rwidth : INTEGER;
			EP81_wrusedw_width : INTEGER;
			EP81_wwidth : INTEGER;
			EP8F_wwidth : INTEGER
			);
	PORT(reset_n : IN STD_LOGIC;
		 clk : IN STD_LOGIC;
		 usb_speed : IN STD_LOGIC;
		 flaga : IN STD_LOGIC;
		 flagb : IN STD_LOGIC;
		 flagc : IN STD_LOGIC;
		 flagd : IN STD_LOGIC;
		 EP01_rdclk : IN STD_LOGIC;
		 EP01_rd : IN STD_LOGIC;
		 ext_buff_rdy : IN STD_LOGIC;
		 EP81_wclk : IN STD_LOGIC;
		 EP81_aclrn : IN STD_LOGIC;
		 EP81_wr : IN STD_LOGIC;
		 EP0F_rdclk : IN STD_LOGIC;
		 EP0F_rd : IN STD_LOGIC;
		 EP8F_wclk : IN STD_LOGIC;
		 EP8F_aclrn : IN STD_LOGIC;
		 EP8F_wr : IN STD_LOGIC;
		 EP81_wdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
		 EP8F_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 fdata : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 clk_out : OUT STD_LOGIC;
		 slcs : OUT STD_LOGIC;
		 slrd : OUT STD_LOGIC;
		 sloe : OUT STD_LOGIC;
		 slwr : OUT STD_LOGIC;
		 pktend : OUT STD_LOGIC;
		 EPSWITCH : OUT STD_LOGIC;
		 EP01_rempty : OUT STD_LOGIC;
		 ext_buff_wr : OUT STD_LOGIC;
		 EP81_wfull : OUT STD_LOGIC;
		 EP0F_rempty : OUT STD_LOGIC;
		 EP8F_wfull : OUT STD_LOGIC;
		 GPIF_busy : OUT STD_LOGIC;
		 EP01_rdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
		 EP0F_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 EP81_wrusedw : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		 ext_buff_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 faddr : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

--COMPONENT nios_cpu
--	PORT(clk100 : IN STD_LOGIC;
--		 exfifo_if_rdempty : IN STD_LOGIC;
--		 exfifo_of_wrfull : IN STD_LOGIC;
--		 spi_lms_MISO : IN STD_LOGIC;
--		 i2c_scl : INOUT STD_LOGIC;
--		 i2c_sda : INOUT STD_LOGIC;
--		 exfifo_if_d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
--		 switch : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--		 exfifo_if_rd : OUT STD_LOGIC;
--		 exfifo_of_wr : OUT STD_LOGIC;
--		 exfifo_rst : OUT STD_LOGIC;
--		 spi_lms_MOSI : OUT STD_LOGIC;
--		 spi_lms_SCLK : OUT STD_LOGIC;
--		 spi_1_MOSI : OUT STD_LOGIC;
--		 spi_1_SCLK : OUT STD_LOGIC;
--		 exfifo_of_d : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
--		 leds : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
--		 lms_ctr_gpio : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
--		 spi_1_SS_n : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
--		 spi_lms_SS_n : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
--	);
--END COMPONENT;

component soc_wrapper
	generic(cpu_name : string := "orca");
	port(
		clk100            : in    std_logic;
		exfifo_if_d       : in    std_logic_vector(31 downto 0);
		exfifo_if_rd      : out   std_logic;
		exfifo_if_rdempty : in    std_logic;
		exfifo_of_d       : out   std_logic_vector(31 downto 0);
		exfifo_of_wr      : out   std_logic;
		exfifo_of_wrfull  : in    std_logic;
		exfifo_rst        : out   std_logic;
		leds              : out   std_logic_vector(7 downto 0);
		lms_ctr_gpio      : out   std_logic_vector(3 downto 0);
		spi_lms_MISO      : in    std_logic;
		spi_lms_MOSI      : out   std_logic;
		spi_lms_SCLK      : out   std_logic;
		spi_lms_SS_n      : out   std_logic_vector(4 downto 0);
		spi_1_MOSI        : out   std_logic;
		spi_1_SCLK        : out   std_logic;
		spi_1_SS_n        : out   std_logic_vector(1 downto 0);
		switch            : in    std_logic_vector(7 downto 0);
		i2c_scl           : inout std_logic;
		i2c_sda           : inout std_logic
	);
end component soc_wrapper;

COMPONENT ddr2_tester
	PORT(global_reset_n : IN STD_LOGIC;
		 pll_ref_clk : IN STD_LOGIC;
		 soft_reset_n : IN STD_LOGIC;
		 begin_test : IN STD_LOGIC;
		 insert_error : IN STD_LOGIC;
		 mem_clk : INOUT STD_LOGIC_VECTOR(0 TO 0);
		 mem_clk_n : INOUT STD_LOGIC_VECTOR(0 TO 0);
		 mem_dq : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 mem_dqs : INOUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 mem_ras_n : OUT STD_LOGIC;
		 mem_cas_n : OUT STD_LOGIC;
		 mem_we_n : OUT STD_LOGIC;
		 pass : OUT STD_LOGIC;
		 fail : OUT STD_LOGIC;
		 test_complete : OUT STD_LOGIC;
		 mem_addr : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		 mem_ba : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 mem_cke : OUT STD_LOGIC_VECTOR(0 TO 0);
		 mem_cs_n : OUT STD_LOGIC_VECTOR(0 TO 0);
		 mem_dm : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 mem_odt : OUT STD_LOGIC_VECTOR(0 TO 0);
		 pnf_per_bit : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 pnf_per_bit_persist : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT synchronizer
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 signal_in : IN STD_LOGIC;
		 signal_sinch : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT lms7002_ddout
GENERIC (dev_family : STRING;
			iq_width : INTEGER
			);
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 data_in_h : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		 data_in_l : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		 txiqsel : OUT STD_LOGIC;
		 txiq : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
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
		 pll_lock : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 pllcfg_busy : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 pllcfg_done : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 sdoutA : OUT STD_LOGIC;
		 oenA : OUT STD_LOGIC;
		 sdoutB : OUT STD_LOGIC;
		 oenB : OUT STD_LOGIC;
		 phcfg_updn : OUT STD_LOGIC;
		 cnt_ind : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 cnt_phase : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 phcfg_start : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 pllcfg_data : OUT STD_LOGIC_VECTOR(143 DOWNTO 0);
		 pllcfg_start : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 pllrst_start : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	BOARD_GPIO_DIR :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	BOARD_GPIO_OVRD :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	BOARD_GPIO_RD :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	BOARD_GPIO_VAL :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	clk_fpga2 :  STD_LOGIC;
SIGNAL	clk_ind :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	clk_test_cmplt :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	clk_test_rez :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	cnt_ind :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	cnt_phase :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	ctr_LMS_SPI_CS :  STD_LOGIC;
SIGNAL	dd_iq_h :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	dd_iq_l :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	ddmux_h :  STD_LOGIC_VECTOR(12 DOWNTO 0);
SIGNAL	ddmux_l :  STD_LOGIC_VECTOR(12 DOWNTO 0);
SIGNAL	ddr2_1_phy_clk :  STD_LOGIC;
SIGNAL	ddr2_1_pnf_per_bit_persisit :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ddr2_1_test_complete :  STD_LOGIC;
SIGNAL	ddr2_1_test_fail :  STD_LOGIC;
SIGNAL	ddr2_1_test_pass :  STD_LOGIC;
SIGNAL	ddr2_2_pnf_per_bit_persisit :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ddr2_2_test_complete :  STD_LOGIC;
SIGNAL	ddr2_2_test_fail :  STD_LOGIC;
SIGNAL	ddr2_2_test_pass :  STD_LOGIC;
SIGNAL	drc_clk_en :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	EP01_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	EP01_data_valid :  STD_LOGIC;
SIGNAL	exfifo_if_d :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	exfifo_if_rd :  STD_LOGIC;
SIGNAL	exfifo_if_rdempty :  STD_LOGIC;
SIGNAL	exfifo_of_d :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	exfifo_of_wr :  STD_LOGIC;
SIGNAL	exfifo_of_wrfull :  STD_LOGIC;
SIGNAL	exfifo_rst :  STD_LOGIC;
SIGNAL	fadr :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	FCLK_ENA :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	fpga_alive :  STD_LOGIC;
SIGNAL	fpga_internal_spi :  STD_LOGIC;
SIGNAL	FPGA_LED1_CTRL_s :  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	FPGA_LED2_CTRL_s :  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	fpga_reset :  STD_LOGIC;
SIGNAL	fpga_reset_n :  STD_LOGIC;
SIGNAL	FPGA_SPI1_SCLK_ALTERA_SYNTHESIZED :  STD_LOGIC;
SIGNAL	fpgapll_locked :  STD_LOGIC;
SIGNAL	FX3_busy :  STD_LOGIC;
SIGNAL	fx3_clk :  STD_LOGIC;
SIGNAL	FX3_LED_CTRL_s :  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	FX3_MCU_BUSY :  STD_LOGIC;
SIGNAL	fx3_outfifo_wfull :  STD_LOGIC;
SIGNAL	fx3_outfifo_wrusedw :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	FX3_slave_busy :  STD_LOGIC;
SIGNAL	GPIO :  STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL	H :  STD_LOGIC;
SIGNAL	internal_spi_miso :  STD_LOGIC;
SIGNAL	L :  STD_LOGIC;
SIGNAL	lmlclk :  STD_LOGIC;
SIGNAL	lms1_reset :  STD_LOGIC;
SIGNAL	lms_ctr_gpio :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	load_phase_reg :  STD_LOGIC;
SIGNAL	lte_ch_en :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	lte_clr_smpl_nr :  STD_LOGIC;
SIGNAL	lte_mimo_en :  STD_LOGIC;
SIGNAL	lte_mimo_en_mclk2rxpll :  STD_LOGIC;
SIGNAL	lte_smpl_width :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	lte_synch_dis :  STD_LOGIC;
SIGNAL	lte_txpct_loss_clr :  STD_LOGIC;
SIGNAL	MCLK1TX :  STD_LOGIC;
SIGNAL	mclk1tx_locked :  STD_LOGIC;
SIGNAL	MCLK2RX :  STD_LOGIC;
SIGNAL	MCLK2RX_dly :  STD_LOGIC;
SIGNAL	MCLK2RX_pll :  STD_LOGIC;
SIGNAL	MCLK2RX_pll_d :  STD_LOGIC;
SIGNAL	mux_spi_miso :  STD_LOGIC;
SIGNAL	nios_leds :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	pct_buff_aclr :  STD_LOGIC;
SIGNAL	PERIPH_OUTPUT_OVRD_0 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	PERIPH_OUTPUT_VAL_0 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	periphcfg_sdout :  STD_LOGIC;
SIGNAL	phase_reg_sel :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	phcfg_start :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	phcfg_updn :  STD_LOGIC;
SIGNAL	pllcfg_busy :  STD_LOGIC;
SIGNAL	pllcfg_data :  STD_LOGIC_VECTOR(143 DOWNTO 0);
SIGNAL	pllcfg_done :  STD_LOGIC;
SIGNAL	pllcfg_oenA :  STD_LOGIC;
SIGNAL	pllcfg_sdoutA :  STD_LOGIC;
SIGNAL	pllcfg_start :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	pllrst_start :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	rx_pct_data :  STD_LOGIC_VECTOR(63 DOWNTO 0);
SIGNAL	rx_ptrn_en :  STD_LOGIC;
SIGNAL	rx_reconfig_status :  STD_LOGIC;
SIGNAL	rxpct_outfifowr :  STD_LOGIC;
SIGNAL	rxpll_locked :  STD_LOGIC;
SIGNAL	rxpllcfg_busy :  STD_LOGIC;
SIGNAL	spi_1_enables :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	spi_enables :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	spi_lms_external_MOSI :  STD_LOGIC;
SIGNAL	spi_lms_external_SCLK :  STD_LOGIC;
SIGNAL	spi_lms_miso :  STD_LOGIC;
SIGNAL	SPI_SS :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	stream_rxen :  STD_LOGIC;
SIGNAL	stream_rxen_fx3clk :  STD_LOGIC;
SIGNAL	stream_rxen_fx3clk_pulse :  STD_LOGIC;
SIGNAL	stream_rxen_mclk2rxpll :  STD_LOGIC;
SIGNAL	stream_sw_rdy :  STD_LOGIC;
SIGNAL	stream_txen :  STD_LOGIC;
SIGNAL	test_en :  STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL	test_inject_error :  STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL	tstcfg_sdout :  STD_LOGIC;
SIGNAL	tx_cnt_en :  STD_LOGIC;
SIGNAL	tx_outfifo_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	tx_outfifo_rdy :  STD_LOGIC;
SIGNAL	tx_outfifo_rdy_fx3_clk :  STD_LOGIC;
SIGNAL	tx_outfifo_wrreq :  STD_LOGIC;
SIGNAL	tx_path_h :  STD_LOGIC_VECTOR(12 DOWNTO 0);
SIGNAL	tx_path_l :  STD_LOGIC_VECTOR(12 DOWNTO 0);
SIGNAL	tx_ptrn_en :  STD_LOGIC;
SIGNAL	tx_reconfig_status :  STD_LOGIC;
SIGNAL	TX_TST_I :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	TX_TST_Q :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	txiq :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	txiqsel :  STD_LOGIC;
SIGNAL	txpllcfg_busy :  STD_LOGIC;
SIGNAL	wfm_ch_en :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	wfm_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	wfm_load :  STD_LOGIC;
SIGNAL	wfm_play :  STD_LOGIC;
SIGNAL	wfm_player_rdy :  STD_LOGIC;
SIGNAL	wfm_player_wrusedw :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	wfm_smpl_width :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	wfm_wr :  STD_LOGIC;
SIGNAL	wrrxfifo_wr :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(0 TO 15);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC_VECTOR(0 TO 9);
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_12 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC;

SIGNAL	GDFX_TEMP_SIGNAL_2 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_1 :  STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_3 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_4 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_0 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_10 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_6 :  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_8 :  STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_9 :  STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_5 :  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_7 :  STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_13 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_12 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_11 :  STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN 
SYNTHESIZED_WIRE_1 <= "0000000000000000";
SYNTHESIZED_WIRE_3 <= "0000000000";

GDFX_TEMP_SIGNAL_2 <= (L & L & L & L & L & L & L & L & L & L & L & L & L & L & L & LM75_OS);
GDFX_TEMP_SIGNAL_1 <= (L & L & L & L & L & L & L & H & H & L);
GDFX_TEMP_SIGNAL_3 <= (H & H & H & H & H & H & H & H);
GDFX_TEMP_SIGNAL_4 <= (L & L & L & L & pct_buff_aclr & L & mclk1tx_locked & rxpll_locked);
GDFX_TEMP_SIGNAL_0 <= (L & L & L & L & L & L & L & L & BOARD_GPIO_RD(7 DOWNTO 0));
GDFX_TEMP_SIGNAL_10 <= (L & L & L & L & L & L & L & L);
GDFX_TEMP_SIGNAL_6 <= (ddr2_2_test_fail & ddr2_2_test_pass & ddr2_2_test_complete);
GDFX_TEMP_SIGNAL_8 <= (ddr2_2_test_complete & ddr2_1_test_complete & clk_test_cmplt(3 DOWNTO 0));
GDFX_TEMP_SIGNAL_9 <= (ddr2_2_test_pass & ddr2_1_test_pass & clk_test_rez(3 DOWNTO 0));
GDFX_TEMP_SIGNAL_5 <= (ddr2_1_test_fail & ddr2_1_test_pass & ddr2_1_test_complete);
GDFX_TEMP_SIGNAL_7 <= (L & L & L & L & L & L & L & L & H & H);
GDFX_TEMP_SIGNAL_13 <= (H & pllcfg_done);
GDFX_TEMP_SIGNAL_12 <= (L & pllcfg_busy);
GDFX_TEMP_SIGNAL_11 <= (rxpll_locked & mclk1tx_locked);


b2v_inst : stream_switch
GENERIC MAP(data_width => 32,
			wfm_fifo_wrusedw_size => 12,
			wfm_limit => 4096
			)
PORT MAP(clk => fx3_clk,
		 reset_n => fpga_reset_n,
		 data_in_valid => EP01_data_valid,
		 dest_sel => wfm_load,
		 tx_fifo_rdy => tx_outfifo_rdy,
		 wfm_rdy => wfm_player_rdy,
		 data_in => EP01_data,
		 wfm_fifo_wrusedw => wfm_player_wrusedw,
		 data_in_rdy => stream_sw_rdy,
		 tx_fifo_wr => tx_outfifo_wrreq,
		 wfm_fifo_wr => wfm_wr,
		 tx_fifo_data => tx_outfifo_data,
		 wfm_data => wfm_data);


b2v_inst1 : rstn_pulse
PORT MAP(clk => fx3_clk,
		 reset_n => fpgapll_locked,
		 resetn_in => stream_rxen_fx3clk);


b2v_inst10 : txiqmux
GENERIC MAP(diq_width => 12
			)
PORT MAP(clk => lmlclk,
		 reset_n => mclk1tx_locked,
		 test_ptrn_en => tx_ptrn_en,
		 test_ptrn_fidm => L,
		 test_data_en => tx_cnt_en,
		 test_data_mimo_en => H,
		 mux_sel => wfm_play,
		 test_ptrn_I => TX_TST_I,
		 test_ptrn_Q => TX_TST_Q,
		 tx_diq_h => tx_path_h,
		 tx_diq_l => tx_path_l,
		 wfm_diq_h => dd_iq_h(12 DOWNTO 0),
		 wfm_diq_l => dd_iq_l(12 DOWNTO 0),
		 diq_h => ddmux_h,
		 diq_l => ddmux_l);


b2v_inst11 : busy_delay
GENERIC MAP(clock_period => 10,
			delay_time => 200
			)
PORT MAP(clk => fx3_clk,
		 reset_n => fpga_reset_n,
		 busy_in => SYNTHESIZED_WIRE_0,
		 busy_out => FX3_busy);


pllcfg_busy <= txpllcfg_busy OR rxpllcfg_busy;


LMS_RESET <= lms1_reset AND lms_ctr_gpio(0);


pllcfg_done <= NOT(pllcfg_busy);



b2v_inst15 : fpga_led2_ctrl
PORT MAP(clk => FPGA_SPI1_SCLK_ALTERA_SYNTHESIZED,
		 reset_n => fpga_reset_n,
		 adf_muxout => ADF_MUXOUT,
		 dac_ss => spi_1_enables(0),
		 adf_ss => spi_1_enables(1),
		 led_ctrl => FPGA_LED2_CTRL_s,
		 led_g => FPGA_LED2_G,
		 led_r => FPGA_LED2_R);


b2v_inst16 : opndrn
PORT MAP(A_IN => spi_1_enables(0),
		 A_OUT => FPGA_SPI1_DAC_SS);


b2v_inst17 : periphcfg
PORT MAP(mimo_en => H,
		 sdin => spi_lms_external_MOSI,
		 sclk => spi_lms_external_SCLK,
		 sen => spi_enables(1),
		 lreset => fpga_reset_n,
		 mreset => fpga_reset_n,
		 BOARD_GPIO_RD => GDFX_TEMP_SIGNAL_0,
		 maddress => GDFX_TEMP_SIGNAL_1,
		 PERIPH_INPUT_RD_0 => GDFX_TEMP_SIGNAL_2,
		 PERIPH_INPUT_RD_1 => SYNTHESIZED_WIRE_1,
		 sdout => periphcfg_sdout,
		 BOARD_GPIO_DIR => BOARD_GPIO_DIR,
		 BOARD_GPIO_OVRD => BOARD_GPIO_OVRD,
		 BOARD_GPIO_VAL => BOARD_GPIO_VAL,
		 PERIPH_OUTPUT_OVRD_0 => PERIPH_OUTPUT_OVRD_0,
		 PERIPH_OUTPUT_VAL_0 => PERIPH_OUTPUT_VAL_0);


b2v_inst18 : miso_mux
PORT MAP(fpga_miso => mux_spi_miso,
		 ext_miso => L,
		 fpga_cs => BRDG_SPI_FPGA_SS,
		 ext_cs => ctr_LMS_SPI_CS,
		 out_miso => BRDG_SPI_MISO);


TX1_2_LB_L <= NOT(GPIO(0));



b2v_inst2 : gpio_ctrl_top
GENERIC MAP(bus_width => 8
			)
PORT MAP(dir_0 => GDFX_TEMP_SIGNAL_3,
		 dir_1 => BOARD_GPIO_DIR(7 DOWNTO 0),
		 gpio => FPGA_GPIO,
		 mux_sel => BOARD_GPIO_OVRD(7 DOWNTO 0),
		 out_val_0 => GDFX_TEMP_SIGNAL_4,
		 out_val_1 => BOARD_GPIO_VAL(7 DOWNTO 0),
		 gpio_in => BOARD_GPIO_RD);


b2v_inst20 : rx_synchronizers
PORT MAP(clk1 => MCLK2RX,
		 clk1_reset_n => rxpll_locked,
		 clk1_d0 => stream_rxen_fx3clk,
		 clk1_d1 => lte_mimo_en,
		 clk1_s0 => stream_rxen_mclk2rxpll);


SYNTHESIZED_WIRE_2 <= NOT(FX3_busy);



b2v_inst22 : fx3_led_ctrl
PORT MAP(ctrl_led_g => SYNTHESIZED_WIRE_2,
		 ctrl_led_r => FX3_busy,
		 HW_VER => HW_VER,
		 led_ctrl => FX3_LED_CTRL_s,
		 led_g => FX3_LED_G,
		 led_r => FX3_LED_R);


spi_lms_miso <= fpga_internal_spi OR FPGA_SPI0_MISO;


b2v_inst24 : fpgacfg
PORT MAP(mimo_en => H,
		 sdin => spi_lms_external_MOSI,
		 sclk => spi_lms_external_SCLK,
		 sen => spi_enables(1),
		 lreset => fpga_reset_n,
		 mreset => fpga_reset_n,
		 PWR_SRC => PWR_SRC,
		 BOM_VER => BOM_VER,
		 HW_VER => HW_VER,
		 maddress => SYNTHESIZED_WIRE_3,
		 sdout => internal_spi_miso,
		 mimo_int_en => lte_mimo_en,
		 synch_dis => lte_synch_dis,
		 smpl_nr_clr => lte_clr_smpl_nr,
		 txpct_loss_clr => lte_txpct_loss_clr,
		 rx_en => stream_rxen,
		 rx_ptrn_en => rx_ptrn_en,
		 tx_ptrn_en => tx_ptrn_en,
		 tx_cnt_en => tx_cnt_en,
		 wfm_play => wfm_play,
		 wfm_load => wfm_load,
		 LMS1_SS => ctr_LMS_SPI_CS,
		 LMS1_RESET => lms1_reset,
		 LMS1_CORE_LDO_EN => LMS_CORE_LDO_EN,
		 LMS1_TXNRX1 => LMS_TXNRX1,
		 LMS1_TXNRX2 => LMS_TXNRX2,
		 LMS1_TXEN => LMS_TXEN,
		 LMS1_RXEN => LMS_RXEN,
		 ch_en => lte_ch_en,
		 drct_clk_en => drc_clk_en,
		 FCLK_ENA => FCLK_ENA,
		 FPGA_LED1_CTRL => FPGA_LED1_CTRL_s,
		 FPGA_LED2_CTRL => FPGA_LED2_CTRL_s,
		 FX3_LED_CTRL => FX3_LED_CTRL_s,
		 GPIO => GPIO,
		 smpl_width => lte_smpl_width,
		 wfm_ch_en => wfm_ch_en,
		 wfm_smpl_width => wfm_smpl_width);


TX2_2_LB_L <= NOT(GPIO(4));




b2v_inst27 : wfm_player_top
GENERIC MAP(addr_size => 25,
			cmd_fifo_size => 9,
			cntrl_bus_size => 16,
			cntrl_rate => 1,
			data_width => 32,
			dcmpr_fifo_size => 10,
			dev_family => "Cyclone IV E",
			iq_width => 12,
			lcl_burst_length => 2,
			lcl_bus_size => 63,
			wfm_infifo_size => 12,
			wfm_outfifo_size => 11
			)
PORT MAP(reset_n => fpga_reset_n,
		 ddr2_pll_ref_clk => clk_fpga2,
		 wcmd_clk => fx3_clk,
		 rcmd_clk => ddr2_1_phy_clk,
		 wfm_load => wfm_load,
		 wfm_play_stop => wfm_play,
		 wfm_wr => wfm_wr,
		 fr_start => L,
		 mimo_en => H,
		 iq_clk => lmlclk,
		 begin_test => test_en(4),
		 insert_error => test_inject_error(4),
		 ch_en => wfm_ch_en(1 DOWNTO 0),
		 mem_clk(0) => DDR2_1_clk(0),
		 mem_clk_n(0) => DDR2_1_clk_n(0),
		 mem_dq => DDR2_1_dq,
		 mem_dqs => DDR2_1_dqs,
		 sample_width => wfm_smpl_width,
		 wfm_data => wfm_data,
		 wfm_rdy => wfm_player_rdy,
		 mem_ras_n => DDR2_1_ras_n,
		 mem_cas_n => DDR2_1_cas_n,
		 mem_we_n => DDR2_1_we_n,
		 phy_clk => ddr2_1_phy_clk,
		 pass => ddr2_1_test_pass,
		 fail => ddr2_1_test_fail,
		 test_complete => ddr2_1_test_complete,
		 dd_iq_h => dd_iq_h,
		 dd_iq_l => dd_iq_l,
		 mem_addr => DDR2_1_addr,
		 mem_ba => DDR2_1_ba,
		 mem_cke(0) => DDR2_1_cke(0),
		 mem_cs_n(0) => DDR2_1_cs_n(0),
		 mem_dm => DDR2_1_dm,
		 mem_odt(0) => DDR2_1_odt(0),
		 pnf_per_bit_persist => ddr2_1_pnf_per_bit_persisit,
		 wfm_infifo_wrusedw => wfm_player_wrusedw);


fpga_internal_spi <= tstcfg_sdout OR internal_spi_miso OR periphcfg_sdout OR pllcfg_sdoutA;


b2v_inst3 : fpga_led1_cntrl
PORT MAP(pll1_locked => mclk1tx_locked,
		 pll2_locked => rxpll_locked,
		 alive => fpga_alive,
		 led_ctrl => FPGA_LED1_CTRL_s,
		 led_g => FPGA_LED1_G,
		 led_r => FPGA_LED1_R);


b2v_inst30 : clock_test
PORT MAP(FX3_clk => fx3_clk,
		 reset_n => fpga_reset_n,
		 Si5351C_clk_0 => SI_CLK0,
		 Si5351C_clk_1 => SI_CLK1,
		 Si5351C_clk_2 => SI_CLK2,
		 Si5351C_clk_3 => SI_CLK3,
		 Si5351C_clk_5 => SI_CLK5,
		 Si5351C_clk_6 => SI_CLK6,
		 Si5351C_clk_7 => SI_CLK7,
		 LMK_CLK => LMK_CLK,
		 ADF_MUXOUT => ADF_MUXOUT,
		 test_en => test_en(3 DOWNTO 0),
		 test_frc_err => test_inject_error(3 DOWNTO 0),
		 ADF_MUXOUT_cnt => SYNTHESIZED_WIRE_4,
		 FX3_clk_cnt => SYNTHESIZED_WIRE_5,
		 LMK_CLK_cnt => SYNTHESIZED_WIRE_6,
		 Si5351C_clk_0_cnt => SYNTHESIZED_WIRE_7,
		 Si5351C_clk_1_cnt => SYNTHESIZED_WIRE_8,
		 Si5351C_clk_2_cnt => SYNTHESIZED_WIRE_9,
		 Si5351C_clk_3_cnt => SYNTHESIZED_WIRE_10,
		 Si5351C_clk_5_cnt => SYNTHESIZED_WIRE_11,
		 Si5351C_clk_6_cnt => SYNTHESIZED_WIRE_12,
		 Si5351C_clk_7_cnt => SYNTHESIZED_WIRE_13,
		 test_cmplt => clk_test_cmplt,
		 test_rez => clk_test_rez);

clk_fpga2 <= SI_CLK0;



b2v_inst32 : pll_block_rx
PORT MAP(pll_inclk0 => MCLK2RX,
		 pll_areset => pllrst_start(1),
		 clk => LMK_CLK,
		 reset => pllrst_start(1),
		 phase_ps_en => phcfg_start(1),
		 phase_up_dn => phcfg_updn,
		 reconfig_en => pllcfg_start(1),
		 drct_clk_en => drc_clk_en(1),
		 FCLK_ENA => FCLK_ENA(1),
		 phase => cnt_phase(9 DOWNTO 0),
		 phase_cnt_sel => cnt_ind(2 DOWNTO 0),
		 reconfig_data => pllcfg_data,
		 c0 => MCLK2RX_pll,
		 c1 => MCLK2RX_pll_d,
		 pll_locked => rxpll_locked,
		 cfg_busy => rxpllcfg_busy,
		 pll_inclk0_dly => MCLK2RX_dly);


b2v_inst33 : pll_block_tx
PORT MAP(pll_inclk0 => MCLK1TX,
		 pll_areset => pllrst_start(0),
		 clk => LMK_CLK,
		 reset => pllrst_start(0),
		 phase_ps_en => phcfg_start(0),
		 phase_up_dn => phcfg_updn,
		 reconfig_en => pllcfg_start(0),
		 drct_clk_en => drc_clk_en(0),
		 FCLK_ENA => FCLK_ENA(0),
		 phase => cnt_phase(9 DOWNTO 0),
		 phase_cnt_sel => cnt_ind(2 DOWNTO 0),
		 reconfig_data => pllcfg_data,
		 c0 => LMS_FCLK1,
		 c1 => lmlclk,
		 pll_locked => mclk1tx_locked,
		 cfg_busy => txpllcfg_busy);


b2v_inst34 : lte_tx_path
GENERIC MAP(dev_family => "Cyclone IV E"
			)
PORT MAP(RX_clk => MCLK2RX,
		 rxpll_locked => rxpll_locked,
		 TX_clk => lmlclk,
		 txpll_locked => mclk1tx_locked,
		 pct_wrclk => fx3_clk,
		 pct_wr => tx_outfifo_wrreq,
		 rxpath_wr => wrrxfifo_wr,
		 stream_rxen => stream_rxen,
		 lte_synch_dis => lte_synch_dis,
		 lte_mimo_en => lte_mimo_en,
		 lte_clr_smpl_nr => lte_clr_smpl_nr,
		 fr_start => L,
		 rx_cap_en => H,
		 tx_reset_req => L,
		 lte_ch_en => lte_ch_en,
		 lte_smpl_width => lte_smpl_width,
		 pct_data => tx_outfifo_data,
		 pct_fifo_rdy => tx_outfifo_rdy,
		 pct_cleared => pct_buff_aclr,
		 dd_data_h => tx_path_h,
		 dd_data_l => tx_path_l);


b2v_inst35 : rx_path
GENERIC MAP(dev_family => "Cyclone IV E",
			diq_width => 12,
			infifo_wrsize => 12,
			outfifo_size => 12
			)
PORT MAP(clk_iopll => MCLK2RX_pll_d,
		 clk_iodirect => MCLK2RX_dly,
		 clk => MCLK2RX,
		 reset_n => rxpll_locked,
		 en => stream_rxen_fx3clk,
		 DIQ2_IQSEL2 => LMS_DIQ2_IQSEL2,
		 drct_clk_en => drc_clk_en(1),
		 data_src => rx_ptrn_en,
		 fr_start => L,
		 mimo_en => lte_mimo_en,
		 pct_clr_detect => pct_buff_aclr,
		 clr_pct_loss_flag => lte_txpct_loss_clr,
		 clr_smpl_nr => lte_clr_smpl_nr,
		 outfifo_full => fx3_outfifo_wfull,
		 ch_en => lte_ch_en,
		 DIQ2 => LMS_DIQ2_D,
		 outfifo_wrusedw => fx3_outfifo_wrusedw,
		 smpl_width => lte_smpl_width,
		 outfifo_wr => rxpct_outfifowr,
		 wrrxfifo_wr => wrrxfifo_wr,
		 outfifo_data => rx_pct_data);

FAN_CTRL <= PERIPH_OUTPUT_VAL_0(0) when PERIPH_OUTPUT_OVRD_0(0)='1' 
									else LM75_OS;
		 


b2v_inst39 : tstcfg
PORT MAP(mimo_en => H,
		 sdin => spi_lms_external_MOSI,
		 sclk => spi_lms_external_SCLK,
		 sen => spi_enables(1),
		 lreset => fpga_reset_n,
		 mreset => fpga_reset_n,
		 ADF_CNT => SYNTHESIZED_WIRE_4,
		 DDR2_1_pnf_per_bit => ddr2_1_pnf_per_bit_persisit,
		 DDR2_1_STATUS => GDFX_TEMP_SIGNAL_5,
		 DDR2_2_pnf_per_bit => ddr2_2_pnf_per_bit_persisit,
		 DDR2_2_STATUS => GDFX_TEMP_SIGNAL_6,
		 FX3_CLK_CNT => SYNTHESIZED_WIRE_5,
		 LMK_CLK_CNT => SYNTHESIZED_WIRE_6,
		 maddress => GDFX_TEMP_SIGNAL_7,
		 Si5351C_CLK0_CNT => SYNTHESIZED_WIRE_7,
		 Si5351C_CLK1_CNT => SYNTHESIZED_WIRE_8,
		 Si5351C_CLK2_CNT => SYNTHESIZED_WIRE_9,
		 Si5351C_CLK3_CNT => SYNTHESIZED_WIRE_10,
		 Si5351C_CLK5_CNT => SYNTHESIZED_WIRE_11,
		 Si5351C_CLK6_CNT => SYNTHESIZED_WIRE_12,
		 Si5351C_CLK7_CNT => SYNTHESIZED_WIRE_13,
		 TEST_CMPLT => GDFX_TEMP_SIGNAL_8,
		 TEST_REZ => GDFX_TEMP_SIGNAL_9,
		 sdout => tstcfg_sdout,
		 TEST_EN => test_en,
		 TEST_FRC_ERR => test_inject_error,
		 TX_TST_I => TX_TST_I,
		 TX_TST_Q => TX_TST_Q);


b2v_inst4 : alive
PORT MAP(rst => fpga_reset_n,
		 clk => clk_fpga2,
		 beat => fpga_alive);


mux_spi_miso <= pllcfg_sdoutA OR tstcfg_sdout OR L;


b2v_inst41 : fx3_slavefifo5b_top
GENERIC MAP(data_width => 32,
			dev_family => "Cyclone IV E",
			EP01_rwidth => 64,
			EP0F_rwidth => 32,
			EP81_wrusedw_width => 12,
			EP81_wwidth => 64,
			EP8F_wwidth => 32
			)
PORT MAP(
		flagc => 'Z',
		flagd => 'Z',
		EP01_rdclk => 'Z',
		EP01_rd => 'Z',
reset_n => fpga_reset_n,
		 clk => fx3_clk,
		 usb_speed => H,
		 flaga => FX3_CTL4,
		 flagb => FX3_CTL5,
		 ext_buff_rdy => stream_sw_rdy,
		 EP81_wclk => MCLK2RX,
		 EP81_aclrn => stream_rxen_mclk2rxpll,
		 EP81_wr => rxpct_outfifowr,
		 EP0F_rdclk => fx3_clk,
		 EP0F_rd => exfifo_if_rd,
		 EP8F_wclk => fx3_clk,
		 EP8F_aclrn => SYNTHESIZED_WIRE_14,
		 EP8F_wr => exfifo_of_wr,
		 EP81_wdata => rx_pct_data,
		 EP8F_wdata => exfifo_of_d,
		 fdata => FX3_DQ,
		 slcs => FX3_CTL0,
		 slrd => FX3_CTL3,
		 sloe => FX3_CTL2,
		 slwr => FX3_CTL1,
		 pktend => FX3_CTL7,
		 ext_buff_wr => EP01_data_valid,
		 EP81_wfull => fx3_outfifo_wfull,
		 EP0F_rempty => exfifo_if_rdempty,
		 EP8F_wfull => exfifo_of_wrfull,
		 GPIF_busy => FX3_slave_busy,
		 EP0F_rdata => exfifo_if_d,
		 EP81_wrusedw => fx3_outfifo_wrusedw,
		 ext_buff_data => EP01_data,
		 faddr => fadr);



b2v_inst42 : soc_wrapper
		generic map(
			cpu_name => "orca"
		)
		port map(
			clk100 => fx3_clk,
			exfifo_if_rdempty => exfifo_if_rdempty,
			exfifo_of_wrfull => exfifo_of_wrfull,
			spi_lms_MISO => spi_lms_miso,
			i2c_scl => FPGA_I2C_SCL,
			i2c_sda => FPGA_I2C_SDA,
			exfifo_if_d => exfifo_if_d,
			switch => GDFX_TEMP_SIGNAL_10,
			exfifo_if_rd => exfifo_if_rd,
			exfifo_of_wr => exfifo_of_wr,
			exfifo_rst => exfifo_rst,
			spi_lms_MOSI => spi_lms_external_MOSI,
			spi_lms_SCLK => spi_lms_external_SCLK,
			spi_1_MOSI => FPGA_SPI1_MOSI,
			spi_1_SCLK => FPGA_SPI1_SCLK_ALTERA_SYNTHESIZED,
			exfifo_of_d => exfifo_of_d,
			leds => nios_leds,
			lms_ctr_gpio => lms_ctr_gpio,
			spi_1_SS_n => spi_1_enables,
			spi_lms_SS_n => spi_enables);


SYNTHESIZED_WIRE_14 <= NOT(exfifo_rst);



fpgapll_locked <= NOT(fpga_reset);



b2v_inst46 : ddr2_tester
PORT MAP(
		begin_test => 'Z',
		global_reset_n => test_en(5),
		 pll_ref_clk => SI_CLK1,
		 soft_reset_n => test_en(5),
		 insert_error => test_inject_error(5),
		 mem_clk(0) => DDR2_2_clk(0),
		 mem_clk_n(0) => DDR2_2_clk_n(0),
		 mem_dq => DDR2_2_dq,
		 mem_dqs => DDR2_2_dqs,
		 mem_ras_n => DDR2_2_ras_n,
		 mem_cas_n => DDR2_2_cas_n,
		 mem_we_n => DDR2_2_we_n,
		 pass => ddr2_2_test_pass,
		 fail => ddr2_2_test_fail,
		 test_complete => ddr2_2_test_complete,
		 mem_addr => DDR2_2_addr,
		 mem_ba => DDR2_2_ba,
		 mem_cke(0) => DDR2_2_cke(0),
		 mem_cs_n(0) => DDR2_2_cs_n(0),
		 mem_dm => DDR2_2_dm,
		 mem_odt(0) => DDR2_2_odt(0),
		 pnf_per_bit_persist => ddr2_2_pnf_per_bit_persisit);


SYNTHESIZED_WIRE_0 <= nios_leds(0) OR FX3_MCU_BUSY OR FX3_slave_busy;



b2v_inst54 : synchronizer
PORT MAP(clk => fx3_clk,
		 reset_n => fpgapll_locked,
		 signal_in => stream_rxen,
		 signal_sinch => stream_rxen_fx3clk);


b2v_inst55 : synchronizer
PORT MAP(clk => fx3_clk,
		 reset_n => fpgapll_locked,
		 signal_in => tx_outfifo_rdy);



b2v_inst7 : lms7002_ddout
GENERIC MAP(dev_family => "Cyclone IV E",
			iq_width => 12
			)
PORT MAP(clk => lmlclk,
		 reset_n => mclk1tx_locked,
		 data_in_h => ddmux_h,
		 data_in_l => ddmux_l,
		 txiqsel => txiqsel,
		 txiq => txiq);


fpga_reset_n <= NOT(fpga_reset);



b2v_inst9 : pllcfg_top
GENERIC MAP(n_pll => 2
			)
PORT MAP(
		sdinB => 'Z',
		sclkB => 'Z',
		senB => 'Z',
		sdinA => spi_lms_external_MOSI,
		 sclkA => spi_lms_external_SCLK,
		 senA => spi_enables(1),
		 lreset => fpga_reset_n,
		 mreset => fpga_reset_n,
		 pll_lock => GDFX_TEMP_SIGNAL_11,
		 pllcfg_busy => GDFX_TEMP_SIGNAL_12,
		 pllcfg_done => GDFX_TEMP_SIGNAL_13,
		 sdoutA => pllcfg_sdoutA,
		 phcfg_updn => phcfg_updn,
		 cnt_ind => cnt_ind,
		 cnt_phase => cnt_phase,
		 phcfg_start => phcfg_start,
		 pllcfg_data => pllcfg_data,
		 pllcfg_start => pllcfg_start,
		 pllrst_start => pllrst_start);

fx3_clk <= FX3_PCLK;
fpga_reset <= EXT_GND;
MCLK2RX <= LMS_MCLK2;
MCLK1TX <= LMS_MCLK1;
LMS_DIQ1_IQSEL <= txiqsel;
FPGA_SPI1_SCLK <= FPGA_SPI1_SCLK_ALTERA_SYNTHESIZED;
FPGA_SPI1_ADF_SS <= spi_1_enables(1);
TX2_2_LB_H <= GPIO(4);
TX2_2_LB_AT <= GPIO(5);
TX2_2_LB_SH <= GPIO(6);
TX1_2_LB_H <= GPIO(0);
TX1_2_LB_AT <= GPIO(1);
TX1_2_LB_SH <= GPIO(2);
FX3_MCU_BUSY <= FX3_CTL8;
FX3_CTL12 <= fadr(0);
FX3_CTL11 <= fadr(1);
FPGA_SPI0_SCLK <= spi_lms_external_SCLK;
FPGA_SPI0_MOSI <= spi_lms_external_MOSI;
FPGA_SPI0_LMS_SS <= spi_enables(0);
LMS_FCLK2 <= MCLK2RX_pll;
LMS_DIQ1_D <= txiq;

H <= '1';
L <= '0';
END bdf_type;