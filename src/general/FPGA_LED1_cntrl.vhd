-- ----------------------------------------------------------------------------
-- FILE:          FPGA_LED1_cntrl.vhd
-- DESCRIPTION:   FPGA_LED1 control module
-- DATE:          4:36 PM Monday, May 7, 2018
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
entity FPGA_LED1_cntrl is
   port (
      --input ports 
      pll1_locked    : in std_logic;
      pll2_locked    : in std_logic;
      alive          : in std_logic;
      led_ctrl       : in std_logic_vector(2 downto 0);
      --output ports 
      led_g          : out std_logic;
      led_r          : out std_logic
      
   );
end FPGA_LED1_cntrl;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of FPGA_LED1_cntrl is
signal all_pll_locked   : std_logic;
signal led_g_ovr        : std_logic;
signal led_r_ovr        : std_logic;
signal led_r_def        : std_logic;
  
begin


led_g_ovr<= '1' when led_ctrl(2)='1' and led_ctrl(1)='0' else '0';
led_r_ovr<= '1' when led_ctrl(1)='1' and led_ctrl(2)='0' else '0';

all_pll_locked <= pll1_locked and pll2_locked;
led_r_def      <= not alive when all_pll_locked='0' else 
                  '0';
                  
led_g <= alive when led_ctrl(0)='0' else led_g_ovr;
led_r <= led_r_def when led_ctrl(0)='0' else led_r_ovr;
  
end arch;

