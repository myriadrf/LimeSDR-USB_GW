-- ----------------------------------------------------------------------------
-- FILE:          edge_delay.vhd
-- DESCRIPTION:   describe file
-- DATE:          Jan 27, 2016
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
entity edge_delay is
   port (
      clk      : in  std_logic;
      reset_n  : in  std_logic;
      -- Parameters
      rise_dly : in std_logic_vector(15 downto 0);
      fall_dly : in std_logic_vector(15 downto 0);
      d        : in  std_logic;  -- Signal in 
      q        : out std_logic   -- Delayed signal out
   );
end edge_delay;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of edge_delay is
--declare signals,  components here
signal d_reg      : std_logic_vector(1 downto 0);
signal rise_cnt   : unsigned(15 downto 0);
signal fall_cnt   : unsigned(15 downto 0);
signal q_reg      : std_logic;

type state_type is (idle, rise_delay, assert_q, wait_fall, fall_delay);
signal current_state, next_state : state_type;
  
begin

-- ----------------------------------------------------------------------------
-- Input registers
-- ----------------------------------------------------------------------------
 process(reset_n, clk)
    begin
      if reset_n='0' then
         d_reg <= (others=>'0');
      elsif (clk'event and clk = '1') then
         d_reg <= d_reg(0) & d;
      end if;
    end process;
    
-- ----------------------------------------------------------------------------
-- Delay counters
-- ----------------------------------------------------------------------------  
process(reset_n, clk)
begin
   if reset_n='0' then
      rise_cnt <= (others=>'0');
      fall_cnt <= (others=>'0');
   elsif (clk'event and clk = '1') then
   
      if current_state = idle then 
         rise_cnt <= (others=>'0');
      elsif current_state = rise_delay then 
         rise_cnt <= rise_cnt + 1;
      else 
         rise_cnt <= rise_cnt;
      end if;
      
      if current_state = idle OR current_state = wait_fall then 
         fall_cnt <= (others=>'0');
      elsif current_state = fall_delay then 
         fall_cnt <= fall_cnt + 1;
      else 
         fall_cnt <= fall_cnt;
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
fsm : process(current_state, d, rise_dly, fall_dly, rise_cnt, fall_cnt) begin
   next_state <= current_state;
   case current_state is
   
      when idle => --idle state
         if d = '1' then 
            next_state <= rise_delay;
         else 
            next_state <= idle;
         end if;
         
      when rise_delay =>
         if d = '1' then  
            if rise_cnt < unsigned(rise_dly) then 
               next_state <= rise_delay;
            else
               next_state <= wait_fall;
            end if;
         else 
            next_state <= fall_delay;
         end if;
         
      when wait_fall =>
         if d = '1' then 
            next_state <= wait_fall;
         else
            next_state <= fall_delay;
         end if;
         
      when fall_delay =>
         if d = '0' then  
            if fall_cnt < unsigned(fall_dly) then 
               next_state <= fall_delay;
            else
               next_state <= idle;
            end if;
         else 
            next_state <= wait_fall;
         end if;
                  
      when others => 
         next_state<=idle;
   end case;
end process;

-- ----------------------------------------------------------------------------
-- output registers
-- ----------------------------------------------------------------------------
process(reset_n, clk)
begin
   if reset_n='0' then
      q_reg <= '0';
   elsif (clk'event and clk = '1') then
      if current_state = wait_fall then 
         q_reg <= '1';
      elsif current_state = idle OR current_state = rise_delay then 
         q_reg <= '0';
      else
         q_reg <= q_reg;
      end if;
   end if;
end process;

-- ----------------------------------------------------------------------------
-- output ports
-- ----------------------------------------------------------------------------
q <= q_reg;


end arch;   


