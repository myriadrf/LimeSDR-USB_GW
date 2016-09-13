-- ----------------------------------------------------------------------------	
-- FILE: 	clk_no_ref_test.vhd
-- DESCRIPTION:	Counts clock transitions with no reference clock
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
entity clk_no_ref_test is
  port (
        --input ports 
        clk       		: in std_logic;
        reset_n   		: in std_logic;
		  test_en			: in std_logic;
		  test_cnt			: out std_logic_vector(15 downto 0);
		  test_complete	: out std_logic;
		  test_pass_fail	: out std_logic
     
        );
end clk_no_ref_test;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of clk_no_ref_test is
--declare signals,  components here
signal cnt 			: unsigned (15 downto 0); 
signal cnt_en		: std_logic;	
signal test_en_reg			: std_logic_vector(1 downto 0);

type state_type is (idle, count, count_end);

signal current_state, next_state : state_type;

  
begin


-- ----------------------------------------------------------------------------
-- clock cycle counter
-- ----------------------------------------------------------------------------
  process(reset_n, clk)
    begin
      if reset_n='0' then
        cnt<=(others=>'0'); 
 	    elsif (clk'event and clk = '1') then
 	      if cnt_en='1' then 
				cnt<=cnt+1;
			else 
				cnt<=cnt; 
			end if;
 	    end if;
    end process;
	 
	 
process(current_state) begin
	if(current_state = count or current_state = count_end) then
		cnt_en<='1';
	else
		cnt_en<='0';
	end if;
end process;

process(current_state) begin
	if(current_state = count_end ) then
		test_complete<='1';
		test_pass_fail<='1';
	else
		test_complete<='0';
		test_pass_fail<='0';
	end if;
end process;	 
	 
-- ----------------------------------------------------------------------------
--state machine
-- ----------------------------------------------------------------------------

fsm_f : process(clk, reset_n)begin
	if(reset_n = '0')then
		current_state <= idle;
		test_en_reg<=(others=>'0');
	elsif(clk'event and clk = '1')then 
		current_state <= next_state;
		test_en_reg(0)<=test_en;
		test_en_reg(1)<=test_en_reg(0);
	end if;	
end process;


-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, test_en_reg(1), cnt) begin
	next_state <= current_state;
	case current_state is
	  
		when idle => 					--idle state
			if test_en_reg(1)='1' then 
				next_state<=count;
			else 
				next_state<=idle;
			end if;
		when count => 					--enable counting
			if test_en_reg(1)='1' then
				if cnt>=65535 then 
					next_state<=count_end;
				else 
					next_state<=count;
				end if;
			else 
				next_state<=idle;
			end if;
		when count_end => 			--counter overflow
			if test_en_reg(1)='0' then 
				next_state<=idle;
			else 
				next_state<=count_end;
			end if;				
		when others => 
			next_state<=idle;
	end case;
end process;


test_cnt<=std_logic_vector(cnt);
	 
  
end arch;





