-- ----------------------------------------------------------------------------
-- FILE:          tstcfg_pkg.vhd
-- DESCRIPTION:   Package for tstcfg module
-- DATE:          9:57 AM Monday, May 14, 2018
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
package tstcfg_pkg is
   
   -- Outputs from the 
   type t_FROM_TSTCFG is record
   	TEST_EN					: std_logic_vector(5 downto 0);
		TEST_FRC_ERR			: std_logic_vector(5 downto 0);
      TX_TST_I					: std_logic_vector(15 downto 0);
		TX_TST_Q					: std_logic_vector(15 downto 0);
   end record t_FROM_TSTCFG;
  
   -- Inputs to the .
   type t_TO_TSTCFG is record
		TEST_CMPLT				: std_logic_vector(5 downto 0);
		TEST_REZ					: std_logic_vector(5 downto 0);
		FX3_CLK_CNT				: std_logic_vector(15 downto 0);
		Si5351C_CLK0_CNT		: std_logic_vector(15 downto 0);
		Si5351C_CLK1_CNT		: std_logic_vector(15 downto 0);
		Si5351C_CLK2_CNT		: std_logic_vector(15 downto 0);
		Si5351C_CLK3_CNT		: std_logic_vector(15 downto 0);
		Si5351C_CLK5_CNT		: std_logic_vector(15 downto 0);
		Si5351C_CLK6_CNT		: std_logic_vector(15 downto 0);
		Si5351C_CLK7_CNT		: std_logic_vector(15 downto 0);
		LMK_CLK_CNT				: std_logic_vector(23 downto 0);
		ADF_CNT					: std_logic_vector(15 downto 0);		
		DDR2_2_STATUS			: std_logic_vector(2 downto 0);
		DDR2_2_pnf_per_bit   : std_logic_vector(31 downto 0);
   end record t_TO_TSTCFG;
   
   type t_TO_TSTCFG_FROM_RXTX is record
		DDR2_1_STATUS			: std_logic_vector(2 downto 0);
		DDR2_1_pnf_per_bit	: std_logic_vector(31 downto 0);
   end record t_TO_TSTCFG_FROM_RXTX;
   

end package tstcfg_pkg;