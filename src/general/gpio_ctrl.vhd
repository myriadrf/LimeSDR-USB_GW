-- ----------------------------------------------------------------------------	
-- FILE: 	gpio_ctrl.vhd
-- DESCRIPTION:	GPIO with controled direction. 
-- DATE:	March 17, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity gpio_ctrl is
	port (
		gpio  		: inout std_logic;
		gpio_in		: out std_logic;
		mux_sel		: in std_logic; 	-- mux select
		dir_0			: in std_logic; 	-- 0 - input, 1 - output.
		dir_1			: in std_logic; 	-- 0 - input, 1 - output.
		out_val_0	: in std_logic;
		out_val_1	: in std_logic

        );
end gpio_ctrl;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of gpio_ctrl is
--declare signals,  components here

signal gpio_dir	: std_logic;
signal gpio_val	: std_logic;
 
begin

--mux
gpio_dir <= dir_0 		when mux_sel = '0' else dir_1;
gpio_val <= out_val_0	when mux_sel = '0' else out_val_1;

--tri state buffer
gpio		<= gpio_val when gpio_dir = '1' else 'Z';

gpio_in	<= gpio;
  
end arch;





