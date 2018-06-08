-- ----------------------------------------------------------------------------
-- FILE:          fpgacfg_pkg.vhd
-- DESCRIPTION:   Package for fpgacfg module
-- DATE:          11:13 AM Friday, May 11, 2018
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
-- Package declaration
-- ----------------------------------------------------------------------------
package fpgacfg_pkg is
   
   -- Outputs from the fpgacfg.
   type t_FROM_FPGACFG is record
      --FPGA direct clocking
      phase_reg_sel  : std_logic_vector(15 downto 0);
      clk_ind        : std_logic_vector(4 downto 0);
      cnt_ind        : std_logic_vector(4 downto 0);
      load_phase_reg : std_logic;
      drct_clk_en    : std_logic_vector(15 downto 0);
      --Interface Config
      ch_en          : std_logic_vector(15 downto 0);
      smpl_width     : std_logic_vector(1 downto 0);
      mode           : std_logic;
      ddr_en         : std_logic;
      trxiq_pulse    : std_logic;
      mimo_int_en    : std_logic;
      synch_dis      : std_logic;
      synch_mode     : std_logic;
      smpl_nr_clr    : std_logic;
      txpct_loss_clr : std_logic;
      rx_en          : std_logic;
      tx_en          : std_logic;
      rx_ptrn_en     : std_logic;
      tx_ptrn_en     : std_logic;
      tx_cnt_en      : std_logic;
      wfm_ch_en      : std_logic_vector(15 downto 0);
      wfm_play       : std_logic;
      wfm_load       : std_logic;
      wfm_smpl_width : std_logic_vector(1 downto 0);
      SPI_SS         : std_logic_vector(15 downto 0);
      
      LMS1_SS        : std_logic;
      -- LMS2_SS     : std_logic;
      -- ADF_SS      : std_logic;
      -- DAC_SS      : std_logic;
      -- POT1_SS     : std_logic;
      
      LMS1_RESET        : std_logic;
      LMS1_CORE_LDO_EN  : std_logic;
      LMS1_TXNRX1       : std_logic;
      LMS1_TXNRX2       : std_logic;
      LMS1_TXEN         : std_logic;
      LMS1_RXEN         : std_logic;
      -- LMS2_RESET        : std_logic;
      -- LMS2_CORE_LDO_EN  : std_logic;
      -- LMS2_TXNRX1       : std_logic;
      -- LMS2_TXNRX2       : std_logic;
      -- LMS2_TXEN         : std_logic;
      -- LMS2_RXEN         : std_logic;
      GPIO              : std_logic_vector(15 downto 0);
      FPGA_LED1_CTRL    : std_logic_vector(2 downto 0);
      FPGA_LED2_CTRL    : std_logic_vector(2 downto 0);
      FX3_LED_CTRL      : std_logic_vector(2 downto 0);
      CLK_ENA           : std_logic_vector(3 downto 0);
      sync_pulse_period : std_logic_vector(31 downto 0);
      sync_size         : std_logic_vector(15 downto 0);
      txant_pre         : std_logic_vector(15 downto 0);
      txant_post        : std_logic_vector(15 downto 0);
   end record t_FROM_FPGACFG;
  
   -- Inputs to the fpgacfg.
   type t_TO_FPGACFG is record
      HW_VER   : std_logic_vector(3 downto 0);
      BOM_VER  : std_logic_vector(3 downto 0);
      PWR_SRC  : std_logic;
   end record t_TO_FPGACFG;
   

      
end package fpgacfg_pkg;