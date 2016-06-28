-- ----------------------------------------------------------------------------	
-- FILE: 	LFSR.vhd
-- DESCRIPTION:	Linear-feedback shift register
-- DATE:	June 15, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity LFSR is
	generic(
			reg_with	: integer := 32;
			seed		: integer := 32 --starting seed
);
	port (
      clk       	: in std_logic;
      reset_n   	: in std_logic;
		en				: in std_logic;
		data			: out std_logic_vector(reg_with-1 downto 0)     
        );
end LFSR;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of LFSR is
--declare signals,  components here
signal lfsr_data : std_logic_vector (reg_with-1 downto 0); 

  
begin


  process(reset_n, clk)
    begin
      if reset_n='0' then
			lfsr_data <= std_logic_vector(to_unsigned(seed, reg_with));  
      elsif (clk'event and clk = '1') then
			if en='1' then 
 	      	for i in 0 to reg_with-1 loop
					if i=0 then 
						lfsr_data(i)<=lfsr_data(reg_with-1);
					elsif	i>=2 and i<5 then 
						lfsr_data(i)<=lfsr_data(i-1) xor lfsr_data(reg_with-1);
					else
						lfsr_data(i)<=lfsr_data(i-1); 
					end if;
				end loop;
			else 
				lfsr_data<=lfsr_data;
			end if;
 	    end if;
    end process;

data<=lfsr_data;

  
end arch;   






