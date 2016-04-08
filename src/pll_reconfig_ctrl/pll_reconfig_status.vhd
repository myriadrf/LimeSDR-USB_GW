-- ----------------------------------------------------------------------------	
-- FILE: 	pll_reconfig_status.vhd
-- DESCRIPTION:	Shows when pll reconfiguration has been completed
-- DATE:	Mar 29, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pll_reconfig_status is
  port (
        --input ports 
        clk       			: in std_logic;
        reset_n   			: in std_logic;
		  reconfig_en			: in std_logic;
		  scandone				: in std_logic;
		  exclude_ps_status	: in std_logic;
		  ps_en					: in std_logic;
		  ps_status				: in std_logic;
        --output ports 		  
		  rcfig_complete		: out std_logic
		  
        );
end pll_reconfig_status;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pll_reconfig_status is
--declare signals,  components here
type state_type is (idle, reconfig_begin, wait_ps_begin, ps_begin, reconfig_complete);

signal current_state, next_state : state_type;

signal scandone_reg0, scandone_reg1 : std_logic;
signal scandone_fall	: std_logic;
--signal ps_en_reg0, ps_en_reg1 : std_logic;
--signal ps_en_rising	: std_logic;


  
begin

process(current_state) begin
	if(current_state = reconfig_complete ) then
		rcfig_complete<='1';
	else
		rcfig_complete<='0';
	end if;
end process;

-- ----------------------------------------------------------------------------
--state machine
-- ----------------------------------------------------------------------------

fsm_f : process(clk, reset_n)begin
	if(reset_n = '0')then
		current_state <= idle;
	elsif(clk'event and clk = '1')then 
		current_state <= next_state;
	end if;	
end process;

-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, reconfig_en, scandone_fall, ps_status, exclude_ps_status) begin
	next_state <= current_state;
	case current_state is
	  
		when idle => --idle state, wait for reconfiguration enable
			if reconfig_en='1' then
				next_state<=reconfig_begin;
			else 
				next_state<=idle;
			end if;
		when reconfig_begin=> --wait for reconfiguration complete
			if scandone_fall='1' then 
				if exclude_ps_status='0' then 
					next_state<=wait_ps_begin;
				else 
					next_state<=reconfig_complete;
				end if;
			else 
				next_state<=reconfig_begin;
			end if;
		when wait_ps_begin => --wait for phase shift enable
			if ps_status='1' then 
				next_state<=ps_begin;
			else
				next_state<=wait_ps_begin;
			end if;
		when ps_begin => 		--wait for phase shift complete
			if ps_status='0' then 
				next_state<=reconfig_complete;
			else 
				next_state<=ps_begin;
			end if;
		when reconfig_complete => --reconfig complete, wait for another reconfiguration
			if reconfig_en='0' then 
				next_state<=idle;
			else 
				next_state<=reconfig_complete;
			end if;
		when others => 
			next_state<=idle;
	end case;
end process;

process(reset_n, clk)
    begin
      if reset_n='0' then
        scandone_reg0<='0';
		  scandone_reg1<='0';
		  --ps_en_reg0<='0';
		  --ps_en_reg1<='0';
 	    elsif (clk'event and clk = '1') then
 	     scandone_reg0<=scandone;
		  scandone_reg1<=scandone_reg0;
		  --ps_en_reg0<=ps_en;
		  --ps_en_reg1<=ps_en_reg0;
 	    end if;
    end process;
	 
	 
scandone_fall 	<= '1' when scandone_reg0='0' and scandone_reg1='1' else '0';
--ps_en_rising	<= '1' when ps_en_reg0='1' and ps_en_reg1='0' else '0';
  
end arch;




