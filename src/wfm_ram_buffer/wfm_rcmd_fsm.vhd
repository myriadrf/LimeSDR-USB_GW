-- ----------------------------------------------------------------------------	
-- FILE: 	wfm_rcmd_fsm.vhd
-- DESCRIPTION:	describe
-- DATE:	June 20, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity wfm_rcmd_fsm is
	generic(
			dev_family			: string  := "Cyclone IV E"; 
			wfm_outfifo_size	: integer := 11;
			addr_size			: integer := 24;
			lcl_burst_length	: integer := 2
);
  port (
      --input ports 
		rcmd_clk					: in std_logic;
		rcmd_reset_n			: in std_logic;
		rcmd_rdy					: in std_logic;
		rcmd_addr				: out std_logic_vector(addr_size-1 downto 0);
		rcmd_wr					: out std_logic;
		rcmd_brst_en			: out std_logic; --1- reads in burst, 0- single read

		wcmd_last_addr			: in std_logic_vector(addr_size-1 downto 0);
 
		wfm_load					: in std_logic;
		wfm_play_stop			: in std_logic -- 1- play, 0- stop
        
        );
end wfm_rcmd_fsm;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of wfm_rcmd_fsm is
--declare signals,  components here
signal wfm_load_reg : std_logic_vector(2 downto 0);
signal wfm_play_stop_reg	: std_logic_vector(2 downto 0);
signal wfm_load_int	: std_logic;
signal wcmd_last_addr_latch,	wcmd_last_addr_reg0, wcmd_last_addr_reg1	: std_logic_vector(addr_size-1 downto 0);
signal wcmd_last_addr_even : std_logic_vector(addr_size-1 downto 0);  

type state_type is (idle, check_rdy, burst_rd, last_burst,rd, rd_stop);


signal current_state, next_state : state_type;

signal rd_addr : unsigned(addr_size-1 downto 0);

signal rcmd_wr_int : std_logic;
signal rcmd_brst_en_int	: std_logic;

  
begin


-- ----------------------------------------------------------------------------
-- To lacth last write command address
-- ----------------------------------------------------------------------------
process(rcmd_reset_n, rcmd_clk) is 
	begin 
		if rcmd_reset_n='0' then 
			wfm_load_reg<=(others=>'0');
			wfm_play_stop_reg<=(others=>'0');
			wcmd_last_addr_reg0<=(others=>'0');
			wcmd_last_addr_reg1<=(others=>'0');
		elsif (rcmd_clk'event and rcmd_clk='1') then
			wfm_load_reg<=wfm_load_reg(1 downto 0) & wfm_load;
			wfm_play_stop_reg<=wfm_play_stop_reg(1 downto 0) & wfm_play_stop;
			wcmd_last_addr_reg0<=wcmd_last_addr;
			wcmd_last_addr_reg1<=wcmd_last_addr_reg0;
			if wfm_load_reg(2 downto 1)="10" then --latch on falling edge
				wcmd_last_addr_latch<=wcmd_last_addr_reg1;
			else 
				 wcmd_last_addr_latch<=wcmd_last_addr_latch;
			end if;
		end if;
end process;

wcmd_last_addr_even<=wcmd_last_addr_latch(addr_size-1 downto 1) & '0';

-- ----------------------------------------------------------------------------
-- Read address counter
-- ----------------------------------------------------------------------------
process(rcmd_reset_n, rcmd_clk) is 
	begin 
		if rcmd_reset_n='0' then 
			rd_addr<=(others=>'0');
		elsif (rcmd_clk'event and rcmd_clk='1') then
			if rcmd_wr_int='1' then 
				if current_state=burst_rd then 
					rd_addr<=rd_addr+2;
				elsif current_state=rd then 
					rd_addr<=(others=>'0');	
				else 
					rd_addr<=rd_addr;
				end if;
			elsif current_state=last_burst then 
				rd_addr<=(others=>'0');		
			else 
				rd_addr<=rd_addr;
			end if;
		end if;
end process;

rcmd_addr<=std_logic_vector(rd_addr);


-- ----------------------------------------------------------------------------
--Read command write signal
-- ----------------------------------------------------------------------------
process(current_state, rcmd_rdy)
begin
	--if (current_state=burst_rd or current_state=rd or current_state=last_burst) and rcmd_rdy='1' then 
	if (current_state=burst_rd or current_state=rd) and rcmd_rdy='1' then 
		rcmd_wr_int<='1';
	else 
		rcmd_wr_int<='0';
	end if;
end process;

rcmd_wr<=rcmd_wr_int;

-- ----------------------------------------------------------------------------
--Read burst enable signal
-- ----------------------------------------------------------------------------
process(current_state)
begin
	--if current_state=burst_rd  or current_state=last_burst then 
	if current_state=burst_rd  then 
		rcmd_brst_en_int<='1';
	else 
		rcmd_brst_en_int<='0';
	end if;
end process;

rcmd_brst_en<=rcmd_brst_en_int;


-- ----------------------------------------------------------------------------
--state machine
-- ----------------------------------------------------------------------------

fsm_f : process(rcmd_clk, rcmd_reset_n)begin
	if(rcmd_reset_n = '0')then
		current_state <= idle;
	elsif(rcmd_clk'event and rcmd_clk = '1')then 
		current_state <= next_state;
	end if;	
end process;

-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, wfm_load_reg(2 downto 1), rcmd_rdy, wfm_play_stop_reg(2), rd_addr, wcmd_last_addr_even,
				wcmd_last_addr_latch(0)) begin
	next_state <= current_state;
	case current_state is
	  
		when idle => --idle state 
			if wfm_load_reg(2 downto 1)="10" then 
				next_state<=check_rdy;
			else 
				next_state<=idle;
			end if;

		when check_rdy => --check that RD command fifo is ready to accept commands
			if rcmd_rdy='1' and wfm_play_stop_reg(2)='1' then 
				next_state<=burst_rd;
			else 
				next_state<=check_rdy;
			end if;

		when burst_rd => 	--burst read command
			if rcmd_rdy='1' then 
					if rd_addr>=unsigned(wcmd_last_addr_even)-2 then 
						if wcmd_last_addr_latch(0)='1' then
							next_state<=rd; 
						else 
							next_state<=last_burst;
						end if;
					else 
						if wfm_play_stop_reg(2)='0' then
							next_state<=rd_stop;
						else 
							next_state<=burst_rd;
						end if;
					end if;
			else 
				next_state<=burst_rd;
			end if;

--			if rcmd_rdy='1' then 
--				if wfm_play_stop_reg(2)='1' then
--					if rd_addr>=unsigned(wcmd_last_addr_even)-2 then 
--						if wcmd_last_addr_latch(0)='1' then
--							next_state<=rd; 
--						else 
--							next_state<=last_burst;
--						end if;
--					else 
--						next_state<=burst_rd;
--					end if;
--				else 
--					next_state<=rd_stop;
--				end if;
--			else 
--				next_state<=burst_rd;
--			end if;

		when last_burst =>	--last burst command to reset address
			if rcmd_rdy='1' then 
				if  wfm_play_stop_reg(2)='1' then 
					next_state<=burst_rd;
				else 
					next_state<=check_rdy;
				end if;
			else 
				next_state<=last_burst;
			end if; 

		when rd => 			-- non burst read command
			if rcmd_rdy='1' then 
				if  wfm_play_stop_reg(2)='1' then 
					next_state<=burst_rd;
				else 
					next_state<=check_rdy;
				end if;
			else 
				next_state<=rd;
			end if;
		
		when rd_stop =>	--stop reading 
			if wfm_load_reg(2 downto 1)="01" then 
				next_state<=idle;
			elsif wfm_play_stop_reg(2)='1' then 
				next_state<=burst_rd;
			else 
				next_state<=rd_stop;
			end if;
			
		when others => 
			next_state<=idle;

	end case;
end process;

  
end arch;   






