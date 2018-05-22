-- ----------------------------------------------------------------------------	
-- FILE: 	p2d_wr_fsm.vhd
-- DESCRIPTION:	For decoding packets.
-- DATE:	March 31, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	

-- ----------------------------------------------------------------------------
-- Notes:
-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity p2d_wr_fsm is
   generic (
      N_BUFF            : integer := 4;   -- 2,4 valid values
      PCT_SIZE          : integer := 4096 -- Whole packet size in bytes
   );
   port (
      clk               : in std_logic;
      reset_n           : in std_logic;      
      
      in_pct_rdreq      : out std_logic;
      in_pct_data       : in std_logic_vector(127 downto 0);
      in_pct_rdy        : in std_logic;
      
      pct_hdr_0         : out std_logic_vector(63 downto 0);
      pct_hdr_0_valid   : out std_logic_vector(N_BUFF-1 downto 0);
      
      pct_hdr_1         : out std_logic_vector(63 downto 0);
      pct_hdr_1_valid   : out std_logic_vector(N_BUFF-1 downto 0);
      
      pct_data          : out std_logic_vector(127 downto 0);
      pct_data_wrreq    : out std_logic_vector(N_BUFF-1 downto 0);

      pct_buff_rdy      : in std_logic_vector(N_BUFF-1 downto 0)
      
        );
end p2d_wr_fsm;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of p2d_wr_fsm is
--declare signals,  components here

constant C_HEADER_POS         : integer := 0;

type state_type is (idle, switch_next_buff, rd_pct, wait_wr_end, check_next_buf, switch_current_buff);
signal current_state, next_state : state_type;  

signal current_buff_cnt       : unsigned(3 downto 0);
signal next_buff_cnt          : unsigned(3 downto 0);

signal rd_cnt                 : unsigned(15 downto 0);

signal current_buff_rdy       : std_logic;
signal next_buff_rdy          : std_logic;

signal in_pct_rdreq_int       : std_logic;

signal pct_data_wrreq_int     : std_logic;
signal pct_data_wrreq_cnt     : unsigned(15 downto 0);

begin
     
-- ----------------------------------------------------------------------------
-- Buffer selection process
-- ----------------------------------------------------------------------------   
   next_buff_sel_proc : process(clk, reset_n)
   begin
      if reset_n = '0' then 
         next_buff_cnt <= (others=>'0');
         next_buff_rdy <= '0';
      elsif (clk'event AND clk='1') then 
         if current_state = switch_next_buff then 
            if next_buff_cnt < N_BUFF - 1 then  
               next_buff_cnt <= next_buff_cnt + 1;
            else 
               next_buff_cnt <= (others=>'0');
            end if;
         else 
            next_buff_cnt <= next_buff_cnt;
         end if;
         
         next_buff_rdy <= pct_buff_rdy(to_integer(next_buff_cnt));
         
      end if;
   end process;
   
   current_buff_sel_proc : process(clk, reset_n)
   begin
      if reset_n = '0' then 
         current_buff_cnt <= (others=>'0');
         current_buff_rdy <= '0';
      elsif (clk'event AND clk='1') then 
         if current_state = check_next_buf then 
            current_buff_cnt <= next_buff_cnt;
         else 
            current_buff_cnt <= current_buff_cnt;
         end if;
         
         current_buff_rdy <= pct_buff_rdy(to_integer(current_buff_cnt));         
      end if;
   end process;
 
-- ----------------------------------------------------------------------------
-- Read counter
-- ---------------------------------------------------------------------------- 
   rdcnt_proc : process(clk, reset_n)
   begin
      if reset_n = '0' then 
         rd_cnt <= (others=>'0');
      elsif (clk'event AND clk='1') then 
         if current_state = rd_pct then 
            rd_cnt <= rd_cnt + 1;
         else 
            rd_cnt <= (others=>'0');
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
-- state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, current_buff_rdy, in_pct_rdy, rd_cnt,
               next_buff_rdy, pct_data_wrreq_int) begin
   next_state <= current_state;
   case current_state is
   
      when idle =>
         if current_buff_rdy = '1' AND in_pct_rdy = '1' then
            next_state <= switch_next_buff;
         else 
            next_state <= idle;
         end if;
         
      when switch_next_buff => 
         next_state <= rd_pct;
                  
      when rd_pct =>
         if rd_cnt < (PCT_SIZE*8)/pct_data'length-1 then 
            next_state <= rd_pct;
         else 
            next_state <= wait_wr_end;
         end if;
         
      when wait_wr_end => 
         if pct_data_wrreq_int = '0' then 
            next_state <= check_next_buf;
         else 
            next_state <= wait_wr_end;
         end if;
         
      when check_next_buf => 
         if next_buff_rdy = '1' then 
            next_state <= switch_current_buff;
         else 
            next_state <= check_next_buf;
         end if;
         
      when switch_current_buff => 
         next_state <= idle;
         
      when others => 
         next_state <= idle;
   end case;
end process;


-- ----------------------------------------------------------------------------
-- Write request signal and write counter
-- ----------------------------------------------------------------------------
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         pct_data_wrreq_int <= '0';
         pct_data_wrreq_cnt <= (others => '0');
      elsif (clk'event AND clk='1') then 
         pct_data_wrreq_int <= in_pct_rdreq_int;
         
         if pct_data_wrreq_int = '1' then 
            pct_data_wrreq_cnt <= pct_data_wrreq_cnt + 1;
         elsif current_state = idle then 
            pct_data_wrreq_cnt <= (others => '0');
         else 
            pct_data_wrreq_cnt <= pct_data_wrreq_cnt;
         end if;
      end if;
   end process;

-- ----------------------------------------------------------------------------
-- Output registers
-- ----------------------------------------------------------------------------

out_reg: process(clk, reset_n)
begin
   if reset_n = '0' then 
      in_pct_rdreq_int  <= '0';
      pct_hdr_0         <= (others=>'0');
      pct_hdr_0_valid   <= (others=>'0');  
      pct_hdr_1         <= (others=>'0');
      pct_hdr_1_valid   <= (others=>'0');
      pct_data          <= (others=>'0');
      pct_data_wrreq    <= (others=>'0');    
   elsif (clk'event AND clk='1') then
      -- Read request signal for FIFO where packet is stored
      if current_state = rd_pct then 
         in_pct_rdreq_int <= '1';
      else 
         in_pct_rdreq_int <= '0';
      end if;
      
      -- Packet header
      if pct_data_wrreq_int = '1' AND pct_data_wrreq_cnt = C_HEADER_POS then 
         pct_hdr_0         <= in_pct_data(63 downto 0);
         pct_hdr_1         <= in_pct_data(127 downto 64);
      end if;
      
      if pct_data_wrreq_int = '1' AND pct_data_wrreq_cnt = C_HEADER_POS then 
         pct_hdr_0_valid   <= (others=>'0');
         pct_hdr_0_valid(to_integer(current_buff_cnt))   <= '1';
   
         pct_hdr_1_valid   <= (others=>'0');
         pct_hdr_1_valid(to_integer(current_buff_cnt))   <= '1';
      else 
         pct_hdr_0_valid   <= (others=>'0');
         pct_hdr_1_valid   <= (others=>'0');
      end if;
      
      -- Packet data
      if pct_data_wrreq_int = '1' AND pct_data_wrreq_cnt > C_HEADER_POS then 
         pct_data         <= in_pct_data;
      end if;
      
      if pct_data_wrreq_int = '1' AND pct_data_wrreq_cnt > C_HEADER_POS then 
         pct_data_wrreq   <= (others=>'0');
         pct_data_wrreq(to_integer(current_buff_cnt))   <= '1';
      else 
         pct_data_wrreq   <= (others=>'0');
      end if;
      
   end if;
end process;


in_pct_rdreq <= in_pct_rdreq_int;

end arch;   





