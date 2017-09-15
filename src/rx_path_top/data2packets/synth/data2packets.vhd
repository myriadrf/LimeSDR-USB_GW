-- ----------------------------------------------------------------------------	
-- FILE: 	data2packets.vhd
-- DESCRIPTION:	Forms packets with provided header.
-- DATE:	Jan 27, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	

-- ----------------------------------------------------------------------------
-- Notes:
-- pct_size MIN 6words
-- pct_data words in packet = pct_size - 2 
-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity data2packets is
   generic (
      pct_size_w        : integer := 15
   );
   port (

      clk               : in std_logic;
      reset_n           : in std_logic;
      pct_size          : in std_logic_vector(pct_size_w-1 downto 0); --Whole packet size in 64b words (MIN 6words)
      pct_hdr_0         : in std_logic_vector(63 downto 0);
      pct_hdr_1         : in std_logic_vector(63 downto 0);
      pct_data          : in std_logic_vector(63 downto 0);
      pct_data_wrreq    : in std_logic;                     -- Do not assert when pct_state="11"
      pct_state         : out std_logic_vector(1 downto 0); -- 00 - Idle
                                                            -- 01 - Data capture
                                                            -- 10 - Last packet word accepted
                                                            -- 11 - Busy

      pct_wrreq         : out std_logic;
      pct_q             : out std_logic_vector(63 downto 0)
      
        );
end data2packets;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of data2packets is
--declare signals,  components here
signal reg_0      : std_logic_vector (63 downto 0); 
signal reg_1      : std_logic_vector (63 downto 0); 
signal reg_2      : std_logic_vector (63 downto 0); 

signal reg_0_ld   : std_logic;
signal reg_1_ld   : std_logic;
signal reg_2_ld   : std_logic;
signal reg_ld     : std_logic;

signal reg_0_en   : std_logic;
signal reg_1_en   : std_logic;
signal reg_2_en   : std_logic;
signal reg_en     : std_logic;

type state_type is (idle, s0, s1, s2, s3);
signal current_state, next_state : state_type;

signal pct_data_wr_cnt     : unsigned(pct_size_w-1 downto 0);
signal pct_data_wr_cnt_max : unsigned(pct_size_w-1 downto 0);
signal pct_data_wr_cnt_en  : std_logic;
signal pct_data_wr_cnt_clr : std_logic;
signal pct_end_cnt         : unsigned(7 downto 0);

signal pct_wrreq_int       : std_logic;
  
begin


pct_data_wr_cnt_en  <= pct_data_wrreq;
pct_data_wr_cnt_clr <= '1' when current_state = s1 else '0';

-- ----------------------------------------------------------------------------
-- Max packet write value
-- ----------------------------------------------------------------------------  
pct_data_wr_cnt_max_proc : process(reset_n, clk)
   begin
      if reset_n='0' then
         pct_data_wr_cnt_max <= (others=>'0');
      elsif (clk'event and clk = '1') then
         pct_data_wr_cnt_max <= unsigned(pct_size)-4;
      end if;
   end process;

-- ----------------------------------------------------------------------------
-- Delay packet write signal counter
-- ----------------------------------------------------------------------------     
pct_end_cnt_proc : process(reset_n, clk)
   begin
      if reset_n='0' then
         pct_end_cnt <= (others=> '0');
      elsif (clk'event and clk = '1') then
         if current_state = s2 then
            pct_end_cnt <= pct_end_cnt-1;
         else
            pct_end_cnt <= x"01";
         end if;
      end if;
   end process;
 
-- ----------------------------------------------------------------------------
-- Write packet counter
-- ----------------------------------------------------------------------------  
pct_data_wr_cnt_proc : process(reset_n, clk)
   begin
      if reset_n='0' then
         pct_data_wr_cnt <= (others=>'0');
      elsif (clk'event and clk = '1') then
         if pct_data_wr_cnt_clr = '1' then
            pct_data_wr_cnt <= (others=>'0');
         elsif pct_data_wr_cnt_en = '1' then 
            pct_data_wr_cnt <= pct_data_wr_cnt + 1;
         else 
            pct_data_wr_cnt <= pct_data_wr_cnt;
         end if;
      end if;
   end process;
   
  
   reg_ld <= '1' when current_state = idle AND pct_data_wrreq='1' else '0';
   reg_en <= '1' when current_state = S2 OR pct_data_wrreq='1' else '0';
   
-- ----------------------------------------------------------------------------
-- Register stage 0
-- ----------------------------------------------------------------------------   
   reg_0_ld <= reg_ld;
   reg_0_en <= reg_en;

 reg_stage_0 : process(reset_n, clk)
   begin
      if reset_n='0' then
         reg_0 <= (others=>'0');
      elsif (clk'event and clk = '1') then
         if reg_0_ld = '1' then 
            reg_0 <= pct_hdr_0;
         elsif reg_0_en ='1' then 
            reg_0 <= reg_1;
         else 
            reg_0 <= reg_0;
         end if;
      end if;
   end process;
   
-- ----------------------------------------------------------------------------
-- Register stage 1
-- ----------------------------------------------------------------------------  
   
reg_1_ld <= reg_ld;
reg_1_en <= reg_en;
   
 reg_stage_1 :  process(reset_n, clk)
   begin
      if reset_n='0' then
         reg_1 <= (others=>'0');
      elsif (clk'event and clk = '1') then
         if reg_1_ld = '1' then 
            reg_1 <= pct_hdr_1;
         elsif reg_1_en ='1' then 
            reg_1 <= reg_2;
         else 
            reg_1 <= reg_1;
         end if;
      end if;
   end process;
   
-- ----------------------------------------------------------------------------
-- Register stage 2
-- ----------------------------------------------------------------------------  
   
reg_2_ld <= pct_data_wrreq;
reg_2_en <= '0';
   
 reg_stage_2 :  process(reset_n, clk)
   begin
      if reset_n='0' then
         reg_2 <= (others=>'0');
      elsif (clk'event and clk = '1') then
         if reg_2_ld = '1' then 
            reg_2 <= pct_data;
         elsif reg_2_en ='1' then 
            reg_2 <= reg_2;
         else 
            reg_2 <= reg_2;
         end if;
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
fsm : process(current_state, pct_data_wrreq, pct_data_wr_cnt, pct_data_wr_cnt_max, pct_end_cnt) begin
	next_state <= current_state;
	case current_state is
	  
		when idle => -- state
         if pct_data_wrreq = '1' then 
            next_state <= s0;
         else 
            next_state <= idle;
         end if;
         
      when s0 => -- state
         if pct_data_wr_cnt = pct_data_wr_cnt_max AND pct_data_wrreq = '1' then 
            next_state <= s1;
         else 
            next_state <= s0;
         end if;
         
      when s1 => -- state
         if pct_data_wrreq = '1' then 
            next_state <= s2;
         else 
            next_state <= s1;
         end if;
        
      when s2 => -- state
         if pct_end_cnt = "00" then 
            next_state <= idle;
         else 
            next_state <= s2;
         end if;
            
		when others => 
			next_state <= idle;
	end case;
end process;

 pct_wrreq_int_proc : process(clk, reset_n)begin
	if(reset_n = '0')then
		pct_wrreq_int <= '0';
	elsif(clk'event and clk = '1')then 
		if pct_data_wrreq = '1' OR current_state = s2 then 
         pct_wrreq_int <= '1';
      else 
         pct_wrreq_int <= '0';
      end if;
	end if;	
end process;

-- ----------------------------------------------------------------------------
-- pct_state decoding
-- ----------------------------------------------------------------------------
process (current_state, pct_data_wrreq)
	begin
		case current_state is
			when idle =>
            pct_state <= "00";
            
			when s0=>
            pct_state <= "01";
            
			when s1=>
				if pct_data_wrreq = '1' then
               pct_state <= "10";
				else
               pct_state <= "01";
				end if;
            
			when s2=>
            pct_state <= "11";
            
         when others=> 
            pct_state <= "11";
            
		end case;
	end process;
   
pct_wrreq   <= pct_wrreq_int;
pct_q       <= reg_0;
  
end arch;   





