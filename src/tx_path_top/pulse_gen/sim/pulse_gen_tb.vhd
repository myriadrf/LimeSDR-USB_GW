-- ----------------------------------------------------------------------------	
-- FILE: pulse_gen_tb.vhd
-- DESCRIPTION: 
-- DATE: August 25, 2017
-- AUTHOR(s): asLime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pulse_gen_tb is
end pulse_gen_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of pulse_gen_tb is
   constant clk0_period       : time := 10 ns;
   constant clk1_period       : time := 10 ns;
   constant dut0_wait_cycles  : std_logic_vector(31 downto 0) := x"00000002";
   
   --signals
   signal clk0,clk1           : std_logic;
   signal reset_n             : std_logic; 

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
   
   
   pulse_gen_dut0 : entity work.pulse_gen
   port map(

      clk         => clk0,
      reset_n     => reset_n,
      wait_cycles => dut0_wait_cycles,
      pulse       => open
   );
   

   
   end tb_behave;
  

