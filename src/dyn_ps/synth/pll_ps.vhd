-- ----------------------------------------------------------------------------
-- FILE:          pll_ps.vhd
-- DESCRIPTION:   control module for PLL dynamic phase shift 
-- DATE:          11:21 AM Friday, January 19, 2018
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
entity pll_ps is
   port (
      clk      : in std_logic; -- connect to PLL scanclk output
      reset_n  : in std_logic;
      busy     : out std_logic; -- 1 - busy, 0 - not busy
      en       : in std_logic; -- rising edge triggers dynamic phase shift
      phase    : in std_logic_vector(9 downto 0); -- phase value in steps
      cnt      : in std_logic_vector(2 downto 0); -- 000 - ALL, 001 -   M, 010 - C0,
                                                  -- 011 -  C1, 100 -  C2, 101 - C3,
                                                  -- 110 -  C4
      updown   : in std_logic; -- 1- UP, 0 - DOWN      
      --pll ports
      pll_phasecounterselect        : out std_logic_vector(2 downto 0);
      pll_phaseupdown               : out std_logic;
      pll_phasestep                 : out std_logic;
      pll_phasedone                 : in std_logic

      );
end pll_ps;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pll_ps is
--declare signals,  components here
signal en_reg     : std_logic;
signal phase_reg  : std_logic_vector(9 downto 0);
signal cnt_reg    : std_logic_vector(2 downto 0);
signal updown_reg : std_logic;
signal busy_reg   : std_logic;

signal current_phase_step_cnt : unsigned(9 downto 0);
signal phase_step_cnt         : unsigned(7 downto 0);
signal check_phase_done_cnt   : unsigned(7 downto 0);
signal pll_phasedone_neg_reg  : std_logic;
signal pll_phasedone_pos_reg  : std_logic;

constant timeout : unsigned(7 downto 0) := x"0F";

type state_type is (idle, check_phase_step, phase_step, check_phase_done, end_phase);
signal current_state, next_state : state_type;

attribute noprune: boolean;
attribute noprune of pll_phasedone_neg_reg: signal is true;
attribute noprune of pll_phasedone_pos_reg: signal is true;

  
begin

-- ----------------------------------------------------------------------------
-- Input registers
-- ----------------------------------------------------------------------------
 process(reset_n, clk)
    begin
      if reset_n='0' then
         en_reg      <= '0';
         phase_reg   <= (others => '0');
         cnt_reg     <= (others => '0');
         updown_reg  <= '0';
         pll_phasedone_pos_reg <= '0';
      elsif (clk'event and clk = '1') then
         en_reg <= en;
         pll_phasedone_pos_reg <= pll_phasedone_neg_reg;
         
         --capture on rising edge of en port
         if en_reg = '0' AND en = '1' then 
            phase_reg   <= phase;
            cnt_reg     <= cnt;
            updown_reg  <= updown;
         else 
            phase_reg   <= phase_reg;
            cnt_reg     <= cnt_reg;
            updown_reg  <= updown_reg;
         end if;
      end if;
    end process;
    
    
   --negative edge register
   process(reset_n, clk)
    begin
      if reset_n='0' then
         pll_phasedone_neg_reg <= '0';
      elsif (clk'event and clk = '0') then
         pll_phasedone_neg_reg <= pll_phasedone;
      end if;
    end process;
    
    
    
    
    
process(clk, reset_n)
begin
   if reset_n = '0' then 
      current_phase_step_cnt  <= (others => '0');
      phase_step_cnt          <= (others => '0');
      check_phase_done_cnt    <= (others => '0');
   elsif (clk'event AND clk='1') then
      -- counter required for counting phase shift cycles
      if current_state = check_phase_step then 
         current_phase_step_cnt <= current_phase_step_cnt + 1;
      elsif current_state = idle then 
         current_phase_step_cnt <= (others => '0'); 
      else 
         current_phase_step_cnt <= current_phase_step_cnt;
      end if;
      
      -- counter required for phasestep signal 
      if current_state = phase_step then 
         phase_step_cnt <= phase_step_cnt + 1;
      else 
         phase_step_cnt <= (others=>'0');
      end if;
      
      if current_state = check_phase_done then 
         check_phase_done_cnt <= check_phase_done_cnt + 1;
      else 
         check_phase_done_cnt    <= (others => '0');
      end if;
      
   end if;
end process;
    
-- ----------------------------------------------------------------------------
--state machine
-- ----------------------------------------------------------------------------
fsm_f : process(clk, reset_n)begin
   if(reset_n = '0')then
      current_state  <= idle;
   elsif(clk'event and clk = '1')then 
      current_state <= next_state;
   end if;
end process;

-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, en, en_reg, current_phase_step_cnt, 
               phase_step_cnt, pll_phasedone, check_phase_done_cnt, phase_reg, 
               pll_phasedone_neg_reg) begin
   next_state <= current_state;
   case current_state is
   
      when idle =>                     -- wait for start
         -- rising edge of ps_en and ps_mode = 1
         if en = '1' AND en_reg = '0' then 
            next_state <= check_phase_step;
         else 
            next_state <= idle;
         end if;
         
      when check_phase_step =>         -- is max step count reached? 
         if current_phase_step_cnt < unsigned(phase_reg) then 
            next_state <= phase_step;
         else 
            next_state <= end_phase;
         end if;
         
      when phase_step =>               -- phase shift operation
         --ensure that fsm stays at least two cycles in this state
         if pll_phasedone_neg_reg = '0' then 
         --if phase_step_cnt > 2 OR (pll_phasedone = '0' AND  phase_step_cnt > 0) then 
            next_state <= check_phase_done;
         elsif phase_step_cnt > timeout then  --timeout
            next_state <= check_phase_done;
         else 
            next_state <= phase_step;
         end if;
       
      when check_phase_done =>         -- check if phase shift is successfully
         if pll_phasedone_neg_reg = '1' then
         --if pll_phasedone = '1' then 
            next_state <= check_phase_step;
         elsif check_phase_done_cnt > timeout then 
            next_state <= idle;
         end if;
         
      when end_phase => 
         next_state <= idle;
         
      when others => 
         next_state <= idle;
   end case;
end process;

-- ----------------------------------------------------------------------------
-- fsm dependant registers
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin
   if reset_n = '0' then 
      busy_reg <= '1';
   elsif (clk'event AND clk='1') then
      if current_state = idle then 
         busy_reg <= '0';
      else 
         busy_reg <= '1';
      end if;
   end if;
end process;

process(current_state)
begin 
   if current_state = phase_step then 
      pll_phasestep <= '1';
   else 
      pll_phasestep <= '0';
   end if;
end process;

-- ----------------------------------------------------------------------------
-- output ports
-- ----------------------------------------------------------------------------
pll_phasecounterselect  <= cnt_reg;
pll_phaseupdown         <= updown_reg;
busy                    <= busy_reg;
  
end arch;   


