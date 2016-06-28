-- ----------------------------------------------------------------------------	
-- FILE: 	ddr2_cmd_fifo_tst.vhd
-- DESCRIPTION:	describe
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
entity ddr2_cmd_fifo_tst is
generic(
			cntrl_rate			: integer := 1; --1 - full rate, 2 - half rate
			cntrl_bus_size		: integer := 16;
			addr_size			: integer := 24;
			lcl_burst_length	: integer := 2;
 			cmd_fifo_size		: integer := 9;
			test_lenqth			: integer := 512
);
  port (
      --input ports 
      clk       			: in std_logic;
      reset_n   			: in std_logic;
		en						: in std_logic;

		test_type			: in std_logic; --1 - sequential write and read, 0 - write then read

		cmd_wclk				: out std_logic;
		cmd_wrrdy			: in std_logic;
		cmd_wraddr			: out std_logic_vector(addr_size-1 downto 0);
		cmd_wr				: out std_logic;
		cmd_wrbrst_en		: out std_logic; --1- writes in burst, 0- single write
		cmd_wrdata			: out std_logic_vector(cntrl_bus_size*2*cntrl_rate-1 downto 0);
		cmd_rclk				: out std_logic;
		cmd_rdrdy			: in std_logic;
		cmd_rdaddr			: out std_logic_vector(addr_size-1 downto 0);
		cmd_rd				: out std_logic;
		cmd_rdbrst_en		: out std_logic --1- reads in burst, 0- single read

        );
end ddr2_cmd_fifo_tst;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of ddr2_cmd_fifo_tst is
--declare signals,  components here
signal waddr			: unsigned(addr_size-1 downto 0);
signal addr				: unsigned(addr_size-1 downto 0);
--lfsr signals
signal lfsr_en		: std_logic;
signal lfsr_data	: std_logic_vector(cntrl_bus_size*2*cntrl_rate-1 downto 0);

--cmd signals
signal cmd_wr_s	: std_logic;
signal cmd_rd_s	: std_logic;  


type state_type is (idle, sequential_wr, sequential_rd, wr_then_rd, rd_then_wr, rst_addr, rst_addr0);
signal current_state, next_state : state_type; 

component LFSR is
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
end component;

  
begin

cmd_wclk<=clk;
cmd_rclk<=clk;


-- ----------------------------------------------------------------------------
-- address generation
-- ----------------------------------------------------------------------------
  process(reset_n, clk)
    begin
      if reset_n='0' then
			addr<=(others=>'0');
      elsif (clk'event and clk = '1') then
			if current_state=rst_addr or current_state=rst_addr0 then
				addr<=(others=>'0');
			else
				if cmd_wr_s='1' or cmd_rd_s='1' then 
					if current_state=sequential_rd and test_type='1' then 
						addr<=addr+2;
					else 
						addr<=addr+1;
					end if;
				else 
					addr<=addr;
				end if;
			end if;	
		end if;
    end process;

-- ----------------------------------------------------------------------------
-- write cmd generation
-- ----------------------------------------------------------------------------
process(current_state) begin
	if(current_state = sequential_wr and cmd_wrrdy='1' ) then
		cmd_wr_s<='1';
	else
		cmd_wr_s<='0';
	end if;
end process;

-- ----------------------------------------------------------------------------
-- read cmd generation
-- ----------------------------------------------------------------------------
process(current_state) begin
	if(current_state = sequential_rd and cmd_rdrdy='1' ) then
		cmd_rd_s<='1';
	else
		cmd_rd_s<='0';
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
fsm : process(current_state, addr, en) begin
	next_state <= current_state;
	case current_state is
	  
		when idle => 			--idle state, wait for enable, and determine test type
		if en='1' then 
			next_state<=sequential_wr; 
		else 
			next_state<=idle; 
		end if;

		when sequential_wr =>		--write from 0 to specified address
			if addr<test_lenqth-1 then 
				next_state<=sequential_wr;
			else
				next_state<=rst_addr;
			end if;

		when rst_addr => 
			next_state<=sequential_rd;
		
		when sequential_rd =>		--read from 0 to specified address 
			if (addr<test_lenqth-2 and test_type='1') or (addr<test_lenqth-1 and test_type='0') then 
				next_state<=sequential_rd;
			else
				next_state<=rst_addr0;
			end if;	

		when rst_addr0 => 
			next_state<=rst_addr0;

		when others => 
			next_state<=idle;
	end case;
end process;


lfsr_en			<= cmd_wr_s;
cmd_wraddr		<= std_logic_vector(addr);
cmd_wr			<= cmd_wr_s;
cmd_wrbrst_en	<= '1' when test_type='1' else '0';
cmd_wrdata		<= lfsr_data;

cmd_rdaddr		<= std_logic_vector(addr);
cmd_rd			<= cmd_rd_s;
cmd_rdbrst_en	<= '1' when test_type='1' else '0';


-- ----------------------------------------------------------------------------
-- LFSR instance
-- ----------------------------------------------------------------------------
lfsr_inst : LFSR
	generic map(
			reg_with	=> cntrl_bus_size*2*cntrl_rate,
			seed		=> 32 --starting seed
)
	port map(
      clk       	=> clk, 
      reset_n   	=> reset_n, 
		en				=> lfsr_en, 
		data			=> lfsr_data     
        );
  
end arch;   






