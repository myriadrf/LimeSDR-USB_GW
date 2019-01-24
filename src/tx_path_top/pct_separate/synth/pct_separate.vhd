-- ----------------------------------------------------------------------------
-- FILE:          pct_separate_fsm.vhd
-- DESCRIPTION:   Module reads pct data stored in FIFO memory end separates them 
--                one by one packet
-- DATE:          12:17 PM Tuesday, January 15, 2019
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pct_separate_fsm is
   generic(
      g_DATA_WIDTH   : integer := 32
   );
   port (
      clk            : in  std_logic;
      reset_n        : in  std_logic;
      infifo_rdreq   : out std_logic;
      infifo_data    : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);
      infifo_rdempty : in  std_logic;
      pct_wrreq      : out std_logic;
      pct_data       : out std_logic_vector(g_DATA_WIDTH-1 downto 0);
      pct_wrempty    : in  std_logic;
      pct_size       : out std_logic_vector(15 downto 0);
      pct_size_valid : out std_logic

   );
end pct_separate_fsm;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pct_separate_fsm is
--declare signals,  components here
constant c_HDR_WORDS_N  : integer := 4; 
type state_type is (idle, rd_pct, rd_done);
signal current_state, next_state : state_type;
signal infifo_rdreq_int    : std_logic;
signal pct_wrreq_reg       : std_logic;
signal rd_cnt              : unsigned(15 downto 0);
signal wr_cnt              : unsigned(15 downto 0);
signal rd_cnt_max          : unsigned(15 downto 0);
signal header_0            : std_logic_vector(31 downto 0);
signal pct_size_valid_reg  : std_logic;

  
begin


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
fsm : process(current_state, infifo_rdempty, pct_wrempty, rd_cnt, wr_cnt, rd_cnt_max) begin
   next_state <= current_state;
   case current_state is
   
      when idle =>
         if infifo_rdempty = '0' AND pct_wrempty = '1' then
            next_state <= rd_pct;
         else 
            next_state <= idle;
         end if;
      
      when rd_pct =>
         if rd_cnt < rd_cnt_max -1 then 
            next_state <= rd_pct;
         else 
            next_state <= rd_done;
         end if;
         
      when rd_done =>
         if pct_wrempty = '1' then 
            next_state <= idle;
         else
            next_state <= rd_done;
         end if;
         
         
      when others => 
         next_state <= idle;
   end case;
end process;

process (current_state, infifo_rdempty) 
   begin 
      if current_state = rd_pct AND infifo_rdempty = '0' then 
         infifo_rdreq_int <= '1';
      else 
         infifo_rdreq_int <= '0';
      end if;
   end process;
   
rd_cnt_proc : process(clk, reset_n)
begin
   if reset_n = '0' then 
      rd_cnt <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      if current_state = idle then 
         rd_cnt <= (others=>'0');
      elsif infifo_rdreq_int = '1' then 
         rd_cnt <= rd_cnt + 1;
      else 
         rd_cnt <= rd_cnt;
      end if;
   end if;
end process;
   
wr_cnt_proc : process(clk, reset_n)
begin
   if reset_n = '0' then 
      wr_cnt <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      if current_state = idle then 
         wr_cnt <= (others=>'0');
      elsif pct_wrreq_reg = '1' then 
         wr_cnt <= wr_cnt + 1;
      else 
         wr_cnt <= wr_cnt;
      end if;
   end if;
end process;

headr_cap : process(clk, reset_n)
begin
   if reset_n = '0' then 
      pct_size_valid_reg <= '0';
      header_0 <= (others=>'0');
      rd_cnt_max <= (others=>'0');
   elsif (clk'event AND clk='1') then
      if wr_cnt = 0 AND pct_wrreq_reg= '1' then 
         header_0             <= infifo_data;
         rd_cnt_max           <= unsigned(infifo_data(23 downto 8)) + c_HDR_WORDS_N;
         pct_size_valid_reg   <= '1';
      else 
         header_0             <= header_0;
         rd_cnt_max           <= rd_cnt_max;
         pct_size_valid_reg   <= '0';
      end if;
   end if;
end process;


   
-- ----------------------------------------------------------------------------
-- Output registers
-- ----------------------------------------------------------------------------
out_reg : process(clk, reset_n)
begin
   if reset_n = '0' then 
      pct_wrreq_reg  <= '0';
   elsif (clk'event AND clk='1') then 
      pct_wrreq_reg  <= infifo_rdreq_int;
   end if;
end process;   
   
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------
infifo_rdreq   <= infifo_rdreq_int; 
pct_wrreq      <= pct_wrreq_reg;
pct_data       <= infifo_data;
pct_size       <= std_logic_vector(rd_cnt_max);
pct_size_valid <= pct_size_valid_reg;


end arch;   


