-- ----------------------------------------------------------------------------	
-- FILE: 	DDR2_arb.vhd
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
entity DDR2_arb is
	generic(
		cntrl_rate			: integer := 1; --1 - full rate, 2 - half rate
		cntrl_bus_size		: integer := 16;
		addr_size			: integer := 24;
		lcl_bus_size		: integer := 63;
		lcl_burst_length	: integer := 2;
		cmd_fifo_size		: integer := 9;
		outfifo_size		: integer :=10
		);
  port (
      clk       			: in std_logic;
      reset_n   			: in std_logic;

		wcmd_fifo_wraddr	: in std_logic_vector(addr_size downto 0);
		wcmd_fifo_wrdata	: in std_logic_vector(cntrl_bus_size*2*cntrl_rate-1 downto 0);
		wcmd_fifo_rdusedw	: in std_logic_vector(cmd_fifo_size-1 downto 0);
		wcmd_fifo_rdempty	: in std_logic;
		wcmd_fifo_rdreq	: out std_logic;
		rcmd_fifo_rdaddr	: in std_logic_vector(addr_size downto 0);
		rcmd_fifo_rdusedw	: in std_logic_vector(cmd_fifo_size-1 downto 0);
		rcmd_fifo_rdempty	: in std_logic;
		rcmd_fifo_rdreq	: out std_logic;
		outbuf_wrusedw		: in std_logic_vector(outfifo_size-1 downto 0);
		
		local_ready			: in std_logic;
		local_addr			: out std_logic_vector(addr_size-1 downto 0);
		local_write_req	: out std_logic;
		local_read_req		: out std_logic;
		local_burstbegin	: out std_logic;
		local_wdata			: out std_logic_vector(cntrl_bus_size*2*cntrl_rate-1 downto 0);
		local_be				: out std_logic_vector(4*cntrl_rate-1 downto 0);
		local_size			: out std_logic_vector(1 downto 0)	
        );
end DDR2_arb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of DDR2_arb is
--declare signals,  components here
type state_type is (idle, check_wcmd, check_rcmd, burst_wr, hold_wr, wr, burst_rd, rd, rd_hold);
signal current_state, next_state : state_type;

signal cmd_status		: std_logic_vector(1 downto 0);

signal wr_cnt 			: unsigned(2 downto 0);

signal burstbegin		: std_logic;
signal write_req 		: std_logic;
signal addr				: std_logic_vector(addr_size-1 downto 0);
signal addr_reg		: std_logic_vector(addr_size-1 downto 0);
signal size				: std_logic_vector(1 downto 0);

  
begin

cmd_status<=rcmd_fifo_rdempty & wcmd_fifo_rdempty;


-- ----------------------------------------------------------------------------
--burst size
-- ----------------------------------------------------------------------------
process(wcmd_fifo_wraddr, current_state, rcmd_fifo_rdaddr) begin
	if(wcmd_fifo_wraddr(addr_size)='1' and (current_state=burst_wr or  current_state=hold_wr or current_state=wr)) then
		size<=std_logic_vector(to_unsigned(lcl_burst_length, size'length));
	elsif(rcmd_fifo_rdaddr(addr_size)='1' and (current_state=burst_rd or current_state=rd_hold or current_state=rd)) then
		size<=std_logic_vector(to_unsigned(lcl_burst_length, size'length));
	else
		size<="01";
	end if;
end process;

-- ----------------------------------------------------------------------------
--burst signal
-- ----------------------------------------------------------------------------
process(current_state, cmd_status) begin
	if(current_state = burst_wr and cmd_status(0)='0') or (current_state=burst_rd and cmd_status(1)='0' ) then
		burstbegin<='1';
	else
		burstbegin<='0';
	end if;
end process;

-- ----------------------------------------------------------------------------
--write signal
-- ----------------------------------------------------------------------------
process(current_state, cmd_status(0)) begin
	if(current_state = burst_wr OR current_state = wr or current_state=hold_wr) and  cmd_status(0)='0' then
		write_req<='1';
	else
		write_req<='0';
	end if;
end process;

process(clk, reset_n)begin
	if(reset_n = '0')then
		wr_cnt<=(others=>'0');
		addr_reg<=(others=>'0');
	elsif(clk'event and clk = '1')then
		addr_reg<=addr;
		if local_ready='1' and write_req='1' then 
			if wr_cnt<lcl_burst_length-1 then 
				wr_cnt<=wr_cnt+1;
			else 
				wr_cnt<=(others=>'0');
			end if;
		elsif current_state=idle then 
			wr_cnt<=(others=>'0');
		else 
			wr_cnt<=wr_cnt;
		end if;
	end if;	
end process;

-- ----------------------------------------------------------------------------
--address signal
-- ----------------------------------------------------------------------------
process(current_state, wcmd_fifo_wraddr, rcmd_fifo_rdaddr, addr_reg, burstbegin) begin

	if(burstbegin='1' and current_state = burst_wr) then
		addr<=wcmd_fifo_wraddr(addr_size-1 downto 0);
	elsif (burstbegin='1' and current_state = burst_rd) then
		addr<=rcmd_fifo_rdaddr(addr_size-1 downto 0);
	else
		addr<=addr_reg;
	end if;

end process;

-- ----------------------------------------------------------------------------
--address signal
-- ----------------------------------------------------------------------------
process(current_state, cmd_status(1)) begin
		if (current_state=burst_rd or current_state=rd_hold) and cmd_status(1)='0'then 
			local_read_req<='1';
		else 
			local_read_req<='0';
		end if;
end process;

process(current_state, local_ready, cmd_status(1)) begin
		if (current_state=burst_rd or current_state=rd_hold) and local_ready='1' and cmd_status(1)='0' then 
			rcmd_fifo_rdreq<='1';
		else 
			rcmd_fifo_rdreq<='0';
		end if;
end process;


-- ----------------------------------------------------------------------------
--address signal
-- ----------------------------------------------------------------------------
process(write_req, local_ready) begin
	if(local_ready='1') then
		if write_req='1' then 
			wcmd_fifo_rdreq<='1';
		else 
			wcmd_fifo_rdreq<='0';
		end if;
	else
		wcmd_fifo_rdreq<='0';
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
fsm : process(current_state, cmd_status, wcmd_fifo_rdusedw, local_ready, wcmd_fifo_wraddr(addr_size), wr_cnt, outbuf_wrusedw) begin
	next_state <= current_state;
	case current_state is
	  
		when idle => 							--idle state, waiting for command
			if local_ready='1' then  
				if cmd_status(0)='0' and 
					((unsigned(wcmd_fifo_rdusedw)>=lcl_burst_length and wcmd_fifo_wraddr(addr_size)='1') 
					or wcmd_fifo_wraddr(addr_size)='0') then	
					next_state<=burst_wr;
				elsif	cmd_status="01" and unsigned(outbuf_wrusedw)<128 then 
					next_state<=burst_rd;
				else 
					next_state<=idle;
				end if; 
			else 
				next_state<=idle;
			end if;

		when burst_wr =>
			if wcmd_fifo_wraddr(addr_size)='1' then 
					next_state<=wr;
			else 
				if local_ready='1' and cmd_status(0)='0' and wcmd_fifo_wraddr(addr_size)='0' then 
					next_state<=burst_wr;
				elsif  local_ready='0'	then 	
					next_state<=hold_wr;
				else 
					next_state<=idle;
				end if;
			end if;

		when hold_wr =>
			if local_ready='1' then 
				if cmd_status(0)='0' and wcmd_fifo_wraddr(addr_size)='0' then 
					next_state<=burst_wr;
				else 
					next_state<=idle;
				end if;
			else
				next_state<=hold_wr; 
			end if; 
				
		when wr => 
			if local_ready='1' and wr_cnt=lcl_burst_length-1 then
				if wcmd_fifo_wraddr(addr_size)='1' and unsigned(wcmd_fifo_rdusedw)>lcl_burst_length and cmd_status(0)='0' then 
					next_state<=burst_wr;
				else 
					next_state<=idle;
				end if;
			else
				next_state<=wr; 
			end if;

		when burst_rd=>
			if local_ready='0' then 
				next_state<=rd_hold;
			else 
				if cmd_status="01" and unsigned(outbuf_wrusedw)<128 then
					next_state<=burst_rd;
				else 
					next_state<=idle;
				end if;
			end if;

		when rd_hold =>
			if local_ready='1' then 
				if cmd_status="01" and unsigned(outbuf_wrusedw)<128 then
					next_state<=burst_rd;
				else 
					next_state<=idle;
				end if;

			else 
				next_state<=rd_hold;
			end if;

		when rd => 
 

		when others => 
			next_state<=idle;

	end case;
end process;



local_burstbegin	<= burstbegin;
local_write_req	<= write_req;
local_addr			<= addr;
local_wdata			<= wcmd_fifo_wrdata;
local_be				<= (others=>'1');
local_size			<= size;



  
end arch;   






