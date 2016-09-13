-- ----------------------------------------------------------------------------	
-- FILE: 	singl_clk_with_ref_test.vhd
-- DESCRIPTION:	Counts clock transitions for defined time period
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
entity singl_clk_with_ref_test is
  port (
        --input ports 
        refclk       	: in std_logic;
        reset_n   		: in std_logic;
		  clk0				: in std_logic;
		  
		  test_en			: in std_logic;
		  test_cnt0			: out std_logic_vector(23 downto 0);
		  test_complete	: out std_logic;
		  test_pass_fail	: out std_logic
     
        );
end singl_clk_with_ref_test;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of singl_clk_with_ref_test is
--declare signals,  components here
signal cnt_ref_clk 			: unsigned (23 downto 0);
signal cnt_ref_clk_en		: std_logic; 
signal cnt_clk0				: unsigned (23 downto 0);
signal cnt_clk_en				: std_logic; 
signal test_en_reg			: std_logic_vector(1 downto 0);

signal cnt_clk0_en_reg0, cnt_clk0_en_reg1 : std_logic;


type state_type is (idle, count, count_end);

signal current_state, next_state : state_type;

  
begin

-- ----------------------------------------------------------------------------
-- test complete signal
-- ----------------------------------------------------------------------------
process(current_state) begin
	if(current_state = count_end) then
		test_complete<='1';
	else
		test_complete<='0';
	end if;
end process;

-- ----------------------------------------------------------------------------
-- reference counter enable
-- ----------------------------------------------------------------------------
process(current_state) begin
	if(current_state = count) then
		cnt_ref_clk_en<='1';
	else
		cnt_ref_clk_en<='0';
	end if;
end process;

-- ----------------------------------------------------------------------------
-- clock cycle counter in ref_clk domain
-- ----------------------------------------------------------------------------
  process(reset_n, refclk)
    begin
      if reset_n='0' then
        cnt_ref_clk<=(others=>'0'); 
 	    elsif (refclk'event and refclk = '1') then
 	      if cnt_ref_clk_en='1' then 
				cnt_ref_clk<=cnt_ref_clk+1;
			else 
				cnt_ref_clk<=(others=>'0');
			end if;
 	    end if;
    end process;
	 
-- ----------------------------------------------------------------------------
--state machine
-- ----------------------------------------------------------------------------

fsm_f : process(refclk, reset_n)begin
	if(reset_n = '0')then
		current_state <= idle;
		test_en_reg<=(others=>'0');
	elsif(refclk'event and refclk = '1')then 
		current_state <= next_state;
		test_en_reg(0)<=test_en;
		test_en_reg(1)<=test_en_reg(0);
	end if;	
end process;


-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, test_en_reg(1), cnt_ref_clk) begin
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
				if cnt_ref_clk>=16777210 then 
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


process(current_state) begin
	if(current_state = count) then
		cnt_clk_en<='1';
	else
		cnt_clk_en<='0';
	end if;
end process;

-- ----------------------------------------------------------------------------
-- clock cycle counter in clk0 domain
-- ----------------------------------------------------------------------------
  process(test_en, clk0)
    begin
      if test_en='0' then
			cnt_clk0<=(others=>'0');
			cnt_clk0_en_reg0<='0';
			cnt_clk0_en_reg1<='0';
 	    elsif (clk0'event and clk0 = '1') then
			cnt_clk0_en_reg0<=cnt_clk_en;
			cnt_clk0_en_reg1<=cnt_clk0_en_reg0;
 	      if cnt_clk0_en_reg1='1' then 
				cnt_clk0<=cnt_clk0+1;
			else 
				cnt_clk0<=cnt_clk0;
			end if;
 	    end if;
    end process;
	 

test_cnt0<=std_logic_vector(cnt_clk0);


	 
end arch;





