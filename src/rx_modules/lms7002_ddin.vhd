-- ----------------------------------------------------------------------------	
-- FILE: 	lms7002_ddin.vhd
-- DESCRIPTION:	takes data from lms7002 in double data rate
-- DATE:	Mar 14, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity lms7002_ddin is
	generic( dev_family				: string := "Cyclone IV E";
				iq_width					: integer :=12;
				invert_input_clocks	: string := "ON"
	);
	port (
      --input ports 
      clk       	: in std_logic;
      reset_n   	: in std_logic;
		rxiq		 	: in std_logic_vector(iq_width-1 downto 0);
		rxiqsel	 	: in std_logic;
		--output ports 
		data_out_h	: out std_logic_vector(iq_width downto 0);
		data_out_l	: out std_logic_vector(iq_width downto 0)
		
        );
end lms7002_ddin;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of lms7002_ddin is
--declare signals,  components here
signal aclr 	: std_logic;
signal datain	: std_logic_vector(iq_width downto 0);

begin

datain<=rxiqsel & rxiq;

aclr<=not reset_n;

	ALTDDIO_IN_component : ALTDDIO_IN
	GENERIC MAP (
		intended_device_family 	=> dev_family,
		invert_input_clocks 		=> invert_input_clocks,
		lpm_hint 					=> "UNUSED",
		lpm_type 					=> "altddio_in",
		power_up_high 				=> "OFF",
		width 						=> iq_width+1
	)
	PORT MAP (
		aclr 			=> aclr,
		datain 		=> datain,
		inclock 		=> clk,
		dataout_h 	=> data_out_h,
		dataout_l 	=> data_out_l
	);
  
end arch;   





