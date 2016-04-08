-- ----------------------------------------------------------------------------	
-- FILE: 	my_busmux.vhd
-- DESCRIPTION:	simple bus mux in VHDl
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity my_busmux is
	generic(
				bus_witdh : integer:=13
				);
  port (
        --input ports 
        dataa       	: in std_logic_vector(bus_witdh-1 downto 0);
        datab   		: in std_logic_vector(bus_witdh-1 downto 0);
		  result			: out std_logic_vector(bus_witdh-1 downto 0);
		  sel				: in std_logic

        --output ports 
        
        );
end my_busmux;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of my_busmux is
--declare signals,  components here


  
begin

result<=dataa when sel='0' else 
		datab;
	 
	 
  
end arch;   




