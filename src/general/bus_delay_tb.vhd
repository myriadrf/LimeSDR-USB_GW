-- ----------------------------------------------------------------------------  
-- FILE:    busy_delay_tb.vhd
-- DESCRIPTION:   
-- DATE: Feb 13, 2014
-- AUTHOR(s):  Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------  
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity busy_delay_tb is
end busy_delay_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of busy_delay_tb is
   constant clk0_period   : time := 10 ns;
   constant clk1_period   : time := 10 ns; 
  --signals
   signal clk0,clk1     : std_logic;
   signal reset_n       : std_logic; 
   signal busy_sign     : std_logic;
  
begin 
  
      clock0: process is
   begin
      clk0 <= '0'; wait for clk0_period/2;
      clk0 <= '1'; wait for clk0_period/2;
   end process clock0;

      clock: process is
   begin
      clk1 <= '0'; wait for clk1_period/2;
      clk1 <= '1'; wait for clk1_period/2;
   end process clock;
   
      res: process is
   begin
      reset_n <= '0'; wait for 20 ns;
      reset_n <= '1'; wait;
   end process res;
   
      busy : process is
   begin
      busy_sign <= '0'; wait for 40 ns;
      busy_sign <= '1'; wait for 50 ns;
      busy_sign <= '0'; wait for 40 ns;
      busy_sign <= '0'; wait for 40 ns;
      busy_sign <= '1'; wait for 50 ns;
		busy_sign <= '0'; wait;
   end process busy;
   
  busy_delay_inst : entity work.busy_delay
generic map (
      clock_period 	=> 10,
      delay_time 		=> 1  -- delay time in ms
)
port map(
   clk         => clk1,
   reset_n     => reset_n, 
   busy_in     => busy_sign, 
   busy_out    => open
   
    );
   
   end tb_behave;
  
  


  
