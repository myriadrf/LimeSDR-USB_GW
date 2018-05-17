-- ----------------------------------------------------------------------------
-- FILE:          tst_top.vhd
-- DESCRIPTION:   Test module
-- DATE:          10:55 AM Monday, May 14, 2018?
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tstcfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity tst_top is
   port (
      --input ports 
      FX3_clk              : in std_logic;
      reset_n              : in std_logic;
      
      Si5351C_clk_0        : in std_logic;
      Si5351C_clk_1        : in std_logic;
      Si5351C_clk_2        : in std_logic;
      Si5351C_clk_3        : in std_logic;
      Si5351C_clk_5        : in std_logic;
      Si5351C_clk_6        : in std_logic;
      Si5351C_clk_7        : in std_logic;
      LMK_CLK              : in std_logic;
      ADF_MUXOUT           : in std_logic;
      
      --DDR2 external memory signals	
      mem_pllref_clk       : in std_logic;
      mem_odt              : out std_logic_vector (0 DOWNTO 0);
      mem_cs_n             : out std_logic_vector (0 DOWNTO 0);
      mem_cke              : out std_logic_vector (0 DOWNTO 0);
      mem_addr             : out std_logic_vector (12 DOWNTO 0);
      mem_ba               : out std_logic_vector (2 DOWNTO 0);
      mem_ras_n            : out std_logic;
      mem_cas_n            : out std_logic;
      mem_we_n             : out std_logic;
      mem_dm               : out std_logic_vector (1 DOWNTO 0);
      mem_clk              : inout std_logic_vector (0 DOWNTO 0);
      mem_clk_n            : inout std_logic_vector (0 DOWNTO 0);
      mem_dq               : inout std_logic_vector (15 DOWNTO 0);
      mem_dqs              : inout std_logic_vector (1 DOWNTO 0);
      
      -- To configuration memory
      to_tstcfg            : out t_TO_TSTCFG;
      from_tstcfg          : in t_FROM_TSTCFG
   );
end tst_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of tst_top is
--declare signals,  components here
signal my_sig_name : std_logic_vector (7 downto 0); 

  
begin

-- ----------------------------------------------------------------------------
-- clock_test instance
-- ----------------------------------------------------------------------------
   clock_test_inst0 : entity work.clock_test
   port map(
      --input ports 
      FX3_clk           => FX3_clk,
      reset_n           => reset_n,
      test_en           => from_tstcfg.TEST_EN(3 downto 0),
      test_frc_err      => from_tstcfg.TEST_FRC_ERR(3 downto 0),
      test_cmplt        => to_tstcfg.TEST_CMPLT(3 downto 0),
      test_rez          => to_tstcfg.TEST_REZ(3 downto 0),      
      Si5351C_clk_0     => Si5351C_clk_0,
      Si5351C_clk_1     => Si5351C_clk_1,
      Si5351C_clk_2     => Si5351C_clk_2,
      Si5351C_clk_3     => Si5351C_clk_3,
      Si5351C_clk_5     => Si5351C_clk_5,
      Si5351C_clk_6     => Si5351C_clk_6,
      Si5351C_clk_7     => Si5351C_clk_7,
      LMK_CLK           => LMK_CLK,
      ADF_MUXOUT        => ADF_MUXOUT,      
      FX3_clk_cnt       => to_tstcfg.FX3_CLK_CNT,
      Si5351C_clk_0_cnt => to_tstcfg.Si5351C_CLK0_CNT,
      Si5351C_clk_1_cnt => to_tstcfg.Si5351C_CLK1_CNT,
      Si5351C_clk_2_cnt => to_tstcfg.Si5351C_CLK2_CNT,
      Si5351C_clk_3_cnt => to_tstcfg.Si5351C_CLK3_CNT,
      Si5351C_clk_5_cnt => to_tstcfg.Si5351C_CLK5_CNT,
      Si5351C_clk_6_cnt => to_tstcfg.Si5351C_CLK6_CNT,
      Si5351C_clk_7_cnt => to_tstcfg.Si5351C_CLK7_CNT,
      LMK_CLK_cnt       => to_tstcfg.LMK_CLK_CNT,
      ADF_MUXOUT_cnt    => to_tstcfg.ADF_CNT
   );
   
-- ----------------------------------------------------------------------------
-- DDR2 external memory test instance
-- ----------------------------------------------------------------------------   
   ddr2_tester_inst2 : entity work.ddr2_tester
   port map(
		global_reset_n			=> from_tstcfg.test_en(5),
		pll_ref_clk				=> Si5351C_clk_1,
		soft_reset_n			=> from_tstcfg.test_en(5),
		begin_test				=> '0', -- unused
		insert_error			=> from_tstcfg.test_frc_err(5),
      --DDR2 external memory signals	
		mem_odt					=> mem_odt,
		mem_cs_n					=> mem_cs_n,
		mem_cke					=> mem_cke,
		mem_addr					=> mem_addr,
		mem_ba					=> mem_ba,
		mem_ras_n				=> mem_ras_n,
		mem_cas_n				=> mem_cas_n,
		mem_we_n					=> mem_we_n,
		mem_dm					=> mem_dm,
		mem_clk					=> mem_clk,
		mem_clk_n				=> mem_clk_n,
		mem_dq					=> mem_dq,
		mem_dqs					=> mem_dqs,	
		--test results
		pnf_per_bit         	=> open,
		pnf_per_bit_persist 	=> to_tstcfg.DDR2_2_pnf_per_bit,
      pass                	=> to_tstcfg.DDR2_2_STATUS(1),
		fail                	=> to_tstcfg.DDR2_2_STATUS(2),
		test_complete       	=> to_tstcfg.DDR2_2_STATUS(0)
   );
  
end arch;   


