-- ----------------------------------------------------------------------------
-- FILE:          gpio_ctrl_top.vhd
-- DESCRIPTION:   GPIO with controled direction
-- DATE:          5:23 PM Monday, May 7, 2018
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
entity gpio_ctrl_top is
   generic(
      bus_width   : integer := 8
   );
   port (
      gpio        : inout  std_logic_vector(bus_width-1 downto 0);
      gpio_in     : out    std_logic_vector(bus_width-1 downto 0);
      mux_sel     : in     std_logic_vector(bus_width-1 downto 0);   -- mux select
      dir_0       : in     std_logic_vector(bus_width-1 downto 0);   -- 0 - input, 1 - output.
      dir_1       : in     std_logic_vector(bus_width-1 downto 0);   -- 0 - input, 1 - output.
      out_val_0   : in     std_logic_vector(bus_width-1 downto 0);
      out_val_1   : in     std_logic_vector(bus_width-1 downto 0)

   );
end gpio_ctrl_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of gpio_ctrl_top is
--declare signals,  components here
 
begin


--Generate components for all bus bits
gpio_ctrl_gen : for i in 0 to bus_width-1 generate 
   gpio_ctrl_bitx	: entity work.gpio_ctrl 
      port map (
      gpio        => gpio(i),
      gpio_in     => gpio_in(i),
      mux_sel     => mux_sel(i),
      dir_0       => dir_0(i),
      dir_1       => dir_1(i),
      out_val_0   => out_val_0(i),
      out_val_1   => out_val_1(i)
      );
end generate gpio_ctrl_gen;

  
end arch;





