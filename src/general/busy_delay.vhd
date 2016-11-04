-- ----------------------------------------------------------------------------	
-- FILE: 	busy_delay.vhd
-- DESCRIPTION:	describe
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity busy_delay is
   generic(
      clock_period 	: integer := 10;      -- input clock period in ns
      delay_time 		: integer := 100       -- delay time in ms
		--counter_value=delay_time*1000/clock_period<2^32
		--delay counter is 32bit wide, 
   );
   port(
      --input ports 
      clk      : in  std_logic;
      reset_n  : in  std_logic;
      busy_in  : in  std_logic;
      busy_out : out std_logic
   );
end busy_delay;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of busy_delay is
   --declare signals,  components here
   signal cnt         : unsigned(31 downto 0);
   signal busy_in_reg : std_logic_vector(2 downto 0);
	signal busy_rising : std_logic;
	signal busy_falling: std_logic;
   signal cnt_reset   : std_logic;
   signal cnt_en      : std_logic;
   signal cnt_max     : unsigned(31 downto 0);
	constant	cnt_max_integer	: integer := (delay_time*1000000)/clock_period;


   type state_type is (idle, reset_counter, delay_busy);
   signal current_state, next_state : state_type;

begin

   cnt_max <= to_unsigned(cnt_max_integer, cnt_max'length);


	process(current_state) 
	begin 
		if current_state =  reset_counter then 
			cnt_reset<= '1';
		else 
			cnt_reset <= '0';
		end if;
	end process;

   sync_reg : process(reset_n, clk)
   begin
      if reset_n = '0' then
         busy_in_reg <= (others => '0');
      elsif (clk'event and clk = '1') then
         busy_in_reg <= busy_in_reg(1 downto 0) & busy_in;
      end if;
   end process;

   busy_out_sig : process(reset_n, clk)
   begin
      if reset_n = '0' then
         busy_out <= '0';
      elsif (clk'event and clk = '1') then
         if current_state = delay_busy or busy_in_reg(2)='1' then 
				busy_out <= '1';
			else 
				busy_out <= '0';
			end if;	
      end if;
   end process;


   busy_rising  <= '1' when busy_in_reg(2 downto 1) = "01" else '0';
   busy_falling <= '1' when busy_in_reg(2 downto 1) = "10" else '0';

	process(current_state, busy_in_reg) 
	begin 
		if current_state =  delay_busy and busy_in_reg(2)='0' then 
			cnt_en<= '1';
		else 
			cnt_en <= '0';
		end if;
	end process;

   cnt_proc : process(reset_n, clk)
   begin
      if reset_n = '0' then
         cnt <= (others => '0');
      elsif (clk'event and clk = '1') then
         if cnt_reset = '1' then
            cnt <= (others => '0');
         elsif cnt_en = '1' then
            if cnt < cnt_max then
               cnt <= cnt + 1;
            else
               cnt <= (others => '0');
            end if;
         else
            cnt <= cnt;
         end if;
      end if;
   end process;

   -- ----------------------------------------------------------------------------
   --state machine
   -- ----------------------------------------------------------------------------
   fsm_f : process(clk, reset_n)
   begin
      if (reset_n = '0') then
         current_state <= idle;
      elsif (clk'event and clk = '1') then
         current_state <= next_state;
      end if;
   end process;

   -- ----------------------------------------------------------------------------
   --state machine combo
   -- ----------------------------------------------------------------------------
   fsm : process(current_state, busy_rising, cnt_max, cnt)
   begin
      next_state <= current_state;
      case current_state is
         when idle =>                   --idle state
            if busy_rising='1' then 
               next_state <= reset_counter;
            else 
               next_state <= idle;
            end if;
              
         when reset_counter =>			--reset counter
            next_state <= delay_busy;
            
         when delay_busy => 				--reset cnt if busy is captured again and wait for delay time
				if busy_rising = '1' then 
					next_state <= reset_counter;
				else
					if cnt = cnt_max then 
               	next_state <= idle;
					else 
						next_state <= delay_busy;	
					end if; 
				end if;
            
         when others        =>
            next_state <= idle;
      end case;
   end process;

end arch;   







