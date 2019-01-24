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

LIBRARY lpm;
USE lpm.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity p2d_wr_fsm is
   generic (
      g_DATA_WIDTH      : integer := 128;
      g_PCT_MAX_SIZE    : integer := 4096;     
      g_PCT_HDR_SIZE    : integer := 16;           
      g_BUFF_COUNT      : integer := 4 -- 2,4 valid values
   );
   port (
      clk               : in std_logic;
      reset_n           : in std_logic;
      
      pct_sync_dis      : in std_logic;
      sample_nr         : in std_logic_vector(63 downto 0);
      
      in_pct_reset_n_req: out std_logic;
      in_pct_rdreq      : out std_logic;
      in_pct_data       : in std_logic_vector(g_DATA_WIDTH-1 downto 0);
      in_pct_rdy        : in std_logic;
      
      pct_hdr_0         : out std_logic_vector(63 downto 0);
      pct_hdr_0_valid   : out std_logic_vector(g_BUFF_COUNT-1 downto 0);
      
      pct_hdr_1         : out std_logic_vector(63 downto 0);
      pct_hdr_1_valid   : out std_logic_vector(g_BUFF_COUNT-1 downto 0);
      
      pct_data          : out std_logic_vector(g_DATA_WIDTH-1 downto 0);
      pct_data_wrreq    : out std_logic_vector(g_BUFF_COUNT-1 downto 0);

      pct_buff_rdy      : in std_logic_vector(g_BUFF_COUNT-1 downto 0)
      
        );
end p2d_wr_fsm;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of p2d_wr_fsm is
--declare signals,  components here

constant C_HEADER_POS      : integer := 0;
constant c_PCT_MAX_WORDS   : integer := g_PCT_MAX_SIZE*8/g_DATA_WIDTH;
constant c_PCT_HDR_WORDS   : integer := g_PCT_HDR_SIZE*8/g_DATA_WIDTH;
constant c_RD_RATIO        : integer := g_DATA_WIDTH/8;

type state_type is (idle, rd_hdr, wait_cmpr_pipe, check_smpl_nr, clr_fifo, switch_next_buff, rd_pct, wait_wr_end, check_next_buf, switch_current_buff);
signal current_state, next_state : state_type;  

signal current_buff_cnt       : unsigned(3 downto 0);
signal next_buff_cnt          : unsigned(3 downto 0);

signal rd_cnt                 : unsigned(15 downto 0);
signal rd_cnt_max             : unsigned(15 downto 0);
signal pipe_cnt               : unsigned(3 downto 0);

signal current_buff_rdy       : std_logic;
signal next_buff_rdy          : std_logic;

signal in_pct_rdreq_int       : std_logic;
signal in_pct_data_valid      : std_logic;

signal pct_data_wrreq_cnt     : unsigned(15 downto 0);
signal pct_smpl_nr_equal      : std_logic;
signal pct_smpl_nr_less       : std_logic;
signal pct_hdr_0_reg          : std_logic_vector(63 downto 0);
signal pct_hdr_1_reg          : std_logic_vector(63 downto 0);
alias  crnt_pct_sync_dis      : std_logic is pct_hdr_0_reg(4);



-- Component declaration
COMPONENT lpm_compare
   GENERIC (
      lpm_pipeline         : NATURAL;
      lpm_representation   : STRING;
      lpm_type             : STRING;
      lpm_width            : NATURAL
   );
   PORT (
      clock : IN STD_LOGIC ;
      dataa : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
      datab : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
      aeb   : OUT STD_LOGIC ;
      alb   : OUT STD_LOGIC 
   );
   END COMPONENT;

begin

   LPM_COMPARE_component : LPM_COMPARE
   GENERIC MAP (
      lpm_pipeline         => 3,
      lpm_representation   => "UNSIGNED",
      lpm_type             => "LPM_COMPARE",
      lpm_width            => 64
   )
   PORT MAP (
      clock                => clk,
      dataa                => pct_hdr_1_reg,
      datab                => sample_nr,
      aeb                  => pct_smpl_nr_equal,
      alb                  => pct_smpl_nr_less
   );
     
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
            if next_buff_cnt < g_BUFF_COUNT - 1 then  
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
         rd_cnt   <= (others=>'0');
         pipe_cnt <= (others=>'0');
      elsif (clk'event AND clk='1') then 
         if current_state = rd_pct OR current_state = rd_hdr then 
            rd_cnt <= rd_cnt + 1;
         elsif current_state = idle then 
            rd_cnt <= (others=>'0');
         else 
            rd_cnt <= rd_cnt;
         end if;
         
         if current_state = wait_cmpr_pipe then 
            pipe_cnt <= pipe_cnt + 1;
         else 
            pipe_cnt <= (others=>'0');
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
               next_buff_rdy, in_pct_data_valid, pipe_cnt, pct_smpl_nr_less, 
               crnt_pct_sync_dis, pct_sync_dis, rd_cnt_max) begin
   next_state <= current_state;
   case current_state is
   
      when idle =>
         if in_pct_rdy = '1' then
            next_state <= rd_hdr;
         else 
            next_state <= idle;
         end if;
      
      when rd_hdr =>
         next_state <= wait_cmpr_pipe;   
         
      when wait_cmpr_pipe => 
         if pipe_cnt > 3 then 
            next_state <= check_smpl_nr;
         else 
            next_state <= wait_cmpr_pipe;
         end if;

      when check_smpl_nr =>
         if pct_smpl_nr_less = '1' AND crnt_pct_sync_dis = '0' AND pct_sync_dis = '0' then 
            next_state <= clr_fifo;
         else 
            if current_buff_rdy = '1' then 
               next_state <= switch_next_buff;
            else 
               next_state <= check_smpl_nr;
            end if;
         end if;
         
      when clr_fifo => 
         next_state <= idle;

      when switch_next_buff => 
         next_state <= rd_pct;
                  
      when rd_pct =>
         if rd_cnt < rd_cnt_max - 1 then 
            next_state <= rd_pct;
         else 
            next_state <= wait_wr_end;
         end if;
         
      when wait_wr_end => 
         if in_pct_data_valid = '0' then 
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
         in_pct_data_valid <= '0';
         pct_data_wrreq_cnt <= (others => '0');
      elsif (clk'event AND clk='1') then 
         in_pct_data_valid <= in_pct_rdreq_int;
         
         if in_pct_data_valid = '1' then 
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
      in_pct_rdreq_int     <= '0';
      in_pct_reset_n_req   <= '1';
      pct_hdr_0_reg     <= (others=>'0');
      pct_hdr_0_valid   <= (others=>'0');  
      pct_hdr_1_reg     <= (others=>'0');
      pct_hdr_1_valid   <= (others=>'0');
      pct_data          <= (others=>'0');
      pct_data_wrreq    <= (others=>'0');
      rd_cnt_max        <= (others=>'0');
   elsif (clk'event AND clk='1') then
      -- Read request signal for FIFO where packet is stored
      if current_state = rd_pct OR current_state = rd_hdr then 
         in_pct_rdreq_int <= '1';
      else 
         in_pct_rdreq_int <= '0';
      end if;
      
      if current_state = clr_fifo then 
         in_pct_reset_n_req <= '0';
      else 
         in_pct_reset_n_req <= '1';
      end if;
      
      -- Packet header
      if in_pct_data_valid = '1' AND pct_data_wrreq_cnt = C_HEADER_POS then 
         pct_hdr_0_reg     <= in_pct_data(63 downto 0);
         pct_hdr_1_reg     <= in_pct_data(127 downto 64);
         if in_pct_data(23 downto 8) = "0000000000000000" then 
            rd_cnt_max  <= to_unsigned(c_PCT_MAX_WORDS,rd_cnt_max'length);
         else 
            rd_cnt_max  <= unsigned(in_pct_data(23 downto 8))/c_RD_RATIO + c_PCT_HDR_WORDS;
         end if;
      end if;
      
      if in_pct_data_valid = '1' AND pct_data_wrreq_cnt = C_HEADER_POS then 
         pct_hdr_0_valid   <= (others=>'0');
         pct_hdr_0_valid(to_integer(current_buff_cnt))   <= '1';
         
         pct_hdr_1_valid   <= (others=>'0');
         pct_hdr_1_valid(to_integer(current_buff_cnt))   <= '1';  
      else 
         pct_hdr_0_valid   <= (others=>'0');
         pct_hdr_1_valid   <= (others=>'0');
      end if;
      
      -- Packet data
      if in_pct_data_valid = '1' AND pct_data_wrreq_cnt > C_HEADER_POS then 
         pct_data         <= in_pct_data;
      end if;
      
      if in_pct_data_valid = '1' AND pct_data_wrreq_cnt > C_HEADER_POS then 
         pct_data_wrreq   <= (others=>'0');
         pct_data_wrreq(to_integer(current_buff_cnt))   <= '1';
      else 
         pct_data_wrreq   <= (others=>'0');
      end if;
      
   end if;
end process;


in_pct_rdreq <= in_pct_rdreq_int;

pct_hdr_0 <= pct_hdr_0_reg;
pct_hdr_1 <= pct_hdr_1_reg;

end arch;   





