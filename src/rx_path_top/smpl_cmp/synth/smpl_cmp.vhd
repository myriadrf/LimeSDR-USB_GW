-- ----------------------------------------------------------------------------
-- FILE:          smpl_cmp.vhd
-- DESCRIPTION:   sample compare module  
-- DATE:          5:19 PM Monday, December 11, 2017
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
entity smpl_cmp is
   generic(
      smpl_width  : integer := 12
   );
   port (

      clk            : in std_logic;
      reset_n        : in std_logic;
      --Mode settings
      mode           : in std_logic; -- JESD207: 1; TRXIQ: 0
      trxiqpulse     : in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
      ddr_en         : in std_logic; -- DDR: 1; SDR: 0
      mimo_en        : in std_logic; -- SISO: 1; MIMO: 0
      ch_en          : in std_logic_vector(1 downto 0); --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B.
      fidm           : in std_logic;
      --control and status
      cmp_start      : in std_logic := '0';
      cmp_length     : in std_logic_vector(15 downto 0) := x"00FF";  -- buffer length to check
      cmp_AI         : in std_logic_vector(smpl_width-1 downto 0);   -- values to compare with
      cmp_AQ         : in std_logic_vector(smpl_width-1 downto 0);   
      cmp_BI         : in std_logic_vector(smpl_width-1 downto 0);
      cmp_BQ         : in std_logic_vector(smpl_width-1 downto 0);
      cmp_done       : out std_logic;     -- '1' - indicates when sample compare is done
      cmp_error      : out std_logic;     -- '0' - no errors, '1' - captured error
      cmp_error_cnt  : out std_logic_vector(15 downto 0);
      --DIQ bus
      diq_h          : in std_logic_vector(smpl_width downto 0);
      diq_l          : in std_logic_vector(smpl_width downto 0)  
        );
end smpl_cmp;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of smpl_cmp is
--declare signals,  components here
signal diq_h_reg        : std_logic_vector(smpl_width downto 0);
signal diq_l_reg        : std_logic_vector(smpl_width downto 0);
signal fidm_reg         : std_logic;
signal cmp_done_reg     : std_logic;
signal cmp_start_reg    : std_logic;
signal cmp_error_reg    : std_logic;
signal cmp_error_cnt_reg: std_logic_vector(15 downto 0);

signal AI_err           : std_logic;
signal AQ_err           : std_logic;
signal BI_err           : std_logic;
signal BQ_err           : std_logic;
signal IQ_SEL_err       : std_logic;
signal smpl_err         : std_logic;
signal smpl_err_cnt     : unsigned(15 downto 0);


signal compare_cnt      : unsigned(15 downto 0);
signal wait_cnt         : unsigned(3 downto 0);
signal compare_stop     : std_logic;

type state_type is (idle, wait_cyc, compare, compare_done);
signal current_state, next_state : state_type;


  
begin
-- ----------------------------------------------------------------------------
-- Input registers
-- ----------------------------------------------------------------------------  
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         diq_h_reg         <= (others=>'0');
         diq_l_reg         <= (others=>'0');
         fidm_reg          <= '0';
         cmp_start_reg     <= '0';
      elsif (clk'event AND clk='1') then 
         diq_h_reg      <= diq_h;
         diq_l_reg      <= diq_l;
         fidm_reg       <= fidm;
         cmp_start_reg  <= cmp_start;
      end if;
   end process;

  
-- ----------------------------------------------------------------------------
-- Compare samples
-- ----------------------------------------------------------------------------
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         AI_err      <= '0';
         AQ_err      <= '0';
         BI_err      <= '0';
         BQ_err      <= '0';
         IQ_SEL_err  <= '0';
         smpl_err    <= '0';
      elsif (clk'event AND clk='1') then
         smpl_err <= AI_err OR AQ_err OR BI_err OR BQ_err OR IQ_SEL_err;
         
         --compare IQ_SEL signal
         if diq_h_reg(smpl_width) = diq_l_reg(smpl_width) then 
            IQ_SEL_err <= '0';
         else 
            IQ_SEL_err <= '1';
         end if;
         
         --compare ch. A samples
         if diq_h_reg(smpl_width) = fidm_reg AND diq_l_reg(smpl_width) = fidm_reg then 
            --AI
            if diq_l_reg(smpl_width-1 downto 0) = cmp_AI then 
               AI_err <= '0';
            else 
               AI_err <= '1';
            end if;
            --AQ
            if diq_h_reg(smpl_width-1 downto 0) = cmp_AQ then 
               AQ_err <= '0';
            else 
               AQ_err <= '1';
            end if;         
         else 
            AI_err <= AI_err;
            AQ_err <= AQ_err;
         end if;
         
         --compare ch. B samples
         if diq_h_reg(smpl_width) /= fidm_reg AND diq_l_reg(smpl_width) /= fidm_reg then 
            --BI
            if diq_l_reg(smpl_width-1 downto 0) = cmp_BI then 
               BI_err <= '0';
            else 
               BI_err <= '1';
            end if;
            --BQ
            if diq_h_reg(smpl_width-1 downto 0) = cmp_BQ then 
               BQ_err <= '0';
            else 
               BQ_err <= '1';
            end if;  
         else 
            BI_err <= BI_err;
            BQ_err <= BQ_err;
         end if;
      end if;
   end process;
   
-- ----------------------------------------------------------------------------
-- Counter
-- ----------------------------------------------------------------------------  
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         compare_cnt    <= (others=>'0');
         compare_stop   <= '0';
      elsif (clk'event AND clk='1') then
         if current_state = compare then 
            compare_cnt <= compare_cnt + 1;
         else 
            compare_cnt <= (others=>'0');
         end if;
         
         if compare_cnt > unsigned(cmp_length) - 1 then 
            compare_stop <= '1';
         else 
            compare_stop <= '0';
         end if;
         
      end if;
   end process; 
     
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         wait_cnt <= (others=>'0');
      elsif (clk'event AND clk='1') then 
         if current_state = wait_cyc then 
            wait_cnt <= wait_cnt + 1;
         else 
            wait_cnt <= (others=>'0');
         end if;
      end if;
   end process;
   
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         smpl_err_cnt   <= (others => '0');
         cmp_error_cnt_reg  <= (others => '0');
      elsif (clk'event AND clk='1') then 
         if current_state = compare then 
            if smpl_err = '1' then 
               smpl_err_cnt <= smpl_err_cnt + 1;
            else 
               smpl_err_cnt <= smpl_err_cnt;
            end if;
         else 
            smpl_err_cnt <= (others => '0');
         end if;
         
         if current_state = compare_done then 
            cmp_error_cnt_reg <= std_logic_vector(smpl_err_cnt);
         elsif current_state = compare then 
            cmp_error_cnt_reg  <= (others => '0');
         else 
            cmp_error_cnt_reg <= cmp_error_cnt_reg;
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
fsm : process(current_state, cmp_start, cmp_start_reg, compare_stop, smpl_err, wait_cnt) begin
	next_state <= current_state;
	case current_state is
	  
		when idle =>                     -- wait for start
         if cmp_start = '1' AND cmp_start_reg = '0' then 
            next_state <= wait_cyc;
         else
            next_state <= idle;
         end if;
         
      when wait_cyc =>                 -- wait clock cycles to capture registers and errors
         if wait_cnt > 3 then 
            next_state <= compare;
         else 
            next_state <= wait_cyc;
         end if;
                
      when compare =>                  -- state to compare samples
         if compare_stop = '1' OR smpl_err = '1' then
         --if compare_stop = '1' then
            next_state <= compare_done;
         else 
            next_state <= compare;
         end if;
       
      when compare_done => 
         next_state <= idle;
           
		when others => 
			next_state <= idle;
	end case;
end process;

-- ----------------------------------------------------------------------------
-- Output registers
-- ----------------------------------------------------------------------------
process(clk, reset_n)
begin
   if reset_n = '0' then 
      cmp_done_reg <= '0';
   elsif (clk'event AND clk='1') then 
      if current_state = compare_done then 
         cmp_done_reg <= '1';
      elsif current_state = idle AND cmp_start = '0' then 
         cmp_done_reg <= '0';
      else 
         cmp_done_reg <= cmp_done_reg;
      end if;
   end if;
end process;

process(clk, reset_n)
begin
   if reset_n = '0' then 
      cmp_error_reg <= '0';
   elsif (clk'event AND clk='1') then 
      if smpl_err = '1' and current_state = compare then 
         cmp_error_reg <= '1';
      elsif current_state = idle AND cmp_start = '0'then 
         cmp_error_reg <= '0';
      else 
         cmp_error_reg <= cmp_error_reg;
      end if;
   end if;
end process;



cmp_done       <= cmp_done_reg;
cmp_error      <= cmp_error_reg;

cmp_error_cnt <= cmp_error_cnt_reg;

end arch;   





