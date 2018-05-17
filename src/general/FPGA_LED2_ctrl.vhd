-- ----------------------------------------------------------------------------
-- FILE:          FPGA_LED2_ctrl.vhd
-- DESCRIPTION:   displays adf and dac status. 
-- DATE:          4:56 PM Monday, May 7, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES: If dac is used no led, if adf - adf locked green not locked red
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity FPGA_LED2_ctrl is
   port (
      --input ports 
      clk            : in std_logic;
      reset_n        : in std_logic;
      adf_muxout     : in std_logic;
      dac_ss         : in std_logic;
      adf_ss         : in std_logic;
      led_ctrl       : in std_logic_vector(2 downto 0);
      --output ports
      led_g          : out std_logic;
      led_r          : out std_logic
      );
end FPGA_LED2_ctrl;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of FPGA_LED2_ctrl is
--declare signals,  components here
signal last_val   : std_logic_vector (1 downto 0);
signal led_g_def  : std_logic;
signal led_r_def  : std_logic;

signal led_g_ovr  : std_logic;
signal led_r_ovr  : std_logic;

begin

   process(reset_n, clk)
   begin
      if reset_n='0' then
         last_val<="10"; 
      elsif (clk'event and clk = '1') then
         if dac_ss='0' then 
            last_val<="00";
         elsif adf_ss='0' then 
            last_val<="10";
         else 
            last_val<=last_val;
         end if;
      end if;
   end process;
   
   led_g_ovr <= '1' when led_ctrl(2)='1' and led_ctrl(1)='0' else '0';
   led_r_ovr <= '1' when led_ctrl(1)='1' and led_ctrl(2)='0' else '0';	 

   led_g_def <=   '0' when last_val="00" else 
                  '1' when last_val="10" and adf_muxout='1' else 
                  '0';
  
   led_r_def <=   '0' when last_val="00" else 
                  '1' when last_val="10" and adf_muxout='0' else 
                  '0'; 
  
   led_g<= led_g_def when led_ctrl(0)='0' else led_g_ovr;
   led_r<= led_r_def when led_ctrl(0)='0' else led_r_ovr;  
  
  
end arch;

