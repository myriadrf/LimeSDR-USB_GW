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
-- CREATED		"Fri Jun  2 17:11:55 2017"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY pll_block_tx IS 
	PORT
	(
		pll_areset :  IN  STD_LOGIC;
		pll_inclk0 :  IN  STD_LOGIC;
		clk :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC;
		phase_ps_en :  IN  STD_LOGIC;
		phase_up_dn :  IN  STD_LOGIC;
		reconfig_en :  IN  STD_LOGIC;
		drct_clk_en :  IN  STD_LOGIC;
		FCLK_ENA :  IN  STD_LOGIC;
		phase :  IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
		phase_cnt_sel :  IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		reconfig_data :  IN  STD_LOGIC_VECTOR(143 DOWNTO 0);
		c0 :  OUT  STD_LOGIC;
		c1 :  OUT  STD_LOGIC;
		pll_locked :  OUT  STD_LOGIC;
		reconfig_status :  OUT  STD_LOGIC;
		cfg_busy :  OUT  STD_LOGIC
	);
END pll_block_tx;

ARCHITECTURE bdf_type OF pll_block_tx IS 

--ATTRIBUTE black_box : BOOLEAN;
--ATTRIBUTE noopt : BOOLEAN;
--
--COMPONENT busmux_0
--	PORT(sel : IN STD_LOGIC;
--		 dataa : IN STD_LOGIC_VECTOR(0 TO 0);
--		 datab : IN STD_LOGIC_VECTOR(0 TO 0);
--		 result : OUT STD_LOGIC_VECTOR(0 TO 0));
--END COMPONENT;
--ATTRIBUTE black_box OF busmux_0: COMPONENT IS true;
--ATTRIBUTE noopt OF busmux_0: COMPONENT IS true;

COMPONENT pll_reconfig_status
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 reconfig_en : IN STD_LOGIC;
		 scandone : IN STD_LOGIC;
		 exclude_ps_status : IN STD_LOGIC;
		 ps_en : IN STD_LOGIC;
		 ps_status : IN STD_LOGIC;
		 rcfig_complete : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT clkctrl
	PORT(inclk : IN STD_LOGIC;
		 ena : IN STD_LOGIC;
		 outclk : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT txpll
	PORT(inclk0 : IN STD_LOGIC;
		 areset : IN STD_LOGIC;
		 pfdena : IN STD_LOGIC;
		 scanclk : IN STD_LOGIC;
		 scandata : IN STD_LOGIC;
		 scanclkena : IN STD_LOGIC;
		 configupdate : IN STD_LOGIC;
		 phaseupdown : IN STD_LOGIC;
		 phasestep : IN STD_LOGIC;
		 phasecounterselect : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 c0 : OUT STD_LOGIC;
		 c1 : OUT STD_LOGIC;
		 scandataout : OUT STD_LOGIC;
		 scandone : OUT STD_LOGIC;
		 phasedone : OUT STD_LOGIC;
		 locked : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT pll_reconfig_module
	PORT(reconfig : IN STD_LOGIC;
		 read_param : IN STD_LOGIC;
		 write_param : IN STD_LOGIC;
		 pll_scandataout : IN STD_LOGIC;
		 pll_scandone : IN STD_LOGIC;
		 clock : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 pll_areset_in : IN STD_LOGIC;
		 write_from_rom : IN STD_LOGIC;
		 rom_data_in : IN STD_LOGIC;
		 reset_rom_address : IN STD_LOGIC;
		 counter_param : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 counter_type : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 data_in : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		 busy : OUT STD_LOGIC;
		 pll_scandata : OUT STD_LOGIC;
		 pll_scanclk : OUT STD_LOGIC;
		 pll_scanclkena : OUT STD_LOGIC;
		 pll_configupdate : OUT STD_LOGIC;
		 pll_areset : OUT STD_LOGIC;
		 write_rom_ena : OUT STD_LOGIC;
		 data_out : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		 rom_address_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT config_ctrl
	PORT(clk : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 busy : IN STD_LOGIC;
		 rd_data : IN STD_LOGIC;
		 en_config : IN STD_LOGIC;
		 addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 spi_data : IN STD_LOGIC_VECTOR(143 DOWNTO 0);
		 en_clk : OUT STD_LOGIC;
		 wr_rom : OUT STD_LOGIC;
		 reconfig : OUT STD_LOGIC;
		 config_data : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT pll_ps_cntrl
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 ps_en : IN STD_LOGIC;
		 ph_done : IN STD_LOGIC;
		 pll_locked : IN STD_LOGIC;
		 pll_reconfig : IN STD_LOGIC;
		 phase : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 ph_step : OUT STD_LOGIC;
		 ps_status : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT lcell
	PORT(A_IN : IN STD_LOGIC;
		 A_OUT : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT ddrox1
	PORT(outclock : IN STD_LOGIC;
		 datain_h : IN STD_LOGIC_VECTOR(0 TO 0);
		 datain_l : IN STD_LOGIC_VECTOR(0 TO 0);
		 dataout : OUT STD_LOGIC_VECTOR(0 TO 0)
	);
END COMPONENT;

SIGNAL	busy :  STD_LOGIC;
SIGNAL	c0_ddr :  STD_LOGIC;
SIGNAL	c0_mux :  STD_LOGIC;
SIGNAL	c0_out :  STD_LOGIC;
SIGNAL	c1_mux :  STD_LOGIC;
SIGNAL	c1_out :  STD_LOGIC;
SIGNAL	c_data :  STD_LOGIC;
SIGNAL	configupdate :  STD_LOGIC;
SIGNAL	H :  STD_LOGIC;
SIGNAL	inclk0 :  STD_LOGIC;
SIGNAL	L :  STD_LOGIC;
SIGNAL	phasestep :  STD_LOGIC;
SIGNAL	pll_areset_in :  STD_LOGIC;
SIGNAL	pll_arst :  STD_LOGIC;
SIGNAL	pll_lock :  STD_LOGIC;
SIGNAL	pll_lock_mux :  STD_LOGIC;
SIGNAL	pll_ph_done :  STD_LOGIC;
SIGNAL	ps_status :  STD_LOGIC;
SIGNAL	rcnfig_complete :  STD_LOGIC;
SIGNAL	reconf_clk :  STD_LOGIC;
SIGNAL	reconfig :  STD_LOGIC;
SIGNAL	rom_addr :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	rom_rd_en :  STD_LOGIC;
SIGNAL	rst :  STD_LOGIC;
SIGNAL	scanclk :  STD_LOGIC;
SIGNAL	scanclkena :  STD_LOGIC;
SIGNAL	scandata :  STD_LOGIC;
SIGNAL	scandataout :  STD_LOGIC;
SIGNAL	scandone :  STD_LOGIC;
SIGNAL	wr_rom :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_21 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC_VECTOR(0 TO 2);
SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC_VECTOR(0 TO 3);
SIGNAL	SYNTHESIZED_WIRE_16 :  STD_LOGIC_VECTOR(0 TO 8);
SIGNAL	SYNTHESIZED_WIRE_17 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_18 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_19 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_20 :  STD_LOGIC;


BEGIN 
SYNTHESIZED_WIRE_10 <= '1';
SYNTHESIZED_WIRE_21 <= '0';
SYNTHESIZED_WIRE_13 <= '0';
SYNTHESIZED_WIRE_14 <= "000";
SYNTHESIZED_WIRE_15 <= "0000";
SYNTHESIZED_WIRE_16 <= "000000000";




b2v_inst1 : pll_reconfig_status
PORT MAP(clk => scanclk,
		 reset_n => SYNTHESIZED_WIRE_0,
		 reconfig_en => reconfig_en,
		 scandone => scandone,
		 exclude_ps_status => L,
		 ps_en => phase_ps_en,
		 ps_status => ps_status,
		 rcfig_complete => rcnfig_complete);


b2v_inst10 : clkctrl
PORT MAP(inclk => c0_out,
		 ena => SYNTHESIZED_WIRE_1,
		 outclk => SYNTHESIZED_WIRE_4);


b2v_inst11 : clkctrl
PORT MAP(inclk => inclk0,
		 ena => SYNTHESIZED_WIRE_2,
		 outclk => SYNTHESIZED_WIRE_3);


c0_mux <= SYNTHESIZED_WIRE_3 OR SYNTHESIZED_WIRE_4;


SYNTHESIZED_WIRE_1 <= SYNTHESIZED_WIRE_5 AND FCLK_ENA;


b2v_inst14 : clkctrl
PORT MAP(inclk => c1_out,
		 ena => SYNTHESIZED_WIRE_6,
		 outclk => SYNTHESIZED_WIRE_9);


b2v_inst15 : clkctrl
PORT MAP(inclk => SYNTHESIZED_WIRE_7,
		 ena => drct_clk_en,
		 outclk => SYNTHESIZED_WIRE_8);


c1_mux <= SYNTHESIZED_WIRE_8 OR SYNTHESIZED_WIRE_9;


SYNTHESIZED_WIRE_6 <= NOT(drct_clk_en);



SYNTHESIZED_WIRE_5 <= NOT(drct_clk_en);



SYNTHESIZED_WIRE_2 <= drct_clk_en AND FCLK_ENA;


SYNTHESIZED_WIRE_0 <= NOT(rst);



cfg_busy <= ps_status OR busy;


b2v_inst35 : txpll
PORT MAP(inclk0 => inclk0,
		 areset => pll_arst,
		 pfdena => SYNTHESIZED_WIRE_10,
		 scanclk => scanclk,
		 scandata => scandata,
		 scanclkena => scanclkena,
		 configupdate => configupdate,
		 phaseupdown => phase_up_dn,
		 phasestep => phasestep,
		 phasecounterselect => phase_cnt_sel,
		 c0 => c0_out,
		 c1 => c1_out,
		 scandataout => scandataout,
		 scandone => scandone,
		 phasedone => pll_ph_done,
		 locked => pll_lock);


b2v_inst36 : pll_reconfig_module
PORT MAP(reconfig => reconfig,
		 read_param => SYNTHESIZED_WIRE_21,
		 write_param => SYNTHESIZED_WIRE_21,
		 pll_scandataout => scandataout,
		 pll_scandone => scandone,
		 clock => reconf_clk,
		 reset => rst,
		 pll_areset_in => pll_areset_in,
		 write_from_rom => wr_rom,
		 rom_data_in => c_data,
		 reset_rom_address => SYNTHESIZED_WIRE_13,
		 counter_param => SYNTHESIZED_WIRE_14,
		 counter_type => SYNTHESIZED_WIRE_15,
		 data_in => SYNTHESIZED_WIRE_16,
		 busy => busy,
		 pll_scandata => scandata,
		 pll_scanclk => scanclk,
		 pll_scanclkena => scanclkena,
		 pll_configupdate => configupdate,
		 pll_areset => pll_arst,
		 write_rom_ena => rom_rd_en,
		 rom_address_out => rom_addr);


b2v_inst37 : config_ctrl
PORT MAP(clk => reconf_clk,
		 rst => rst,
		 busy => busy,
		 rd_data => rom_rd_en,
		 en_config => reconfig_en,
		 addr => rom_addr,
		 spi_data => reconfig_data,
		 wr_rom => wr_rom,
		 reconfig => reconfig,
		 config_data => c_data);








b2v_inst43 : pll_ps_cntrl
PORT MAP(clk => scanclk,
		 reset_n => SYNTHESIZED_WIRE_17,
		 ps_en => phase_ps_en,
		 ph_done => pll_ph_done,
		 pll_locked => pll_lock,
		 pll_reconfig => reconfig_en,
		 phase => phase,
		 ph_step => phasestep,
		 ps_status => ps_status);


SYNTHESIZED_WIRE_17 <= NOT(pll_arst);



b2v_inst5 : lcell
PORT MAP(A_IN => SYNTHESIZED_WIRE_18,
		 A_OUT => SYNTHESIZED_WIRE_7);



--b2v_inst6 : busmux_0
--PORT MAP(sel => drct_clk_en,
--		 dataa(0) => pll_lock,
--		 datab(0) => SYNTHESIZED_WIRE_19,
--		 result(0) => pll_lock_mux);

pll_lock_mux <= (not rst) when drct_clk_en='1' else pll_lock;

b2v_inst61 : ddrox1
PORT MAP(outclock => c0_mux,
		 datain_h(0) => H,
		 datain_l(0) => L,
		 dataout(0) => c0_ddr);


--SYNTHESIZED_WIRE_19 <= NOT(rst);



b2v_inst8 : lcell
PORT MAP(A_IN => SYNTHESIZED_WIRE_20,
		 A_OUT => SYNTHESIZED_WIRE_18);


b2v_inst9 : lcell
PORT MAP(A_IN => inclk0,
		 A_OUT => SYNTHESIZED_WIRE_20);

c0 <= c0_ddr;
inclk0 <= pll_inclk0;
reconf_clk <= clk;
rst <= reset;
pll_areset_in <= pll_areset;
c1 <= c1_mux;
pll_locked <= pll_lock_mux;
reconfig_status <= rcnfig_complete;

H <= '1';
L <= '0';
END bdf_type;