-- ----------------------------------------------------------------------------	
-- FILE: 	transition_count.vhd
-- DESCRIPTION:	Counts signal transitions
-- DATE:	Sep 5, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity transition_count is
  port (
        --input ports 
			clk				: in std_logic;
			reset_n   		: in std_logic;
			trans_wire		: in std_logic;
		  
			test_en			: in std_logic;
			test_cnt			: out std_logic_vector(15 downto 0);
			test_complete	: out std_logic;
			test_pass_fail	: out std_logic
     
        );
end transition_count;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of transition_count is
--declare signals,  components here
signal trans_wire_reg : std_logic_vector(2 downto 0);
signal high_trans		: std_logic;
signal low_trans		: std_logic;
signal trans_cnt		: unsigned(15 downto 0);

signal test_en_reg	: std_logic_vector(1 downto 0);


  
begin

-- ----------------------------------------------------------------------------
-- Register chain to capture low to high and high to low transitions
-- ----------------------------------------------------------------------------
process(reset_n, clk)
begin 
	if reset_n='0' then
		trans_wire_reg<=(others=>'0');
	elsif (clk'event and clk='1') then
		trans_wire_reg(0)<=trans_wire;
		trans_wire_reg(1)<=trans_wire_reg(0);
		trans_wire_reg(2)<=trans_wire_reg(1);
	end if;
end process;

high_trans	<= '1' when trans_wire_reg(2 downto 1)="01" else '0';
low_trans	<= '1' when trans_wire_reg(2 downto 1)="10" else '0';

-- ----------------------------------------------------------------------------
-- To count transitions
-- ----------------------------------------------------------------------------
process(reset_n, clk)
begin 
	if reset_n='0' then
		test_en_reg<=(others=>'0');
		trans_cnt<=(others=>'0');
	elsif (clk'event and clk='1') then
		test_en_reg(0)<=test_en;
		test_en_reg(1)<=test_en_reg(0);
		if test_en_reg(1)='1' then
			if high_trans='1' or low_trans='1' then 
				trans_cnt<=trans_cnt+1;
			else
				trans_cnt<=trans_cnt;
			end if;
		else 
			trans_cnt<=(others=>'0');
		end if;
	end if;
end process;

test_cnt<=std_logic_vector(trans_cnt);
test_complete<=test_en_reg(1);
test_pass_fail<='0';


end arch;





