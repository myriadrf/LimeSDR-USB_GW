-- ----------------------------------------------------------------------------	
-- FILE: pulse_gen.vhd
-- DESCRIPTION: generates one clk cycle long pulse 
-- DATE: August 25, 2017
-- AUTHOR(s): Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pulse_gen is
   port (
      clk         : in std_logic;
      reset_n     : in std_logic;
      wait_cycles : in std_logic_vector(31 downto 0);
      pulse       : out std_logic
   );
end pulse_gen;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pulse_gen is
--declare signals,  components here
signal cnt           : unsigned(31 downto 0);
signal cnt_max       : unsigned(31 downto 0);

  
begin


process(reset_n, clk)
begin
   if reset_n='0' then
      cnt      <= (others=>'0');
      cnt_max  <= (others=>'0');
      pulse <= '0';
      elsif (clk'event and clk = '1') then
         cnt_max <= unsigned(wait_cycles)-1;
         if cnt = cnt_max then 
            cnt <= (others => '0');
            pulse <= '1';
         else 
            cnt <= cnt + 1;
            pulse <= '0';
         end if;         
      end if;
end process;
  
end arch;   





