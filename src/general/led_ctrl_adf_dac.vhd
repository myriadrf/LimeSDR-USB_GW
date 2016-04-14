-- ----------------------------------------------------------------------------	
-- FILE: 	led_ctrl_adf_dac.vhd
-- DESCRIPTION:	displays adf and dac status. If dac is used no led, if 
-- adf - adf locked green not locked red
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
entity led_ctrl_adf_dac is
  port (
        --input ports 
        clk       	: in std_logic;
        reset_n   	: in std_logic;
		  adf_muxout	: in std_logic;
		  dac_ss			: in std_logic;
		  adf_ss			: in std_logic;
		  led_g			: out std_logic;
		  led_r			: out std_logic

        --output ports 
        
        );
end led_ctrl_adf_dac;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of led_ctrl_adf_dac is
--declare signals,  components here
signal last_val : std_logic_vector (1 downto 0);

begin

  process(reset_n, clk)
    begin
      if reset_n='0' then
        last_val<="10"; 
 	    elsif (clk'event and clk = '1') then
 	      if dac_ss='0' then 
				last_val<="00";
			elsif	adf_ss='0' then 
				last_val<="10";
			else 
				last_val<=last_val;
			end if;			
 	    end if;
    end process;
	 
  
led_g<= '0' when last_val="00" else 
		  '1' when last_val="10" and adf_muxout='1' else 
		  '0';
		  
led_r<= '0' when last_val="00" else 
		  '1' when last_val="10" and adf_muxout='0' else 
		  '0';		  
  
  
end arch;





