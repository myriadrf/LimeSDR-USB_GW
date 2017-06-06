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
-- CREATED		"Sat Jun  3 22:38:56 2017"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY tx_synchronizers IS 
	PORT
	(
		clk0_reset_n :  IN  STD_LOGIC;
		clk1_reset_n :  IN  STD_LOGIC;
		clk0 :  IN  STD_LOGIC;
		clk1 :  IN  STD_LOGIC;
		clk2 :  IN  STD_LOGIC;
		clk2_reset_n :  IN  STD_LOGIC;
		clk1_d1 :  IN  STD_LOGIC;
		clk1_d2 :  IN  STD_LOGIC;
		clk1_d3 :  IN  STD_LOGIC;
		clk2_d0 :  IN  STD_LOGIC;
		clk0_d0 :  IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		clk1_d0 :  IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		clk2_s0 :  OUT  STD_LOGIC;
		clk1_s1 :  OUT  STD_LOGIC;
		clk1_s2 :  OUT  STD_LOGIC;
		clk1_s3 :  OUT  STD_LOGIC;
		clk0_s0 :  OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
		clk1_s0 :  OUT  STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END tx_synchronizers;

ARCHITECTURE bdf_type OF tx_synchronizers IS 

COMPONENT synchronizer
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 signal_in : IN STD_LOGIC;
		 signal_sinch : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT bus_synch
GENERIC (bus_w : INTEGER
			);
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 signal_in : IN STD_LOGIC_VECTOR(bus_w-1 DOWNTO 0);
		 signal_sinch : OUT STD_LOGIC_VECTOR(bus_w-1 DOWNTO 0)
	);
END COMPONENT;



BEGIN 



b2v_inst56 : synchronizer
PORT MAP(clk => clk1,
		 reset_n => clk1_reset_n,
		 signal_in => clk1_d1,
		 signal_sinch => clk1_s1);


b2v_inst61 : synchronizer
PORT MAP(clk => clk1,
		 reset_n => clk1_reset_n,
		 signal_in => clk1_d2,
		 signal_sinch => clk1_s2);


b2v_inst62 : synchronizer
PORT MAP(clk => clk2,
		 reset_n => clk2_reset_n,
		 signal_in => clk2_d0,
		 signal_sinch => clk2_s0);


b2v_inst63 : bus_synch
GENERIC MAP(bus_w => 16
			)
PORT MAP(clk => clk0,
		 reset_n => clk0_reset_n,
		 signal_in => clk0_d0,
		 signal_sinch => clk0_s0);


b2v_inst64 : bus_synch
GENERIC MAP(bus_w => 2
			)
PORT MAP(clk => clk1,
		 reset_n => clk1_reset_n,
		 signal_in => clk1_d0,
		 signal_sinch => clk1_s0);


b2v_inst65 : synchronizer
PORT MAP(clk => clk1,
		 reset_n => clk1_reset_n,
		 signal_in => clk1_d3,
		 signal_sinch => clk1_s3);


END bdf_type;