-- ----------------------------------------------------------------------------	
-- FILE: 	file_name.vhd
-- DESCRIPTION:	describe
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
entity my_sw is
  port (
        --input ports 
        i       : in std_logic;
        sel   	 : in std_logic_vector(3 downto 0);
		  o 		 : out std_logic_vector(15 downto 0)

        --output ports 
        
        );
end my_sw;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of my_sw is
--declare signals,  components here

  
begin

process(sel, i) begin
	o<=(others=>'0');
	o(to_integer(unsigned(sel)))<=i;
end process;
  
end arch;




