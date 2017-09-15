-- ----------------------------------------------------------------------------	
-- FILE: 	lms7002_ddout.vhd
-- DESCRIPTION:	takes data in SDR and ouputs double data rate
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
entity lms7002_ddout is
	generic( dev_family	: string := "Cyclone IV E";
				iq_width		: integer :=12
	);
	port (
      --input ports 
      clk       	: in std_logic;
      reset_n   	: in std_logic;
		data_in_h	: in std_logic_vector(iq_width downto 0);
		data_in_l	: in std_logic_vector(iq_width downto 0);
		--output ports 
		txiq		 	: out std_logic_vector(iq_width-1 downto 0);
		txiqsel	 	: out std_logic
		
        );
end lms7002_ddout;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of lms7002_ddout is
--declare signals,  components here
signal aclr 	: std_logic;
signal datout	: std_logic_vector(iq_width downto 0);

begin


aclr<=not reset_n;

	ALTDDIO_OUT_component : ALTDDIO_OUT
	GENERIC MAP (
		extend_oe_disable 		=> "OFF",
		intended_device_family 	=> "Cyclone IV E",
		invert_output 				=> "OFF",
		lpm_hint 					=> "UNUSED",
		lpm_type 					=> "altddio_out",
		oe_reg 						=> "UNREGISTERED",
		power_up_high 				=> "OFF",
		width 						=> iq_width+1
	)
	PORT MAP (
		aclr 			=> aclr,
		datain_h 	=> data_in_h,
		datain_l 	=> data_in_l,
		outclock 	=> clk,
		dataout 		=> datout
	);
	
	txiq		<=datout(11 downto 0);
	txiqsel	<=datout(12);
	
  
end arch;   





