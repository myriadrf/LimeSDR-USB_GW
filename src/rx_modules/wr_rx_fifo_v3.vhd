
-- ----------------------------------------------------------------------------	
-- FILE: 	wr_rx_fifo_v3.vhd
-- DESCRIPTION:	writes fifo when right iq sel is captured
-- DATE:	June 17, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity wr_rx_fifo_v3 is
  generic(sample_wdth : integer:=12);
  port (
        --input ports 
			clk			: in std_logic;
			reset_n   	: in std_logic;
			fr_start		: in std_logic;
			mimo_en		: in std_logic; -- mimo mode enable -1, disable-0
			ch_en			: in std_logic_vector(1 downto 0); -- first bit ch A, second bit ch B
			en				: in std_logic;
			diq_h			: in std_logic_vector(sample_wdth downto 0);    --iqsel & diq
			diq_l			: in std_logic_vector(sample_wdth downto 0);    --iqsel & diq
			diq			: out std_logic_vector((2*sample_wdth)-1 downto 0); --diq
			fifo_wr		: out std_logic;
			fifo_wfull	: in std_logic
 
        );
end wr_rx_fifo_v3;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of wr_rx_fifo_v3 is
--declare signals,  components here
type state_type is (idle, wait_fr_start, fr_start_rec, wr_fifo, pack_data);
signal fifo_sig	: std_logic;
signal diq_l_reg	: std_logic_vector(sample_wdth downto 0);    --iqsel & diq

signal curretnt_state, next_state : state_type;
signal iq_sel		   	:  std_logic;
signal iq_sel_int  : std_logic;

signal diqin_h_reg		: std_logic_vector(sample_wdth downto 0);
signal diqin_l_reg		: std_logic_vector(sample_wdth downto 0);

  
begin
  
	iq_sel<=diqin_h_reg(sample_wdth) and diqin_l_reg(sample_wdth);
	iq_sel_int<=iq_sel when fr_start='1' else not iq_sel;
-- ----------------------------------------------------------------------------
--main state machine
-- ----------------------------------------------------------------------------
main_fsm_f : process(clk, reset_n) begin
	if(reset_n = '0')then
		curretnt_state <= idle;
		diq_l_reg<=(others=>'0');
		diqin_h_reg<=(others=>'0');
		diqin_l_reg<=(others=>'0');

	elsif(clk'event and clk = '1')then 
		diqin_h_reg<=diq_h;
		diqin_l_reg<=diq_l;
		curretnt_state <= next_state;
		--diq_l_reg<=diq_l;
		diq_l_reg<=diqin_l_reg;
	end if;	
end process;

-- ----------------------------------------------------------------------------
--main state machine combo
-- ----------------------------------------------------------------------------
main_fsm : process(curretnt_state, en, iq_sel, mimo_en, fr_start) begin
  	next_state <= curretnt_state;
  	case curretnt_state is
	
  		when idle =>					--wait for enable signal to start
			if en='1' then 
				next_state<=wait_fr_start;
			else 
				next_state<=idle;
			end if;
			
		when wait_fr_start =>		--wait for correct frame start 
			if iq_sel=fr_start then 
				next_state<=fr_start_rec;
			else 
				next_state<=wait_fr_start;
			end if;
			
		when fr_start_rec =>			-- skip one sample, because 1st sample allready missed when fr start detected
			if iq_sel=not fr_start then 
				if mimo_en='1' then  
				  next_state<=wr_fifo;
				else 
					next_state<=pack_data;
				end if;
			else 
				next_state<=wait_fr_start;
			end if;

		when wr_fifo => 				--write every clock cyclce if SISO mode.
			if en='0' then 
				next_state<=idle;
			else
			  if mimo_en='1' then  
				  next_state<=wr_fifo;
				else 
          next_state<=pack_data;
        end if; 
			end if;
			
		when pack_data =>			  -- writte every second clock cycle if SISO
		    		if en='0' then 
				    next_state<=idle;
				  else
				    next_state<=wr_fifo;
				   end if; 	
		when others=>
		end case;
		
end process;

-- ----------------------------------------------------------------------------
--fifo write signal formation 
-- ----------------------------------------------------------------------------
process(curretnt_state, ch_en, iq_sel_int, mimo_en)begin
	if (curretnt_state=wr_fifo and (ch_en="11" or mimo_en='0')) then
		  fifo_sig <= '1'; 
	elsif (curretnt_state=wr_fifo and ch_en="01") then
      fifo_sig <= iq_sel_int; 
	elsif (curretnt_state=wr_fifo and ch_en="10") then
      fifo_sig <= not iq_sel_int; 
	else 
		  fifo_sig <= '0';
	end if;	
end process;

fifo_wr<=fifo_sig and not fifo_wfull;

diq<=diqin_h_reg(11 downto 0) & diqin_l_reg(11 downto 0) when mimo_en='1' else 
     diqin_l_reg(11 downto 0) & diq_l_reg(11 downto 0);

  
end arch;  
