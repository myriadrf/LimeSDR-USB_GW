-- ----------------------------------------------------------------------------	
-- FILE: 	ddr2_tester.vhd
-- DESCRIPTION:	top module for testing ddr2 ram memory
-- DATE:	Aug 19, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity ddr2_tester is
  port (

		global_reset_n			: in std_logic;
		pll_ref_clk				: in std_logic;
		soft_reset_n			: in std_logic;
		begin_test				: in std_logic;
		insert_error			: in std_logic;

      --DDR2 external memory signals	
		mem_odt					: out std_logic_vector (0 DOWNTO 0);
		mem_cs_n					: out std_logic_vector (0 DOWNTO 0);
		mem_cke					: out std_logic_vector (0 DOWNTO 0);
		mem_addr					: out std_logic_vector (12 DOWNTO 0);
		mem_ba					: out std_logic_vector (2 DOWNTO 0);
		mem_ras_n				: out std_logic;
		mem_cas_n				: out std_logic;
		mem_we_n					: out std_logic;
		mem_dm					: out std_logic_vector (1 DOWNTO 0);
		mem_clk					: inout std_logic_vector (0 DOWNTO 0);
		mem_clk_n				: inout std_logic_vector (0 DOWNTO 0);
		mem_dq					: inout std_logic_vector (15 DOWNTO 0);
		mem_dqs					: inout std_logic_vector (1 DOWNTO 0);
		
		--test results
		pnf_per_bit         	: out std_logic_vector(31 downto 0);
		pnf_per_bit_persist 	: out std_logic_vector(31 downto 0);
		pass                	: out std_logic;
		fail                	: out std_logic; 
		test_complete       	: out std_logic 
	
		
        
        );
end ddr2_tester;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of ddr2_tester is
--declare signals,  components here
--avalon signals
signal avl_ready           : std_logic;
signal avl_addr            : std_logic_vector(24 downto 0);
signal avl_size            : std_logic_vector(1 downto 0);
signal avl_wdata           : std_logic_vector(31 downto 0);
signal avl_rdata, avl_rdata_error    : std_logic_vector(31 downto 0);
signal avl_write_req       : std_logic;
signal avl_read_req        : std_logic;
signal avl_rdata_valid     : std_logic;
signal avl_be              : std_logic_vector(3 downto 0);
signal avl_burstbegin      : std_logic;  

--phy interface
signal ddr2_phy_clk			: std_logic;
signal local_init_done		: std_logic;

signal begin_test_reg0, begin_test_reg1 : std_logic;


component ddr2 IS
	PORT (
		local_address		: IN STD_LOGIC_VECTOR (24 DOWNTO 0);
		local_write_req	: IN STD_LOGIC;
		local_read_req		: IN STD_LOGIC;
		local_burstbegin	: IN STD_LOGIC;
		local_wdata			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		local_be				: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		local_size			: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		global_reset_n		: IN STD_LOGIC;
		pll_ref_clk			: IN STD_LOGIC;
		soft_reset_n		: IN STD_LOGIC;
		local_ready			: OUT STD_LOGIC;
		local_rdata			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		local_rdata_valid	: OUT STD_LOGIC;
		local_refresh_ack	: OUT STD_LOGIC;
		local_init_done	: OUT STD_LOGIC;
		reset_phy_clk_n	: OUT STD_LOGIC;
		mem_odt				: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		mem_cs_n				: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		mem_cke				: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		mem_addr				: OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
		mem_ba				: OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		mem_ras_n			: OUT STD_LOGIC;
		mem_cas_n			: OUT STD_LOGIC;
		mem_we_n				: OUT STD_LOGIC;
		mem_dm				: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		phy_clk				: OUT STD_LOGIC;
		aux_full_rate_clk	: OUT STD_LOGIC;
		aux_half_rate_clk	: OUT STD_LOGIC;
		reset_request_n	: OUT STD_LOGIC;
		mem_clk				: INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		mem_clk_n			: INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		mem_dq				: INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		mem_dqs				: INOUT STD_LOGIC_VECTOR (1 DOWNTO 0)
	);
END component;


component ddr2_traffic_gen is
	port (
		avl_ready           : in  std_logic                     := '0';             --       avl.waitrequest_n
		avl_addr            : out std_logic_vector(24 downto 0);                    --          .address
		avl_size            : out std_logic_vector(1 downto 0);                     --          .burstcount
		avl_wdata           : out std_logic_vector(31 downto 0);                    --          .writedata
		avl_rdata           : in  std_logic_vector(31 downto 0) := (others => '0'); --          .readdata
		avl_write_req       : out std_logic;                                        --          .write
		avl_read_req        : out std_logic;                                        --          .read
		avl_rdata_valid     : in  std_logic                     := '0';             --          .readdatavalid
		avl_be              : out std_logic_vector(3 downto 0);                     --          .byteenable
		avl_burstbegin      : out std_logic;                                        --          .beginbursttransfer
		clk                 : in  std_logic                     := '0';             -- avl_clock.clk
		reset_n             : in  std_logic                     := '0';             -- avl_reset.reset_n
		pnf_per_bit         : out std_logic_vector(31 downto 0);                    --       pnf.pnf_per_bit
		pnf_per_bit_persist : out std_logic_vector(31 downto 0);                    --          .pnf_per_bit_persist
		pass                : out std_logic;                                        --    status.pass
		fail                : out std_logic;                                        --          .fail
		test_complete       : out std_logic                                         --          .test_complete
	);
end component;

  
begin

process(global_reset_n, pll_ref_clk)
begin
	if global_reset_n='0' then 
		begin_test_reg0<='0';
		begin_test_reg1<='0';
	elsif (pll_ref_clk'event and pll_ref_clk='1') then
		begin_test_reg0<=begin_test;
		begin_test_reg1<=begin_test_reg0;
	end if;
end process;

ddr2_inst : ddr2
	PORT map (
		local_address		=> avl_addr, 
		local_write_req	=> avl_write_req, 
		local_read_req		=> avl_read_req, 
		local_burstbegin	=> avl_burstbegin, 
		local_wdata			=> avl_wdata, 
		local_be				=> avl_be, 
		local_size			=> avl_size, 
		global_reset_n		=> global_reset_n, 
		pll_ref_clk			=> pll_ref_clk, 
		soft_reset_n		=> soft_reset_n, 
		local_ready			=> avl_ready, 
		local_rdata			=> avl_rdata, 
		local_rdata_valid	=> avl_rdata_valid, 
		local_refresh_ack	=> open, 
		local_init_done	=> local_init_done, 
		reset_phy_clk_n	=> open, 
		mem_odt				=> mem_odt, 
		mem_cs_n				=> mem_cs_n, 
		mem_cke				=> mem_cke, 
		mem_addr				=> mem_addr, 
		mem_ba				=> mem_ba, 
		mem_ras_n			=> mem_ras_n, 
		mem_cas_n			=> mem_cas_n, 
		mem_we_n				=> mem_we_n, 
		mem_dm				=> mem_dm, 
		phy_clk				=> ddr2_phy_clk, 
		aux_full_rate_clk	=> open, 
		aux_half_rate_clk	=> open, 
		reset_request_n	=> open, 
		mem_clk				=> mem_clk, 
		mem_clk_n			=> mem_clk_n, 
		mem_dq				=> mem_dq, 
		mem_dqs				=> mem_dqs 
	);	 
	
traffic_gen_inst : ddr2_traffic_gen
	port map (
		avl_ready				=> avl_ready,
		avl_addr					=> avl_addr,
		avl_size					=> avl_size,
		avl_wdata				=> avl_wdata,
		avl_rdata				=> avl_rdata_error,--avl_rdata,
		avl_write_req			=> avl_write_req,
		avl_read_req			=> avl_read_req,
		avl_rdata_valid		=> avl_rdata_valid,
		avl_be					=> avl_be,
		avl_burstbegin			=> avl_burstbegin,
		clk						=> ddr2_phy_clk,
		reset_n					=> local_init_done,
		pnf_per_bit				=> pnf_per_bit,
		pnf_per_bit_persist	=> pnf_per_bit_persist,
		pass						=> pass,
		fail						=> fail,
		test_complete			=> test_complete 
	);	
	
	avl_rdata_error<=avl_rdata(31 downto 1) & '0' when insert_error='1' else avl_rdata;
  
end arch;





