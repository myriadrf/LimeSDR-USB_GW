-- ----------------------------------------------------------------------------	
-- FILE:          p2d_rd.vhd
-- DESCRIPTION:   FSM for data reading from packets.
-- DATE:          April 6, 2017
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	

-- ----------------------------------------------------------------------------
-- Notes:
-- Due to pct_buff_rdreq signal delay assert smpl_buff_almost_full signal min 2
-- cycles before buffer can not accept data to avoid overflow.
-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY lpm;
USE lpm.all;
-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity p2d_rd is
   generic (
      g_PCT_MAX_SIZE : integer := 4096;   -- Whole packet size in bytes
      g_PCT_HDR_SIZE : integer := 16;     -- Packet header size in bytes  
      g_BUFF_COUNT   : integer := 4;      -- 2,4 valid values
      g_DATA_W       : integer := 64
   );
   port (
      clk                     : in std_logic;
      reset_n                 : in std_logic;
      
      synch_dis               : in std_logic;
      
      pct_hdr_0               : in std_logic_vector(63 downto 0);
      pct_hdr_0_valid         : in std_logic_vector(g_BUFF_COUNT-1 downto 0);      
      pct_hdr_1               : in std_logic_vector(63 downto 0);
      pct_hdr_1_valid         : in std_logic_vector(g_BUFF_COUNT-1 downto 0);
      
      sample_nr               : in std_logic_vector(63 downto 0);
      
      pct_buff_rdy            : in std_logic_vector(g_BUFF_COUNT-1 downto 0);
      pct_buff_rdreq          : out std_logic_vector(g_BUFF_COUNT-1 downto 0);
      pct_buff_sel            : out std_logic_vector(3 downto 0);
      pct_buff_clr_n          : out std_logic_vector(g_BUFF_COUNT-1 downto 0);
      
      smpl_buff_almost_full   : in std_logic
     
   );
end p2d_rd;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of p2d_rd is
--declare signals,  components here
constant c_PCT_MAX_WORDS   : integer := (g_PCT_MAX_SIZE-g_PCT_HDR_SIZE)*8/g_DATA_W;
constant c_RD_RATIO        : integer := g_DATA_W/8;

type pct_hdr_0_array_type  is array (0 to g_BUFF_COUNT-1) of std_logic_vector(pct_hdr_0'length-1 downto 0);
type pct_hdr_1_array_type  is array (0 to g_BUFF_COUNT-1) of std_logic_vector(pct_hdr_1'length-1 downto 0);

signal pct_hdr_0_array              : pct_hdr_0_array_type;
signal pct_hdr_1_array              : pct_hdr_1_array_type;
signal pct_smpl_nr_less             : std_logic_vector(g_BUFF_COUNT-1 downto 0);
signal pct_smpl_nr_equal            : std_logic_vector(g_BUFF_COUNT-1 downto 0);
signal pct_synch_dis                : std_logic_vector(g_BUFF_COUNT-1 downto 0);

signal crnt_buff_rdy                : std_logic;
signal crnt_buff_pct_synch_dis      : std_logic;
signal crnt_buff_pct_smpl_nr_equal  : std_logic; 
signal crnt_buff_pct_smpl_nr_less   : std_logic; 
signal crnt_buff_cnt                : unsigned(3 downto 0);
signal crnt_buff_payload_size       : std_logic_vector(15 downto 0);

signal rd_req_int                   : std_logic;
signal rd_cnt                       : unsigned(15 downto 0);
signal rd_cnt_max                   : unsigned(15 downto 0);

type state_type is (idle, switch_next_buff, check_next_buf, rd_buff, rd_hold, clr_buff);
signal current_state, next_state : state_type;   

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
   
-- ----------------------------------------------------------------------------
-- Capture pct_hdr_0 and pct_hdr_1 to array
-- ----------------------------------------------------------------------------
   -- pct_hdr_0 capture register
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         pct_hdr_0_array <= (others=>(others=>'0'));
      elsif (clk'event AND clk='1') then 
         for i in 0 to g_BUFF_COUNT-1 loop
            if pct_hdr_0_valid(i) = '1' then 
               pct_hdr_0_array(i)<= pct_hdr_0;
            else 
               pct_hdr_0_array(i)<=pct_hdr_0_array(i);
            end if;
         end loop;
      end if;
   end process;

   -- pct_hdr_1 capture register
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         pct_hdr_1_array <= (others=>(others=>'0'));
      elsif (clk'event AND clk='1') then 
         for i in 0 to g_BUFF_COUNT-1 loop
            if pct_hdr_1_valid(i) = '1' then 
               pct_hdr_1_array(i)<= pct_hdr_1;
            else 
               pct_hdr_1_array(i)<=pct_hdr_1_array(i);
            end if;
         end loop;
      end if;
   end process;
   
   -- Packet synchronization bit from received packet header
   pct_synch_dis_gen : for i in 0 to g_BUFF_COUNT-1 generate 
      pct_synch_dis(i) <= pct_hdr_0_array(i)(4);
   end generate pct_synch_dis_gen; 
   
-- ----------------------------------------------------------------------------
-- Pipelined comparators
-- Sample number is compared with current received sample number in packet
-- ----------------------------------------------------------------------------
   gen_lpm_compare : 
   for i in 0 to g_BUFF_COUNT-1 generate
   LPM_COMPARE_component : LPM_COMPARE
      GENERIC MAP (
         lpm_pipeline         => 3,
         lpm_representation   => "UNSIGNED",
         lpm_type             => "LPM_COMPARE",
         lpm_width            => 64
      )
      PORT MAP (
         clock                => clk,
         dataa                => pct_hdr_1_array(i),
         datab                => sample_nr,
         aeb                  => pct_smpl_nr_equal(i),
         alb                  => pct_smpl_nr_less(i)
      );
   end generate gen_lpm_compare;  
   
-- ----------------------------------------------------------------------------
-- Buffer selection process
-- ----------------------------------------------------------------------------     
   crnt_buff_sel_proc : process(clk, reset_n)
   begin
      if reset_n = '0' then 
         crnt_buff_cnt               <= (others=>'0');
         crnt_buff_rdy               <= '0';
         crnt_buff_pct_synch_dis     <= '0';
         crnt_buff_pct_smpl_nr_equal <= '0';
         crnt_buff_pct_smpl_nr_less  <= '0';
         crnt_buff_payload_size      <= (others=>'0');
      elsif (clk'event AND clk='1') then
         -- Current buffer counter used for MUX select
         if current_state = switch_next_buff then
            if crnt_buff_cnt < g_BUFF_COUNT - 1 then
               crnt_buff_cnt <= crnt_buff_cnt + 1;
            else 
               crnt_buff_cnt <= (others=>'0');
            end if;
         else 
            crnt_buff_cnt <= crnt_buff_cnt;
         end if;
         
         -- Signal MUX
         crnt_buff_rdy               <= pct_buff_rdy(to_integer(crnt_buff_cnt)); 
         crnt_buff_pct_synch_dis     <= pct_synch_dis(to_integer(crnt_buff_cnt));
         crnt_buff_pct_smpl_nr_equal <= pct_smpl_nr_equal(to_integer(crnt_buff_cnt));
         crnt_buff_pct_smpl_nr_less  <= pct_smpl_nr_less(to_integer(crnt_buff_cnt));
         crnt_buff_payload_size      <= pct_hdr_0_array(to_integer(crnt_buff_cnt))(23 downto 8);
         
      end if;
   end process;
   
   -- Read counter to terminate buffer read state
   rd_cnt_proc : process(clk, reset_n)
   begin
      if reset_n = '0' then 
         rd_cnt <= (others=>'0');
         rd_cnt_max <= (others=> '0');
      elsif (clk'event AND clk='1') then 
         if current_state = idle then 
            rd_cnt <= (others=>'0');
         else 
            if rd_req_int = '1' then 
               rd_cnt <= rd_cnt + 1;
            else 
               rd_cnt <= rd_cnt;
            end if;
         end if;
         
         if unsigned(crnt_buff_payload_size) = 0 then 
            rd_cnt_max <= to_unsigned(c_PCT_MAX_WORDS,rd_cnt_max'length);
         else
            rd_cnt_max <= unsigned(crnt_buff_payload_size)/c_RD_RATIO;
         end if;
      end if;
   end process;
   
   -- internal read request signal,  
   rd_req_int_proc : process (current_state, smpl_buff_almost_full)
   begin 
      if current_state = rd_buff AND smpl_buff_almost_full = '0' then 
         rd_req_int <= '1';
      else 
         rd_req_int <= '0';
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
-- State machine combo.
-- FSM waits until current selected buffer is ready, if synchronization is 
-- disabled buffer read process begins. If synchronization is enabled current 
-- buffer read process begins only when received sample number equals to sample_nr,
-- if received sample number is less than sample_nr, buffer clear signal is asserted
-- (Current buffer is cleared and FSM goes to check next buffer)
-- ----------------------------------------------------------------------------
   fsm : process(current_state, synch_dis, crnt_buff_rdy, crnt_buff_pct_synch_dis, rd_cnt,
                  crnt_buff_pct_smpl_nr_equal, crnt_buff_pct_smpl_nr_less,
                  smpl_buff_almost_full) begin
      next_state <= current_state;
      case current_state is
      
         when idle =>
            if crnt_buff_rdy = '1' then
               if synch_dis = '1' OR crnt_buff_pct_synch_dis = '1' then 
                  next_state <= rd_buff;
               else
                  if crnt_buff_pct_smpl_nr_equal = '1' then 
                     next_state <= rd_buff;
                  elsif crnt_buff_pct_smpl_nr_less = '1' then 
                     next_state <= clr_buff;
                  else 
                     next_state <= idle;
                  end if;                  
               end if;
            else 
               next_state <= idle;
            end if;
            
         when clr_buff =>
            next_state <= switch_next_buff;
         
         when rd_buff =>
            if smpl_buff_almost_full = '0' then
               if rd_cnt < rd_cnt_max - 1 then 
                  next_state <= rd_buff;
               else 
                  next_state <= switch_next_buff;
               end if;
            else 
               next_state <= rd_hold;
            end if;
         
         when rd_hold => 
            if smpl_buff_almost_full = '0' then
               next_state <= rd_buff;
            else
               next_state <= rd_hold;
            end if;
            
         when switch_next_buff =>
            next_state <= check_next_buf;
            
         when check_next_buf =>     -- Extra state to allow all data to be read
            next_state <= idle;
            
         when others => 
            next_state <= idle;
      end case;
   end process;
   

-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------
   process(rd_req_int, crnt_buff_cnt)
   begin 
      pct_buff_rdreq <= (others=>'0');
      pct_buff_rdreq(to_integer(crnt_buff_cnt))   <= rd_req_int;
   end process;
   
   process(current_state, crnt_buff_cnt, reset_n)
   begin
      if reset_n = '0' then
         pct_buff_clr_n <= (others=>'0');
      elsif current_state = clr_buff then
         pct_buff_clr_n <= (others=>'1');
         pct_buff_clr_n(to_integer(crnt_buff_cnt))   <= '0';
      else 
         pct_buff_clr_n <= (others=>'1');        
      end if;
   end process;
   
   pct_buff_sel <= std_logic_vector(crnt_buff_cnt);

end arch;