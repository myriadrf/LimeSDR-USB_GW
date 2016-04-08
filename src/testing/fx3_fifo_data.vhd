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
entity fx3_fifo_data is
  port (
        --input ports 
        clk       : in std_logic;
        reset_n   : in std_logic;
		  wrusedw	: in std_logic_vector(11 downto 0);
		  wrreq		: out std_logic;
		  out_data	: out std_logic_vector(63 downto 0)

        --output ports 
        
        );
end fx3_fifo_data;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of fx3_fifo_data is
--declare signals,  components here
signal cnt : unsigned (31 downto 0);
signal data_h : unsigned(31 downto 0);
signal data_l : unsigned(31 downto 0);
signal wrreq_sig	: std_logic; 

  
begin


  process(reset_n, clk)
    begin
      if reset_n='0' then
        wrreq_sig<='0'; 
		  cnt<=(others=>'0');
 	    elsif (clk'event and clk = '1') then
 	      if unsigned(wrusedw) < 2000 then 
				wrreq_sig<='1';
			else 
				wrreq_sig<='0';
			end if;
			
			if wrreq_sig='1' then 
				cnt<=cnt+2;
			else 
				cnt<=cnt;
			end if;
 	    end if;
    end process;
	 
	 process(cnt)
	 begin
		data_h<=cnt+1;
	end process;
	 
	 
	 out_data<=std_logic_vector(data_h) & std_logic_vector(cnt);
	 wrreq<=wrreq_sig;
  
end arch;   




