-- ----------------------------------------------------------------------------	
-- FILE: 	led2_cntrl.vhd
-- DESCRIPTION:	describe
-- DATE:	Mar 18, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity led2_cntrl is
  port (
        --input ports 
        pll1_locked   : in std_logic;
        pll2_locked   : in std_logic;
		  alive			 : in std_logic;
        --output ports 
		  led_g			 : out std_logic;
        led_r			 : out std_logic

        );
end led2_cntrl;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of led2_cntrl is
signal all_pll_locked	: std_logic;

  
begin

all_pll_locked <= pll1_locked and pll2_locked;

led_g <= alive;
led_r <= not alive when all_pll_locked='0' else 
			'0';
  
end arch;




