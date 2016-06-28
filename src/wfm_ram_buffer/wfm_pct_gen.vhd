-- ----------------------------------------------------------------------------	
-- FILE: 	wfm_pct_gen.vhd
-- DESCRIPTION:	describe
-- DATE:	June 21, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity wfm_pct_gen is
	generic(
		dev_family				: string  := "Cyclone IV E"; 
		wfm_infifo_size		: integer := 11;
		data_width				: integer := 32
);
  port (
      --input ports 
      clk						: in std_logic;
      reset_n					: in std_logic;
		wfm_load					: in std_logic; 
		wfm_play_stop			: in std_logic; -- 1- play, 0- stop
		wfm_data					: out std_logic_vector(data_width-1 downto 0);
		wfm_wr					: out std_logic;
		wfm_infifo_wrusedw 	: in std_logic_vector(wfm_infifo_size-1 downto 0);
		payload_size			: in std_logic_vector(15 downto 0);
		n_packets				: in std_logic_vector(15 downto 0)
      --output ports 
        
        );
end wfm_pct_gen;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of wfm_pct_gen is
--declare signals,  components here
type state_type is (idle, head0, head1, head2, head3, payload, check_n_packets, check_fifo, wait_load);

signal current_state, next_state : state_type;

signal wfm_load_reg 	: std_logic_vector(2 downto 0);
signal payload_cnt	: unsigned (31 downto 0);
signal pct_cnt			: unsigned (15 downto 0);
type nco_array is array (0 to 5) of std_logic_vector(31 downto 0);
signal nco_sig			: nco_array;
signal data_cnt		: unsigned(2 downto 0);

  
begin


nco_sig(0)<=x"FF0007FF";
nco_sig(1)<=x"F0000007";
nco_sig(2)<=x"7FF0007F";
nco_sig(3)<=x"00000800";
nco_sig(4)<=x"00000008";
nco_sig(5)<=x"80000080";

-- ----------------------------------------------------------------------------
--input registers
-- ----------------------------------------------------------------------------
process(reset_n, clk)
    begin
      if reset_n='0' then
        wfm_load_reg<=(others=>'0');  
 	    elsif (clk'event and clk = '1') then
 	      wfm_load_reg<=wfm_load_reg(1 downto 0) & wfm_load;
 	    end if;
    end process;

-- ----------------------------------------------------------------------------
--payload counter
-- ----------------------------------------------------------------------------
process(reset_n, clk)
    begin
      if reset_n='0' then
        payload_cnt<=(others=>'0');  
 	    elsif (clk'event and clk = '1') then
			if current_state=payload then 
 	      	payload_cnt<=payload_cnt+1;
			else
				payload_cnt<=(others=>'0');
			end if;  
 	    end if;
    end process;
	 
-- ----------------------------------------------------------------------------
--packet counter
-- ----------------------------------------------------------------------------	 
process(reset_n, clk)
    begin
      if reset_n='0' then
        pct_cnt<=(others=>'0');  
 	    elsif (clk'event and clk = '1') then
			if current_state=check_n_packets then 
 	      	pct_cnt<=pct_cnt+1;
			elsif current_state=wait_load then 
				pct_cnt<=(others=>'0');
			else
				pct_cnt<=pct_cnt;
			end if;  
 	    end if;
    end process;	 
	 
	 
	 
-- ----------------------------------------------------------------------------
--data counter
-- ----------------------------------------------------------------------------
process(reset_n, clk)
    begin
      if reset_n='0' then
        data_cnt<=(others=>'0');  
 	    elsif (clk'event and clk = '1') then
			if current_state=payload then 
				if data_cnt<5 then 
					data_cnt<=data_cnt+1;
				else 
					data_cnt<=(others=>'0');
				end if;
			else
				data_cnt<=(others=>'0');
			end if;  
 	    end if;
    end process;

-- ----------------------------------------------------------------------------
--write signal
-- ----------------------------------------------------------------------------
process(current_state)
begin
	if (current_state=head0 or current_state=head1 or current_state=head2 or current_state=head3 or current_state=payload ) then 
		wfm_wr<='1';
	else 
		wfm_wr<='0';
	end if;	
end process;

-- ----------------------------------------------------------------------------
--data mux
-- ----------------------------------------------------------------------------
process(current_state, payload_cnt, data_cnt, nco_sig)
begin
	if (current_state=head0) then
		wfm_data<=x"00" & payload_size & x"20"; --std_logic_vector(to_unsigned(payload_size, wfm_data'length));
	elsif (current_state=head1) then 
		wfm_data<=(others=>'1');
	elsif (current_state=head2) then
 		wfm_data<=(others=>'0');
	elsif (current_state=head3) then 
		wfm_data<=(others=>'1');		
	elsif (current_state=payload) then 
		wfm_data<=nco_sig(to_integer(data_cnt));
	else 
		 wfm_data<=x"55555555";
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
fsm : process(current_state, wfm_load_reg(2), wfm_infifo_wrusedw, payload_cnt, pct_cnt, n_packets, payload_size) begin
	next_state <= current_state;
	case current_state is
	  
		when idle => --idle state
			if wfm_load_reg(2)='1' and unsigned(wfm_infifo_wrusedw)=0 then
				next_state<=head0; 
			else 
				next_state<=idle;
			end if; 

		when head0 => 
			next_state<=head1; 

		when head1 =>
			next_state<=head2;
  
		when head2 =>
			next_state<=head3;
  
		when head3 => 
			next_state<=payload; 

		when payload =>
			if payload_cnt< unsigned(payload_size)*8/32-1 then
				next_state<=payload;
			else 
				next_state<=check_n_packets;
			end if;
			
		when check_n_packets => 
			if pct_cnt<unsigned(n_packets) then
				next_state<=check_fifo;			
			else 
				next_state<=wait_load;
			end if;
			
		when check_fifo => 
			if unsigned(wfm_infifo_wrusedw)<7172 then 
				next_state<=head0;
			else 
				next_state<=check_fifo;
			end if;

		when wait_load => 
			if wfm_load_reg(2)='0' then 
				next_state<=idle;
			else 
				next_state<=wait_load;
			end if;

		when others => 
			next_state<=idle;
	end case;
end process;
  
end arch;   






