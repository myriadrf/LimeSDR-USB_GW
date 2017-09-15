-- ----------------------------------------------------------------------------	
-- FILE:          txiq_ctrl.vhd
-- DESCRIPTION:   control module for txiq
-- DATE:          August 25, 2017
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity txiq_ctrl is
   port (
      clk                 : in std_logic;
      reset_n             : in std_logic;
      --Mode settings
      pct_sync_mode       : in std_logic; -- 0 - timestamp, 1 - external pulse
      --pulse sync mode signals
      pct_sync_pulse      : in std_logic; -- external packet synchronisation pulse signal
      pct_sync_size       : in std_logic_vector(15 downto 0); -- valid in external pulse mode only
      pct_buff_rdy        : in std_logic; --assert high when there is samples more than pct_sync_size
      --signals for txiq module
      txiq_rdreq_in       : in std_logic;
      txiq_en             : out std_logic;
      --tx antenna controll
      txant_cyc_before_en : in std_logic_vector(15 downto 0);
      txant_cyc_after_en  : in std_logic_vector(15 downto 0);
      txant_en            : out std_logic
        );
end txiq_ctrl;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of txiq_ctrl is
--declare signals,  components here
signal txiq_en_mux         : std_logic;
signal txiq_en_mode_1      : std_logic;
signal cnt                 : unsigned(15 downto 0);
signal cnt_max             : unsigned(15 downto 0);
signal txant_en_wait_cnt   : unsigned(15 downto 0);
signal txant_dis_wait_cnt  : unsigned(15 downto 0);
signal txant_en_reg        : std_logic;

type state_type is (idle, txant_enable_wait, rd_samples, txant_dis_wait, wait_rd_cycles);
signal current_state, next_state : state_type;

  
begin

--sample read counter max value
process(clk, reset_n)
begin
   if reset_n = '0' then 
      cnt_max <= (others => '0');
   elsif (clk'event AND clk='1') then 
      cnt_max <= unsigned(pct_sync_size)-1;
   end if;
end process;


--txant_en wait down counter
process(clk, reset_n)
   begin
   if reset_n = '0' then 
      txant_en_wait_cnt <= (others => '0');
   elsif (clk'event AND clk='1') then
      if current_state = txant_enable_wait then 
         txant_en_wait_cnt <= txant_en_wait_cnt-1;
      else 
         txant_en_wait_cnt <= unsigned(txant_cyc_before_en);
      end if;
   end if;
end process;

--txant_dis wait down counter
process(clk, reset_n)
   begin
   if reset_n = '0' then 
      txant_dis_wait_cnt <= (others => '0');
   elsif (clk'event AND clk='1') then
      if current_state = txant_dis_wait then 
         txant_dis_wait_cnt <= txant_dis_wait_cnt-1;
      else 
         txant_dis_wait_cnt <= unsigned(txant_cyc_after_en);
      end if;
   end if;
end process;

--txiq_en signal in pulse sync mode
process(current_state)
begin 
   if current_state = rd_samples then 
      txiq_en_mode_1 <= '1';
   else 
      txiq_en_mode_1 <= '0';
   end if;
end process;


--sample read counter
cnt_p : process(clk, reset_n)
begin
   if reset_n = '0' then 
      cnt <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      if current_state = rd_samples then
         if txiq_rdreq_in = '1' then 
            cnt <= cnt + 1;
         else 
            cnt <= cnt;
         end if;
      else 
         cnt <= (others=>'0');
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
fsm : process(current_state, pct_buff_rdy, pct_sync_pulse, cnt, cnt_max, txiq_rdreq_in, txant_en_wait_cnt,        txant_dis_wait_cnt) begin
	next_state <= current_state;
	case current_state is
	  
		when idle => --idle state
         if pct_buff_rdy = '1' and pct_sync_pulse = '1' then 
            next_state <= txant_enable_wait;
         else 
            next_state <= idle;
         end if;
         
      when txant_enable_wait =>
         if txant_en_wait_cnt = 0 then 
            next_state <= rd_samples;
         else 
            next_state <= txant_enable_wait;
         end if;
               
      when rd_samples =>
         if cnt >= cnt_max AND txiq_rdreq_in = '1' then
            next_state <= txant_dis_wait;
         else 
            next_state <= rd_samples;
         end if;
         
      when txant_dis_wait => 
         if txant_dis_wait_cnt = 0 then 
            next_state <= idle;
         else 
            next_state <= txant_dis_wait;
         end if;
                           
		when others => 
			next_state <= idle;
	end case;
end process;

--txiq_en mux register
 -- process(reset_n, clk)
    -- begin
      -- if reset_n='0' then
         -- txiq_en_mux <= '0';
      -- elsif (clk'event and clk = '1') then
         -- if pct_sync_mode = '0' then 
            -- txiq_en_mux <= '1';
         -- else 
            -- txiq_en_mux <= txiq_en_mode_1;
         -- end if;
      -- end if;
-- end process;

txiq_en_mux <= '1' when pct_sync_mode = '0' else txiq_en_mode_1;
 
--txant_en register
process(clk, reset_n)
begin
   if reset_n = '0' then 
      txant_en_reg <= '0';
   elsif (clk'event AND clk='1') then 
      if current_state = txant_enable_wait then 
         txant_en_reg <= '1';
      elsif current_state = idle then 
         txant_en_reg <= '0';
      else 
         txant_en_reg <= txant_en_reg;
      end if;
   end if;
end process;

txant_en <= txant_en_reg;
    

    
txiq_en <= txiq_en_mux;
  
end arch;   





