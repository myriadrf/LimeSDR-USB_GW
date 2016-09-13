-- ----------------------------------------------------------------------------	
-- FILE: 	clock_test.vhd
-- DESCRIPTION:	clock test module
-- DATE:	Sep 5, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity clock_test is
  port (
        --input ports 
        FX3_clk       		: in std_logic;
        reset_n   	 		: in std_logic;
		  test_en				: in std_logic_vector(3 downto 0);
		  test_frc_err			: in std_logic_vector(3 downto 0);
		  test_cmplt			: out std_logic_vector(3 downto 0);
		  test_rez				: out std_logic_vector(3 downto 0);
		  
		  Si5351C_clk_0 		: in std_logic;
		  Si5351C_clk_1 		: in std_logic;
		  Si5351C_clk_2 		: in std_logic;
		  Si5351C_clk_3 		: in std_logic;
		  Si5351C_clk_5 		: in std_logic;
		  Si5351C_clk_6 		: in std_logic;
		  Si5351C_clk_7 		: in std_logic;
		  LMK_CLK		 		: in std_logic;
		  ADF_MUXOUT	 		: in std_logic;
		  
		  FX3_clk_cnt   		: out std_logic_vector(15 downto 0);
		  Si5351C_clk_0_cnt 	: out std_logic_vector(15 downto 0);
		  Si5351C_clk_1_cnt 	: out std_logic_vector(15 downto 0);
		  Si5351C_clk_2_cnt 	: out std_logic_vector(15 downto 0);
		  Si5351C_clk_3_cnt 	: out std_logic_vector(15 downto 0);
		  Si5351C_clk_5_cnt 	: out std_logic_vector(15 downto 0);
		  Si5351C_clk_6_cnt 	: out std_logic_vector(15 downto 0);
		  Si5351C_clk_7_cnt 	: out std_logic_vector(15 downto 0);
		  LMK_CLK_cnt		 	: out std_logic_vector(23 downto 0);
		  ADF_MUXOUT_cnt	 	: out std_logic_vector(15 downto 0)
		  
		  

        --output ports 
        
        );
end clock_test;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of clock_test is
--declare signals,  components here

component clk_no_ref_test is
  port (
        --input ports 
        clk       		: in std_logic;
        reset_n   		: in std_logic;
		  test_en			: in std_logic;
		  test_cnt			: out std_logic_vector(15 downto 0);
		  test_complete	: out std_logic;
		  test_pass_fail	: out std_logic    
        );
end component;

component clk_with_ref_test is
  port (
        --input ports 
        refclk       	: in std_logic;
        reset_n   		: in std_logic;
		  clk0				: in std_logic;
		  clk1				: in std_logic;
		  clk2				: in std_logic;
		  clk3				: in std_logic;
		  clk4				: in std_logic;
		  clk5				: in std_logic;
		  clk6				: in std_logic;		  
		  test_en			: in std_logic;
		  test_cnt0			: out std_logic_vector(15 downto 0);
		  test_cnt1			: out std_logic_vector(15 downto 0);
		  test_cnt2			: out std_logic_vector(15 downto 0);
		  test_cnt3			: out std_logic_vector(15 downto 0);
		  test_cnt4			: out std_logic_vector(15 downto 0);
		  test_cnt5			: out std_logic_vector(15 downto 0);
		  test_cnt6			: out std_logic_vector(15 downto 0);
		  test_complete	: out std_logic;
		  test_pass_fail	: out std_logic
     
        );
end component;

component singl_clk_with_ref_test is
  port (
        --input ports 
        refclk       	: in std_logic;
        reset_n   		: in std_logic;
		  clk0				: in std_logic;
		  
		  test_en			: in std_logic;
		  test_cnt0			: out std_logic_vector(23 downto 0);
		  test_complete	: out std_logic;
		  test_pass_fail	: out std_logic
     
        );
end component;

component transition_count is
  port (
        --input ports 
			clk				: in std_logic;
			reset_n   		: in std_logic;
			trans_wire		: in std_logic;
		  
			test_en			: in std_logic;
			test_cnt			: out std_logic_vector(15 downto 0);
			test_complete	: out std_logic;
			test_pass_fail	: out std_logic
     
        );
end component;


begin

FX3_clk_test : clk_no_ref_test
  port map(
        clk       		=> FX3_clk,
        reset_n   		=> reset_n,
		  test_en			=> test_en(0),
		  test_cnt			=> FX3_clk_cnt,
		  test_complete	=> test_cmplt(0),
		  test_pass_fail	=> test_rez(0)   
        );
		  
		  
Si5351C_test : clk_with_ref_test
  port map (
        --input ports 
        refclk       	=> FX3_clk,
        reset_n   		=> reset_n,
		  clk0				=> Si5351C_clk_0,
		  clk1				=> Si5351C_clk_1,
		  clk2				=> Si5351C_clk_2,
		  clk3				=> Si5351C_clk_3,
		  clk4				=> Si5351C_clk_5,
		  clk5				=> Si5351C_clk_6,
		  clk6				=> Si5351C_clk_7,		  
		  test_en			=> test_en(1),
		  test_cnt0			=> Si5351C_clk_0_cnt,
		  test_cnt1			=> Si5351C_clk_1_cnt,
		  test_cnt2			=> Si5351C_clk_2_cnt,
		  test_cnt3			=> Si5351C_clk_3_cnt,
		  test_cnt4			=> Si5351C_clk_5_cnt,
		  test_cnt5			=> Si5351C_clk_6_cnt,
		  test_cnt6			=> Si5351C_clk_7_cnt,
		  test_complete	=> test_cmplt(1),
		  test_pass_fail	=> test_rez(1)
     
        );		  

		  
LML_CLK_test : singl_clk_with_ref_test
  port map (
        --input ports 
        refclk       	=> FX3_clk,
        reset_n   		=> reset_n,
		  clk0				=> LMK_CLK,		  
		  test_en			=> test_en(2),
		  test_cnt0			=> LMK_CLK_cnt,
		  test_complete	=> test_cmplt(2),
		  test_pass_fail	=> test_rez(2)   
        );
	
ADF_muxout_test : transition_count
  port map (
        --input ports 
			clk				=> FX3_clk,
			reset_n   		=> reset_n,
			trans_wire		=> ADF_MUXOUT,
		  
			test_en			=> test_en(3),
			test_cnt			=> ADF_MUXOUT_cnt,
			test_complete	=> test_cmplt(3),
			test_pass_fail	=> open
     
        );	
		  
test_rez(3)<=ADF_MUXOUT;

end arch;





