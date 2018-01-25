-- ----------------------------------------------------------------------------
-- FILE:          pll_ps_top.vhd
-- DESCRIPTION:   describe file
-- DATE:          4:31 PM Friday, January 12, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES: in auto mode pll_ps_fsm automatically adjust C1 output clock phase
-- to get correct samples from external interface (checking is done trough 
-- smpl_cmp module)
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pll_ps_top is
   port (

      clk                           : in std_logic;
      reset_n                       : in std_logic;
      --module control ports
      ps_en                         : in std_logic; -- rising edge triggers dynamic phase shift
      ps_mode                       : in std_logic; -- 0 - manual, 1 - auto
      ps_tst                        : in std_logic;
      ps_cnt                        : in std_logic_vector(2 downto 0); 
                                                   -- 000 - ALL, 001 -   M, 010 - C0,
                                                   -- 011 -  C1, 100 -  C2, 101 - C3,
                                                   -- 110 -  C4
      ps_updwn                      : in std_logic; -- 1- UP, 0 - DOWN 
      ps_phase                      : in std_logic_vector(9 downto 0); -- phase value in steps
      ps_step_size                  : in std_logic_vector(9 downto 0);
      ps_busy                       : out std_logic;
      ps_done                       : out std_logic;
      ps_status                     : out std_logic;     
      --pll ports
      pll_phasecounterselect        : out std_logic_vector(2 downto 0);
      pll_phaseupdown               : out std_logic;
      pll_phasestep                 : out std_logic;
      pll_phasedone                 : in std_logic;
      pll_locked                    : in std_logic;
      pll_reconfig                  : in std_logic;
      pll_reset_req                 : out std_logic;
      --sample compare module
      smpl_cmp_en                   : out std_logic;
      smpl_cmp_done                 : in std_logic;
      smpl_cmp_error                : in std_logic
            
      );
end pll_ps_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pll_ps_top is
--declare signals,  components here

signal ps_tst_reg       : std_logic;
signal ps_en_reg        : std_logic;
--inst 0
signal inst0_ph_step    : std_logic;
signal inst0_ps_status  : std_logic;
signal inst0_busy       : std_logic;

--isnt1
signal inst1_ps_en            : std_logic;
signal inst1_ps_done          : std_logic;
signal inst1_ps_status        : std_logic;
signal inst1_ps_ctrl_phase    : std_logic_vector(9 downto 0);
signal inst1_ps_ctrl_en       : std_logic;
signal inst1_smpl_cmp_en      : std_logic;
signal inst1_pll_reset_req    : std_logic;
signal inst1_ps_ctrl_cnt      : std_logic_vector(2 downto 0);
signal inst1_ps_ctrl_updown   : std_logic;

signal ps_en_tst              : std_logic;
signal ps_disable_cnt         : unsigned(7 downto 0);
   
   
type state_type is (idle, check_mode, ps_enable, ps_disable);
signal current_state, next_state : state_type;


  
begin

-- ----------------------------------------------------------------------------
-- Input registers
-- ----------------------------------------------------------------------------
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         ps_tst_reg  <= '0';
         ps_en_reg   <= '0';
      elsif (clk'event AND clk='1') then 
         ps_tst_reg  <= ps_tst;
         ps_en_reg   <= ps_en;
      end if;
   end process;
   
   
-- ----------------------------------------------------------------------------
-- state machine for testing
-- ----------------------------------------------------------------------------
fsm_f : process(clk, reset_n)begin
   if(reset_n = '0')then
      current_state  <= idle;
   elsif(clk'event and clk = '1')then 
      current_state <= next_state;
   end if;	
end process;

-- ----------------------------------------------------------------------------
--state machine combo for testing
-- ----------------------------------------------------------------------------
fsm : process(current_state, ps_tst, ps_en_reg, ps_en, inst1_ps_done, ps_disable_cnt,
               inst1_ps_status) begin
   next_state <= current_state;
   case current_state is
   
      when idle =>                     -- wait for start
         if ps_en = '1' AND ps_en_reg = '0' then 
            next_state <= check_mode;
         else 
            next_state <= idle;
         end if;
         
      when check_mode =>               --check if this is test mode
         if ps_tst = '1' then 
            next_state <= ps_enable;
         else 
            next_state <= idle;
         end if;
      
      when ps_enable =>                -- enable and wait for done
         if inst1_ps_done = '1' then 
            if inst1_ps_status = '1' then 
               next_state <= idle;
            else 
               next_state <= ps_disable;
            end if;
         else 
            next_state <= ps_enable;
         end if;
         
      when ps_disable =>               -- diable and go to idle or enable again
         if ps_disable_cnt > 7 then 
            if ps_en = '1' then 
               next_state <= ps_enable;
            else 
               next_state <= idle;
            end if;
         else 
            next_state <= ps_disable;
         end if;

         
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
         ps_disable_cnt  <= (others=> '0');
      elsif (clk'event AND clk='1') then 
         if current_state = ps_disable then 
            ps_disable_cnt <= ps_disable_cnt + 1;
         else 
            ps_disable_cnt  <= (others=> '0');
         end if;
      end if;
   end process;

   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         inst1_ps_en  <= '0';
      elsif (clk'event AND clk='1') then 
         if ps_tst = '0' then 
            inst1_ps_en <= ps_en;
         else 
            if current_state = ps_enable then 
               inst1_ps_en <= '1';
            else 
               inst1_ps_en <= '0';
            end if;
         end if;
      end if;
   end process;

-- ----------------------------------------------------------------------------
-- lower level instances
-- ----------------------------------------------------------------------------   
pll_ps_inst0 : entity work.pll_ps
   port map(
      clk                     => clk,
      reset_n                 => reset_n,
      busy                    => inst0_busy,
      en                      => inst1_ps_ctrl_en,
      phase                   => inst1_ps_ctrl_phase,
      cnt                     => inst1_ps_ctrl_cnt,
      updown                  => inst1_ps_ctrl_updown,    
      --pll ports
      pll_phasecounterselect  => pll_phasecounterselect,
      pll_phaseupdown         => pll_phaseupdown,
      pll_phasestep           => pll_phasestep,
      pll_phasedone           => pll_phasedone

      );
   
   
pll_ps_fsm_inst1 : entity work.pll_ps_fsm
   port map(
      clk               => clk,
      reset_n           => reset_n,
      --module control ports
      ps_en             => inst1_ps_en,
      ps_reset_at_start => '1',
      ps_mode           => ps_mode,
      ps_cnt            => ps_cnt,
      ps_updwn          => ps_updwn,
      ps_phase          => ps_phase,
      ps_step_size      => ps_step_size,
      ps_done           => inst1_ps_done,
      ps_status         => inst1_ps_status,
      --pll ports
      pll_locked        => pll_locked,
      pll_reconfig      => pll_reconfig,
      pll_reset_req     => inst1_pll_reset_req,
      --pll_ps_cntrl ports
      ps_ctrl_busy      => inst0_busy,
      ps_ctrl_en        => inst1_ps_ctrl_en,
      ps_ctrl_phase     => inst1_ps_ctrl_phase,
      ps_ctrl_cnt       => inst1_ps_ctrl_cnt,
      ps_ctrl_updown    => inst1_ps_ctrl_updown,
      --sample compare module
      smpl_cmp_en       => inst1_smpl_cmp_en,
      smpl_cmp_done     => smpl_cmp_done,
      smpl_cmp_error    => smpl_cmp_error
      );
      
   
   
   --output ports
   ps_done        <= inst1_ps_done;
   ps_status      <= inst1_ps_status;
   smpl_cmp_en    <= inst1_smpl_cmp_en;
   pll_reset_req  <= inst1_pll_reset_req;
   

  
end arch;   


