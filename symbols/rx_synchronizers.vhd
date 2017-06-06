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
-- CREATED		"Sat Jun  3 22:04:37 2017"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY rx_synchronizers IS 
	PORT
	(
		clk1 :  IN  STD_LOGIC;
		clk1_reset_n :  IN  STD_LOGIC;
		clk1_d0 :  IN  STD_LOGIC;
		clk1_d1 :  IN  STD_LOGIC;
		clk1_s0 :  OUT  STD_LOGIC;
		clk1_s1 :  OUT  STD_LOGIC
	);
END rx_synchronizers;

ARCHITECTURE bdf_type OF rx_synchronizers IS 

COMPONENT synchronizer
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 signal_in : IN STD_LOGIC;
		 signal_sinch : OUT STD_LOGIC
	);
END COMPONENT;



BEGIN 



b2v_inst19 : synchronizer
PORT MAP(clk => clk1,
		 reset_n => clk1_reset_n,
		 signal_in => clk1_d1,
		 signal_sinch => clk1_s1);


b2v_inst8 : synchronizer
PORT MAP(clk => clk1,
		 reset_n => clk1_reset_n,
		 signal_in => clk1_d0,
		 signal_sinch => clk1_s0);


END bdf_type;