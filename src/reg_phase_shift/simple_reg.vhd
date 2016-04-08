
-- ----------------------------------------------------------------------------	
-- FILE: 	simple_reg.vhd
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
entity simple_reg is
  port (
        --input ports 
			clk      : in std_logic;
			reset_n  : in std_logic;
			d 			: in std_logic;
			q			: out std_logic

        --output ports 
        
        );
end simple_reg;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of simple_reg is
--declare signals,  components here

  
begin

  process(reset_n, clk)
    begin
      if reset_n='0' then
        q<=('0');  
 	    elsif (clk'event and clk = '1') then
 	      q<=d;
 	    end if;
    end process;
  
end arch;   




