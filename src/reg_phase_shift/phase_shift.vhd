-- ----------------------------------------------------------------------------	
-- FILE: 	phase_shift.vhd
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
entity phase_shift is
	generic( reg_chain_size : integer := 16
				);

  port (
        --input ports 
        clk       : in std_logic;
        reset_n   : in std_logic;
		  clk_in		: in std_logic;
		  load_reg	: in std_logic;
		  reg_sel	: in std_logic_vector(7 downto 0);
		  clk_out	: out std_logic

        --output ports 
        
        );
end phase_shift;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of phase_shift is
--declare signals,  components here
signal reg_chain : std_logic_vector (reg_chain_size-1 downto 0);
--signal reg_chain_d0,  reg_chain_d1: std_logic_vector (reg_chain_size-1 downto 0);
signal reg_sel_int : std_logic_vector(7 downto 0);

component simple_reg is
  port (
        --input ports 
			clk      : in std_logic;
			reset_n  : in std_logic;
			d 			: in std_logic;
			q			: out std_logic
        
        );
end component; 

  
begin

gen_reg :
	for i in 0 to reg_chain_size-1 generate
			first : if i=0 generate  
				reg0 : simple_reg port map
					(clk, 
					reset_n, 
					clk_in, 
					reg_chain(i)
					);
			end generate first;

			other : if i>0 generate
		 		regx : simple_reg port map
					(clk, 
					reset_n, 
					reg_chain(i-1), 
					reg_chain(i)
					);
			end generate other;
				
end generate gen_reg;



--  process(reset_n, clk)
--    begin
--      if reset_n='0' then
--        reg_chain_d0<=(others=>'0');
-- 		  reg_chain_d1<=(others=>'0');
-- 	    elsif (clk'event and clk = '1') then
-- 	      reg_chain_d0<=reg_chain;
--			reg_chain_d1<=reg_chain_d0;
-- 	    end if;
--    end process;
	 
	 
	  process(reset_n, clk)
    begin
      if reset_n='0' then
			reg_sel_int<=(others=>'0');
 	    elsif (clk'event and clk = '1') then
			if load_reg = '1' then 
				reg_sel_int<=reg_sel;
			else 
				reg_sel_int<=reg_sel_int;
			end if;
 	    end if;
    end process; 
	 
	 
	 


--clk_out<=reg_chain_d1(to_integer(unsigned(reg_sel_int)));
clk_out<=reg_chain(to_integer(unsigned(reg_sel_int)));
  
end arch;   



