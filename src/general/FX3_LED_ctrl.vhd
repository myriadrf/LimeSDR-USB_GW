-- ----------------------------------------------------------------------------
-- FILE:          FX3_LED_ctrl.vhd
-- DESCRIPTION:   FX3 led status module
-- DATE:          5:03 PM Monday, May 7, 2018
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
entity FX3_LED_ctrl is
   port (
      --input ports 
      ctrl_led_g     : in std_logic;
      ctrl_led_r     : in std_logic;
      HW_VER         : in std_logic_vector(3 downto 0);
      led_ctrl       : in std_logic_vector(2 downto 0);
      --output ports 
      led_g          : out std_logic;
      led_r          : out std_logic
   );
end FX3_LED_ctrl;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of FX3_LED_ctrl is
--declare signals,  components here
   signal led_g_def  : std_logic;
   signal led_r_def  : std_logic;
   
   signal led_g_ovr  : std_logic;
   signal led_r_ovr  : std_logic;


  
begin

   led_g_ovr <= '1' when led_ctrl(2)='1' and led_ctrl(1)='0' else '0';
   led_r_ovr <= '1' when led_ctrl(1)='1' and led_ctrl(2)='0' else '0';

   led_g_def <= ctrl_led_g when led_ctrl(0)='0' else led_g_ovr;
   led_r_def <= ctrl_led_r when led_ctrl(0)='0' else led_r_ovr;

   led_g <= led_g_def when unsigned(HW_VER)>=3 and unsigned(HW_VER)< 15 else '0';
   led_r <= led_r_def when unsigned(HW_VER)>=3 and unsigned(HW_VER)< 15 else '0';
  
end arch;


