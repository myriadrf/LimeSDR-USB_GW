-- ----------------------------------------------------------------------------
-- FILE:          general_periph_top.vhd
-- DESCRIPTION:   Top wrapper file for general periphery components
-- DATE:          3:39 PM Monday, May 7, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.periphcfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity general_periph_top is
   generic(
      DEV_FAMILY  : string := "CYCLONE IV E";
      N_GPIO      : integer := 8
   );
   port (
      -- General ports
      clk                  : in     std_logic; -- Free running clock
      reset_n              : in     std_logic; -- Asynchronous, active low reset
      
      to_periphcfg         : out    t_TO_PERIPHCFG;
      from_periphcfg       : in     t_FROM_PERIPHCFG;
      
      -- Dual colour LEDs
      -- LED1 (Clock and PLL lock status)
      led1_pll1_locked     : in     std_logic;
      led1_pll2_locked     : in     std_logic;
      led1_ctrl            : in     std_logic_vector(2 downto 0);
      led1_g               : out    std_logic;
      led1_r               : out    std_logic;
      
      --LED2 (TCXO control status)
      led2_clk             : in     std_logic;
      led2_adf_muxout      : in     std_logic;
      led2_dac_ss          : in     std_logic;
      led2_adf_ss          : in     std_logic;
      led2_ctrl            : in     std_logic_vector(2 downto 0);
      led2_g               : out    std_logic;
      led2_r               : out    std_logic;
      
      --LED3 (FX3 and NIOS CPU busy)
      led3_g_in            : in     std_logic;
      led3_r_in            : in     std_logic;
      led3_ctrl            : in     std_logic_vector(2 downto 0);
      led3_hw_ver          : in     std_logic_vector(3 downto 0);
      led3_g               : out    std_logic;
      led3_r               : out    std_logic;
      
      --GPIO
      gpio_dir             : in     std_logic_vector(N_GPIO-1 downto 0);
      gpio_out_val         : in     std_logic_vector(N_GPIO-1 downto 0);
      gpio_rd_val          : out    std_logic_vector(N_GPIO-1 downto 0);
      gpio                 : inout  std_logic_vector(N_GPIO-1 downto 0); -- to FPGA pins
      
      --Fan control
      fan_sens_in          : in     std_logic;
      fan_ctrl_out         : out    std_logic

   );
end general_periph_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of general_periph_top is
--declare signals,  components here
--inst0
signal inst0_beat : std_logic; 

--inst1 
signal inst1_board_gpio_ovrd        : std_logic_vector(15 downto 0);
signal inst1_board_gpio_rd          : std_logic_vector(15 downto 0);
signal inst1_board_gpio_dir         : std_logic_vector(15 downto 0);
signal inst1_board_gpio_val         : std_logic_vector(15 downto 0);
signal inst1_periph_input_rd_0      : std_logic_vector(15 downto 0);
signal inst1_periph_input_rd_1      : std_logic_vector(15 downto 0);
signal inst1_periph_output_ovrd_0   : std_logic_vector(15 downto 0);
signal inst1_periph_output_val_0    : std_logic_vector(15 downto 0);
signal inst1_periph_output_ovrd_1   : std_logic_vector(15 downto 0);
signal inst1_periph_output_val_1    : std_logic_vector(15 downto 0);

--inst5
signal inst5_gpio_in                : std_logic_vector(N_GPIO-1 downto 0);
signal inst5_mux_sel                : std_logic_vector(N_GPIO-1 downto 0);
signal inst5_dir_0                  : std_logic_vector(N_GPIO-1 downto 0);
signal inst5_dir_1                  : std_logic_vector(N_GPIO-1 downto 0);
signal inst5_out_val_0              : std_logic_vector(N_GPIO-1 downto 0);
signal inst5_out_val_1              : std_logic_vector(N_GPIO-1 downto 0);

begin
   
-- ----------------------------------------------------------------------------
-- Alive instance
-- Simple counter to toggle output
-- ----------------------------------------------------------------------------   
   alive_inst0 : entity work.alive
   port map(
      clk      => clk,
      reset_n  => reset_n,
      beat     => inst0_beat
   );

   process(inst5_gpio_in)
   begin 
      inst1_board_gpio_rd <= (others=>'0');
      inst1_board_gpio_rd(N_GPIO-1 downto 0) <= inst5_gpio_in;
   end process;
   
   inst1_periph_input_rd_0 <= (others=>'0');
   inst1_periph_input_rd_1 <= (others=>'0');
   
-- ----------------------------------------------------------------------------
-- FPGA_LED1_cntrl instance
-- Blinking indicates presence of TCXO clock.
-- Colour indicates status of FPGA PLLs that are used for LMS digital interface clocking: 
-- Green - both PLLs are locked; Red/Green - at least one -- PLL is not locked.
-- ----------------------------------------------------------------------------    
   FPGA_LED1_cntrl_inst2 : entity work.FPGA_LED1_cntrl
   port map(
      pll1_locked    => led1_pll1_locked,
      pll2_locked    => led1_pll2_locked,
      alive          => inst0_beat,
      led_ctrl       => led1_ctrl,
      led_g          => led1_g,
      led_r          => led1_r
   );
-- ----------------------------------------------------------------------------
-- FPGA_LED2_ctrl instance
-- No light - TCXO is controlled from DAC
-- Red - TCXO is controlled from phase detector and is not locked to external reference clock,
-- Green - TCXO is controlled from phase detector and is -- locked to external reference clock
-- ---------------------------------------------------------------------------- 
   FPGA_LED2_ctrl_inst3 : entity work.FPGA_LED2_ctrl
      port map(
         clk            => led2_clk,
         reset_n        => reset_n,
         adf_muxout     => led2_adf_muxout,
         dac_ss         => led2_dac_ss,
         adf_ss         => led2_adf_ss,
         led_ctrl       => led2_ctrl,
         led_g          => led2_g,
         led_r          => led2_r
      );
-- ----------------------------------------------------------------------------
-- FX3_LED_ctrl instance
-- USB3.0 (FX3) controller, slave FIFO (GPIF) interface module and NIOS CPU activity indication:
-- Green - idle, Red - busy.
-- ---------------------------------------------------------------------------- 
   FX3_LED_ctrl_inst4 : entity work.FX3_LED_ctrl
      port map(
         ctrl_led_g     => led3_g_in,
         ctrl_led_r     => led3_r_in,
         HW_VER         => led3_hw_ver,
         led_ctrl       => led3_ctrl,
         led_g          => led3_g,
         led_r          => led3_r
      );

-- ----------------------------------------------------------------------------
-- gpio_ctrl_top instance
-- ----------------------------------------------------------------------------      
   gpio_ctrl_top_inst5 : entity work.gpio_ctrl_top
   generic map(
      bus_width   => N_GPIO
   )
   port map(
      gpio        => gpio,
      gpio_in     => inst5_gpio_in,
      mux_sel     => inst5_mux_sel,
      dir_0       => gpio_dir,
      dir_1       => inst5_dir_1,
      out_val_0   => gpio_out_val,
      out_val_1   => inst5_out_val_1

   );
   
   
   inst5_mux_sel   <= from_periphcfg.BOARD_GPIO_OVRD(N_GPIO-1 downto 0);
   inst5_dir_1     <= from_periphcfg.BOARD_GPIO_DIR(N_GPIO-1 downto 0);
   inst5_out_val_1 <= from_periphcfg.BOARD_GPIO_VAL(N_GPIO-1 downto 0);
   
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------      
      
   fan_ctrl_out   <= fan_sens_in when from_periphcfg.PERIPH_OUTPUT_OVRD_0(0) = '0' else 
                     from_periphcfg.PERIPH_OUTPUT_VAL_0(0);
                     
   gpio_rd_val    <= inst5_gpio_in;
   
   process(inst5_gpio_in)
   begin 
      to_periphcfg.BOARD_GPIO_RD <= (others=>'0');
      to_periphcfg.BOARD_GPIO_RD(N_GPIO-1 downto 0) <= inst5_gpio_in;
   end process;
   
   process(fan_sens_in)
   begin 
      to_periphcfg.PERIPH_INPUT_RD_0 <= (others=>'0');
      to_periphcfg.PERIPH_INPUT_RD_0(0) <= fan_sens_in;
   end process;
   
   to_periphcfg.PERIPH_INPUT_RD_1 <= (others=>'0');
                     
      
end arch;   


