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
entity test_data_dd is
  port (
        --input ports 
        clk       : in std_logic;
        reset_n   : in std_logic;
		    fr_start	 : in std_logic;
		    mimo_en   : in std_logic;
		  
		    data_h		  : out std_logic_vector(12 downto 0);
		    data_l		  : out std_logic_vector(12 downto 0)

        --output ports 
        
        );
end test_data_dd;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of test_data_dd is
--declare signals,  components here
signal cnt_h : unsigned (9 downto 0);
signal cnt_l : unsigned (9 downto 0);
signal iq_sel	: std_logic;
signal iq_sel_out	: std_logic; 

  
begin

  process(reset_n, clk)
    begin
      if reset_n='0' then
		  cnt_h<=(others=>'0');
        cnt_l<=(others=>'0');
		  iq_sel<='0'; 
 	    elsif (clk'event and clk = '1') then
			iq_sel<= not iq_sel;
			cnt_l<=cnt_l+1;
 	      cnt_h<=cnt_h+1;
 	    end if;
    end process;
	 
iq_sel_out<= iq_sel when fr_start='0' else not iq_sel;

data_l<=iq_sel_out & "0" & std_logic_vector(cnt_l) & '0' when mimo_en='1' else iq_sel_out & "00" & std_logic_vector(cnt_l);
data_h<=iq_sel_out & "0" & std_logic_vector(cnt_h) & '1' when mimo_en='1' else iq_sel_out & "00" & std_logic_vector(cnt_h);
  
end arch;




