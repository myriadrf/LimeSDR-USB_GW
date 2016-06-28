-- ----------------------------------------------------------------------------	
-- FILE: 	rst_pulse.vhd
-- DESCRIPTION:	makes single reset_n pulse 
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
entity rstn_pulse is
  port (
        --input ports 
        clk       		: in std_logic;
		  reset_n			: in std_logic;
        resetn_in   		: in std_logic;
		  rstn_pulse_out	: out std_logic

        --output ports 
        
        );
end rstn_pulse;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of rstn_pulse is
--declare signals,  components here
signal resetn_in_reg : std_logic;
signal resetn_in_reg1 : std_logic;
signal resetn_in_reg2 : std_logic;

  
begin

  process(reset_n, clk)
    begin
      if reset_n='0' then
        resetn_in_reg<='1';
		  resetn_in_reg1<='1';
		  resetn_in_reg2<='1';  
 	    elsif (clk'event and clk = '1') then
 	      resetn_in_reg<=resetn_in;
			resetn_in_reg1<=resetn_in_reg;
			resetn_in_reg2<=resetn_in_reg1;
 	    end if;
    end process;
	 
	rstn_pulse_out<='0' when resetn_in_reg2='1' and   resetn_in_reg1='0' else '1';
  
end arch;   




