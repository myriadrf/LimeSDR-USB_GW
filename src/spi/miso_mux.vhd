-- ----------------------------------------------------------------------------	
-- FILE: 	miso_mux.vhd
-- DESCRIPTION:	mux for spi miso signal
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
entity miso_mux is
  port (
        --input ports 
        fpga_miso       : in std_logic;
        ext_miso		   : in std_logic;
		  fpga_cs			: in std_logic;
		  ext_cs				: in std_logic;

        --output ports 
        out_miso			: out std_logic
        );
end miso_mux;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of miso_mux is
--declare signals,  components here


  
begin

out_miso<=fpga_miso when (fpga_cs='0') else 
				ext_miso when (fpga_cs='1' and ext_cs='0') else
				'Z';
  
end arch;   




