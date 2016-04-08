-- ----------------------------------------------------------------------------	
-- FILE: 	synch.vhd
-- DESCRIPTION:	for signals in different clock domains
-- DATE:	June 23, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity synchronizer is
  port (
        --input ports 
        clk       		: in std_logic;
        reset_n   		: in std_logic;
		  signal_in			: in std_logic;
		  signal_sinch		: out std_logic

        
        );
end synchronizer;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of synchronizer is
--declare signals,  components here
signal signal_d0 : std_logic; 
signal signal_d1 : std_logic; 
signal signal_d2 : std_logic; 

  
begin

  process(reset_n, clk)
    begin
      if reset_n='0' then
        signal_d0<='0';
		  signal_d1<='0';
		  signal_d2<='0';
 	    elsif (clk'event and clk = '1') then
 	      signal_d0<=signal_in;
			signal_d1<=signal_d0;
			signal_d2<=signal_d1;
 	    end if;
    end process;
	 
signal_sinch<=	signal_d2; 
  
end arch;   




