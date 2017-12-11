
-- ----------------------------------------------------------------------------	
-- FILE: 	unpack_64_to_64.vhd
-- DESCRIPTION:	unpacks bits from 63b words to 16 bit samples
-- DATE:	March 30, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity unpack_64_to_64 is
  port (
      --input ports 
      clk       		: in std_logic;
      reset_n   		: in std_logic;
		data_in_wrreq	: in std_logic;
		data64_in		: in std_logic_vector(63 downto 0);
		data64_out		: out std_logic_vector(127 downto 0);
		data_out_valid	: out std_logic
       
        );
end unpack_64_to_64;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of unpack_64_to_64 is
--declare signals,  components here
signal word128_0		      : std_logic_vector(127 downto 0);

signal word128_0_valid 	   : std_logic;

signal wr_cnt			      : unsigned(1 downto 0);
signal data64_in_reg			: std_logic_vector(63 downto 0);
  
begin


-- ----------------------------------------------------------------------------
-- Input data register
-- ----------------------------------------------------------------------------
  process(reset_n, clk)
    begin
      if reset_n='0' then
			data64_in_reg<=(others=>'0');
      elsif (clk'event and clk = '1') then
         if data_in_wrreq = '1' then 
				data64_in_reg <= data64_in;
         else 
            data64_in_reg <= data64_in_reg;
         end if;
 	    end if;
    end process;
    
-- ----------------------------------------------------------------------------
-- Write counter
-- ----------------------------------------------------------------------------
process(clk, reset_n) is 
	begin 
		if reset_n='0' then 
			wr_cnt<=(others=>'0');
		elsif (clk'event and clk='1') then
			if  data_in_wrreq='1' then 
				if wr_cnt < 1 then 
					wr_cnt<=wr_cnt+1;
				else 
					wr_cnt<=(others=>'0');
				end if;
			else
				wr_cnt<=wr_cnt;
			end if;
		end if;
end process;


-- ----------------------------------------------------------------------------
-- 64b word formation
-- ----------------------------------------------------------------------------
  process(reset_n, clk)
    begin
      if reset_n='0' then
			word128_0<=(others=>'0');
         word128_0_valid<='0';
      elsif (clk'event and clk = '1') then
         if wr_cnt=1 and data_in_wrreq='1' then 
				word128_0<=  data64_in & data64_in_reg;
            word128_0_valid<='1';
			else 
				word128_0<=word128_0;
            word128_0_valid<='0';
			end if;
 	    end if;
    end process;
    
    
data64_out     <= word128_0;
data_out_valid <= word128_0_valid;


 

end arch;   



