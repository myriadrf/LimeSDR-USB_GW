-- ----------------------------------------------------------------------------	
-- FILE: 	data2packets_fsm.vhd
-- DESCRIPTION:	Ensures continuous sample packing while not overflowing pct buffer  
-- DATE:	March 22, 2017
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
entity data2packets_fsm is
   port (
      clk               : in std_logic;
      reset_n           : in std_logic;
      pct_buff_rdy      : in std_logic;   -- Assert 1 when packet buffer is ready to accept one full packet
      pct_buff_wr_dis   : out std_logic;  -- When 0  - writing to pct buffer has to be disabled
      smpl_rd_size      : in std_logic_vector(11 downto 0); --Samples to read per packet
      smpl_buff_rdy     : in std_logic;   -- Assert 1 when there is enough samples for at least one packet
      smpl_buff_rdreq   : out std_logic;  -- Read require is asserted for smpl_rd_size cycles
      data2packets_done : in std_logic    -- Assert when packet formation cycle is done
    
        );
end data2packets_fsm;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of data2packets_fsm is
--declare signals,  components here

type state_type is (idle, check_pct_buff, rd_smpl_buff, wait_data2packets_done);
signal current_state, next_state : state_type;

signal smpl_buff_rd_done         : std_logic;
signal smpl_buff_rd_cnt          : unsigned(11 downto 0);
signal smpl_buff_rd_cnt_max      : unsigned(11 downto 0);
signal pct_buff_wr_dis_sig       : std_logic;
  
begin


-- ----------------------------------------------------------------------------
--To decide when to disable writing to external buffer
-- ----------------------------------------------------------------------------
pct_buff_wr_dis_proc : process(clk, reset_n)
begin
   if reset_n = '0' then 
      pct_buff_wr_dis_sig <= '0';
   elsif (clk'event AND clk='1') then 
      if current_state = check_pct_buff then
         pct_buff_wr_dis_sig <= pct_buff_rdy;
      else 
         pct_buff_wr_dis_sig <= pct_buff_wr_dis_sig;
      end if;
   end if;
end process;

pct_buff_wr_dis <= pct_buff_wr_dis_sig;

-- ----------------------------------------------------------------------------
--To decide when to end reading from sample buffer
-- ----------------------------------------------------------------------------
smpl_buff_rd_cnt_proc : process(clk, reset_n)
begin
   if reset_n = '0' then 
      smpl_buff_rd_cnt     <= (others=>'0');
      smpl_buff_rd_cnt_max <= (others=> '0');
   elsif (clk'event AND clk='1') then 
      smpl_buff_rd_cnt_max <= unsigned(smpl_rd_size) - 2;
      if current_state = rd_smpl_buff then
         smpl_buff_rd_cnt <= smpl_buff_rd_cnt+1;
      else 
         smpl_buff_rd_cnt <= (others=>'0');
      end if;
   end if;
end process;

smpl_buff_rd_done_proc : process(clk, reset_n)
begin
   if reset_n = '0' then
      smpl_buff_rd_done<= '0';
   elsif (clk'event AND clk='1') then 
      if smpl_buff_rd_cnt < smpl_buff_rd_cnt_max then
         smpl_buff_rd_done <= '0';
      else 
         smpl_buff_rd_done <= '1';
      end if;
   end if;
end process;

smpl_buff_rdreq_comb : process(current_state)
begin
   if current_state = rd_smpl_buff then 
      smpl_buff_rdreq <= '1';
   else 
      smpl_buff_rdreq <= '0';
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
fsm : process(current_state, smpl_buff_rdy, smpl_buff_rd_done, data2packets_done) begin
	next_state <= current_state;
	case current_state is
	  
		when idle =>                  -- wait for enough samples for one packet
         if smpl_buff_rdy = '1' then 
            next_state <= check_pct_buff;
         else
            next_state <= idle;
         end if;
       
      when check_pct_buff =>        -- state to capture pct_buff_rdy 
            next_state <= rd_smpl_buff;
               
      when rd_smpl_buff =>          -- read smpl_rd_size cycles
         if smpl_buff_rd_done = '0' then 
            next_state <= rd_smpl_buff;
         else 
            next_state <= wait_data2packets_done;
         end if;
        
      when wait_data2packets_done => -- wait when packet formation is done
         if data2packets_done = '1' then 
            next_state <= idle; 
         else 
            next_state <= wait_data2packets_done;
         end if;
            
		when others => 
			next_state <= idle;
	end case;
end process;
  
end arch;   





