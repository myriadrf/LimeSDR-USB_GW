-- ----------------------------------------------------------------------------	
-- FILE: 	capture_signal.vhd
-- DESCRIPTION:	captures signal an releases on rel signal
-- DATE:	July 8, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity capture_signal is
  port (
        --input ports 
        clk       : in std_logic;
        reset_n   : in std_logic;
		  in_sig		: in std_logic;
		  release	: in std_logic;
		  cap_sig	: out std_logic

        --output ports 
        
        );
end capture_signal;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of capture_signal is
--declare signals,  components here
signal in_sig_d0, in_sig_d1 	: std_logic;
signal release_d0, release_d1	: std_logic;

  type cap_state is (idle, hold);
  signal current_cap_state, next_cap_state :  cap_state;


  
begin
-------------------------------------------------------------------------------
--sync input signals to clk
-------------------------------------------------------------------------------
  process(reset_n, clk)
    begin
      if reset_n='0' then
        in_sig_d0<='0';
		  in_sig_d1<='0';
		  release_d0<='0';
		  release_d1<='0';
 	    elsif (clk'event and clk = '1') then
 	     in_sig_d0<=in_sig;
		  in_sig_d1<=in_sig_d0;
		  release_d0<=release;
		  release_d1<=release_d0;
 	    end if;
    end process;
	 
	 
	process(current_cap_state)begin
	if (current_cap_state=hold) then
			cap_sig <= '1'; 
	else
			cap_sig<='0';
	end if;	
end process;
	 
-------------------------------------------------------------------------------
--state machine
-------------------------------------------------------------------------------
fsm_f : process(clk, reset_n) begin
	if(reset_n = '0')then
		current_cap_state <= idle;
	elsif(clk'event and clk = '1')then 
		current_cap_state <= next_cap_state;
	end if;	
end process;

-------------------------------------------------------------------------------
--machine combo
-------------------------------------------------------------------------------
fsm : process(current_cap_state, in_sig_d1, release_d1) 
begin
    next_cap_state <= current_cap_state;
    
    case current_cap_state is
      when idle =>
			if in_sig_d1='1' then 
				next_cap_state<=hold;
			else
				next_cap_state<=idle;
			end if;
		when hold => 
			if release_d1='1' then 
				next_cap_state<=idle;
			else
				next_cap_state<=hold;
			end if;
		when others => 
			next_cap_state<=idle;
	end case;
end process; 
	 
	 
	 
  
end arch;   




