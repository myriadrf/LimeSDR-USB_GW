-- ----------------------------------------------------------------------------	
-- FILE: 	wfm_wcmd_fsm.vhd
-- DESCRIPTION:	FSM for write commands
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
entity wfm_wcmd_fsm is
	generic(
			dev_family			: string  := "Cyclone IV E"; 
			wfm_infifo_size	: integer := 11;
			addr_size			: integer := 24;
			lcl_burst_length	: integer := 2
);
	port (
		wcmd_clk					: in std_logic;
		wcmd_reset_n			: in  std_logic;
		wcmd_rdy					: in std_logic;
		wcmd_addr				: out std_logic_vector(addr_size-1 downto 0);
		wcmd_wr					: out std_logic;
		wcmd_brst_en			: out std_logic; --1- writes in burst, 0- single write
		wcmd_last_addr			: out std_logic_vector(addr_size-1 downto 0);

		wfm_load					: in std_logic;
		wfm_load_ext			: out std_logic;
		wfm_play_stop			: in std_logic; -- 1- play, 0- stop

		wfm_infifo_rd			: out std_logic;
		wfm_infifo_rdusedw 	: in std_logic_vector(wfm_infifo_size-1 downto 0)
        
        );
end wfm_wcmd_fsm;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of wfm_wcmd_fsm is
--declare signals,  components here
type state_type is (idle, check_burst, burst_wr, check_wr, wr, burst_rd, rd);
signal current_state, next_state : state_type;

signal wrburst_cnt 			: unsigned(3 downto 0);
signal wr_address				: unsigned(addr_size-1 downto 0);
signal wr_address_latch		: unsigned(addr_size-1 downto 0);

signal wfm_load_reg0, wfm_load_reg1 : std_logic;
  
begin

wfm_load_ext<=wfm_load_reg1;

-- ----------------------------------------------------------------------------
--write burst counter
-- ----------------------------------------------------------------------------
process(wcmd_clk, wcmd_reset_n)begin
	if (wcmd_reset_n = '0')then
		wr_address_latch<=(others=>'0');
	elsif(wcmd_clk'event and wcmd_clk = '1')then 
		if wfm_load_reg0='0' and wfm_load_reg1='1' then --latch on falling edge
			wr_address_latch<=wr_address;
		else 
			wr_address_latch<=wr_address_latch;
		end if;
	end if;	
end process;

wcmd_last_addr<=std_logic_vector(wr_address_latch);


-- ----------------------------------------------------------------------------
-- command write signal and infifo read signal formation
-- ----------------------------------------------------------------------------
process(current_state)
begin 
	if current_state=burst_wr or current_state=wr then 
		wcmd_wr<='1';
		wfm_infifo_rd<='1'; 
	else 
		wcmd_wr<='0';
		wfm_infifo_rd<='0';
	end if;
end process;

-- ----------------------------------------------------------------------------
-- command burst write signal formation
-- ----------------------------------------------------------------------------
process(current_state)
begin 
	if current_state=burst_wr then 
		wcmd_brst_en<='1';
	else
		wcmd_brst_en<='0'; 
	end if;
end process;

-- ----------------------------------------------------------------------------
--write burst counter
-- ----------------------------------------------------------------------------
process(wcmd_clk, wcmd_reset_n)begin
	if (wcmd_reset_n = '0')then
		wrburst_cnt<=(others=>'0');
	elsif(wcmd_clk'event and wcmd_clk = '1')then 
		if current_state=burst_wr then
			if  wrburst_cnt<lcl_burst_length-1 then 
				wrburst_cnt<=wrburst_cnt+1;
			else 
				wrburst_cnt<=(others=>'0');
			end if;
		else 
			wrburst_cnt<=(others=>'0');
		end if;

	end if;	
end process;

-- ----------------------------------------------------------------------------
-- write address counter
-- ----------------------------------------------------------------------------
process(wcmd_clk, wcmd_reset_n)begin
	if (wcmd_reset_n = '0')then
		wr_address<=(others=>'0');
	elsif(wcmd_clk'event and wcmd_clk = '1')then 
		if wfm_load_reg0='0' and wfm_load_reg1='1' then
			wr_address<=(others=>'0');
		else
			if current_state=burst_wr or current_state=wr then
				wr_address<=wr_address+1;
			else 
				wr_address<=wr_address;
			end if; 
		end if;
	end if;	
end process;

wcmd_addr<=std_logic_vector(wr_address);

-- ----------------------------------------------------------------------------
--state machine
-- ----------------------------------------------------------------------------

fsm_f : process(wcmd_clk, wcmd_reset_n) begin
	if(wcmd_reset_n = '0')then
		current_state <= idle;
		wfm_load_reg0<='0';
		wfm_load_reg1<='0';
	elsif(wcmd_clk'event and wcmd_clk = '1')then 
		current_state <= next_state;
		wfm_load_reg0<=wfm_load;
		wfm_load_reg1<=wfm_load_reg0;
	end if;	
end process;

-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, wfm_load, wfm_infifo_rdusedw, wrburst_cnt, wcmd_rdy) begin
	next_state <= current_state;
	case current_state is
	  
		when idle => --idle state wait for enable signal
			if wfm_load='1' then
				next_state<=check_burst;
			else 	
				next_state<=idle;
			end if;

		when check_burst => 	--wait for incomming data
			if unsigned(wfm_infifo_rdusedw)>=lcl_burst_length and wcmd_rdy='1' then 
				next_state<=burst_wr;
			elsif unsigned(wfm_infifo_rdusedw)=lcl_burst_length-1 and wcmd_rdy='1' then
				next_state<=check_wr;
			else 
				next_state<=idle;
			end if;

		when check_wr=> 
			if unsigned(wfm_infifo_rdusedw)=lcl_burst_length-1 and wcmd_rdy='1' then
				next_state<=wr;
			else 
				next_state<=idle;
			end if;

		when burst_wr=> 	--burst write command
			if wrburst_cnt=lcl_burst_length-1 then 
				if unsigned(wfm_infifo_rdusedw)>lcl_burst_length*2 and wcmd_rdy='1' then 
					next_state<=burst_wr;
				else 
					next_state<=idle;
				end if;
			else 
				next_state<=burst_wr;
			end if;

		when wr=> 		--read command
			next_state<=idle;

		when others => 
			next_state<=idle;
	end case;
end process;


  
end arch;   





