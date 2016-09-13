-- ----------------------------------------------------------------------------	
-- FILE: 	DDR2_ctrl_top.vhd
-- DESCRIPTION:	describe
-- DATE:	June 13, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity DDR2_ctrl_top is
		generic(
			cntrl_rate			: integer := 1; --1 - full rate, 2 - half rate
			cntrl_bus_size		: integer := 16;
			addr_size			: integer := 24;
			lcl_bus_size		: integer := 63;
			lcl_burst_length	: integer := 2;
			cmd_fifo_size		: integer := 9;
			outfifo_size		: integer := 10  --DDR2 outfifo buffer size
		);
		port (

      pll_ref_clk       : in std_logic;
      global_reset_n   	: in std_logic;
		soft_reset_n		: in std_logic;

		wcmd_clk				: in std_logic;
		wcmd_reset_n		: in  std_logic;
		wcmd_rdy				: out std_logic;
		wcmd_addr			: in std_logic_vector(addr_size-1 downto 0);
		wcmd_wr				: in std_logic;
		wcmd_brst_en		: in std_logic; --1- writes in burst, 0- single write
		wcmd_data			: in std_logic_vector(cntrl_bus_size*2*cntrl_rate-1 downto 0);
		rcmd_clk				: in std_logic;
		rcmd_reset_n		: in  std_logic;
		rcmd_rdy				: out std_logic;
		rcmd_addr			: in std_logic_vector(addr_size-1 downto 0);
		rcmd_wr				: in std_logic;
		rcmd_brst_en		: in std_logic; --1- reads in burst, 0- single read
		outbuf_wrusedw		: in std_logic_vector(outfifo_size-1 downto 0);

		local_ready			: out std_logic;
		local_rdata			: out std_logic_vector(cntrl_bus_size*2*cntrl_rate-1 downto 0);
		local_rdata_valid	: out std_logic;
		local_init_done	: out std_logic;

		mem_odt				: out std_logic_vector (0 DOWNTO 0);
		mem_cs_n				: out std_logic_vector (0 DOWNTO 0);
		mem_cke				: out std_logic_vector (0 DOWNTO 0);
		mem_addr				: out std_logic_vector (12 DOWNTO 0);
		mem_ba				: out std_logic_vector (2 DOWNTO 0);
		mem_ras_n			: out std_logic;
		mem_cas_n			: out std_logic;
		mem_we_n				: out std_logic;
		mem_dm				: out std_logic_vector (1 DOWNTO 0);
		phy_clk				: out std_logic;
		--aux_full_rate_clk	: out std_logic;
		--aux_half_rate_clk	: out std_logic;
		--reset_request_n	: out std_logic;
		mem_clk				: inout std_logic_vector (0 DOWNTO 0);
		mem_clk_n			: inout std_logic_vector (0 DOWNTO 0);
		mem_dq				: inout std_logic_vector (15 DOWNTO 0);
		mem_dqs				: inout std_logic_vector (1 DOWNTO 0);
		begin_test				: in std_logic;
		insert_error			: in std_logic;
		pnf_per_bit         : out std_logic_vector(31 downto 0);   
		pnf_per_bit_persist 	: out std_logic_vector(31 downto 0);
		pass                	: out std_logic;
		fail                	: out std_logic; 
		test_complete       	: out std_logic

      --output ports 
        
        );
end DDR2_ctrl_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of DDR2_ctrl_top  is
--declare signals,  components here
signal lcl_init_done	: std_logic;

--write command fifo signals
signal wcmdfifo_wrfull				: std_logic;
signal wcmdfifo_wrusedw				: std_logic_vector(cmd_fifo_size-1 downto 0);
signal wcmdfifo_rdreq 				: std_logic;
signal wcmdfifo_q						: std_logic_vector((addr_size+1)+cntrl_bus_size*2*cntrl_rate-1 downto 0); 
signal wcmdfifo_rdusedw				: std_logic_vector(cmd_fifo_size-1 downto 0);
signal wcmdfifo_data					: std_logic_vector((addr_size+1)+cntrl_bus_size*2*cntrl_rate-1 downto 0);
signal wcmdfifo_rdempty				: std_logic;
--read command fifo signals
signal rcmdfifo_wrfull				: std_logic;
signal rcmdfifo_rdreq				: std_logic; 
signal rcmdfifo_q						: std_logic_vector(addr_size downto 0);
signal rcmdfifo_rdusedw 			: std_logic_vector(cmd_fifo_size-1 downto 0);
signal rcmdfifo_rdempty				: std_logic;
signal rcmdfifo_data 				: std_logic_vector(addr_size downto 0);  

signal ddr2_phy_clk 					: std_logic;
signal ddr2_local_init_done		: std_logic;
signal ddr2_local_ready				: std_logic;

signal read_cnt						: unsigned(7 downto 0);

--ddr2 arbiter signals
signal ddr2arb_local_addr			: std_logic_vector(addr_size-1 downto 0);
signal ddr2arb_local_write_req	: std_logic;
signal ddr2arb_local_read_req		: std_logic;
signal ddr2arb_local_burstbegin	: std_logic;
signal ddr2arb_local_wdata			: std_logic_vector(cntrl_bus_size*2*cntrl_rate-1 downto 0);
signal ddr2arb_local_be				: std_logic_vector(4*cntrl_rate-1 downto 0);
signal ddr2arb_local_size			: std_logic_vector(1 downto 0);	

--avalon MM bus signals
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

signal tst_ready           : std_logic;
signal tst_addr            : std_logic_vector(24 downto 0);
signal tst_size            : std_logic_vector(1 downto 0);
signal tst_wdata           : std_logic_vector(31 downto 0);
signal tst_rdata, tst_rdata_error    : std_logic_vector(31 downto 0);
signal tst_write_req       : std_logic;
signal tst_read_req        : std_logic;
signal tst_rdata_valid     : std_logic;
signal tst_be              : std_logic_vector(3 downto 0);
signal tst_burstbegin      : std_logic;   

component fifo_inst is
  generic(dev_family	     : string  := "Cyclone IV E";
          wrwidth         : integer := 24;
          wrusedw_witdth  : integer := 12; --12=2048 words 
          rdwidth         : integer := 48;
          rdusedw_width   : integer := 11;
          show_ahead      : string  := "ON"
  );  
  port (
      --input ports 
      reset_n       : in std_logic;
      wrclk         : in std_logic;
      wrreq         : in std_logic;
      data          : in std_logic_vector(wrwidth-1 downto 0);
      wrfull        : out std_logic;
		wrempty		  : out std_logic;
      wrusedw       : out std_logic_vector(wrusedw_witdth-1 downto 0);
      rdclk 	     : in std_logic;
      rdreq         : in std_logic;
      q             : out std_logic_vector(rdwidth-1 downto 0);
      rdempty       : out std_logic;
      rdusedw       : out std_logic_vector(rdusedw_width-1 downto 0)     
        );
end component; 


component DDR2_arb is
	generic(
		cntrl_rate			: integer := 1; --1 - full rate, 2 - half rate
		cntrl_bus_size		: integer := 16;
		addr_size			: integer := 24;
		lcl_bus_size		: integer := 63;
		lcl_burst_length	: integer := 2;
		cmd_fifo_size		: integer := 9;
		outfifo_size		: integer :=10
		);
  port (
      clk       			: in std_logic;
      reset_n   			: in std_logic;

		wcmd_fifo_wraddr	: in std_logic_vector(addr_size downto 0);
		wcmd_fifo_wrdata	: in std_logic_vector(cntrl_bus_size*2*cntrl_rate-1 downto 0);
		wcmd_fifo_rdusedw	: in std_logic_vector(cmd_fifo_size-1 downto 0);
		wcmd_fifo_rdempty	: in std_logic;
		wcmd_fifo_rdreq	: out std_logic;
		rcmd_fifo_rdaddr	: in std_logic_vector(addr_size downto 0);
		rcmd_fifo_rdusedw	: in std_logic_vector(cmd_fifo_size-1 downto 0);
		rcmd_fifo_rdempty	: in std_logic;
		rcmd_fifo_rdreq	: out std_logic;
		outbuf_wrusedw		: in std_logic_vector(outfifo_size-1 downto 0);
		
		local_ready			: in std_logic;
		local_addr			: out std_logic_vector(addr_size-1 downto 0);
		local_write_req	: out std_logic;
		local_read_req		: out std_logic;
		local_burstbegin	: out std_logic;
		local_wdata			: out std_logic_vector(cntrl_bus_size*2*cntrl_rate-1 downto 0);
		local_be				: out std_logic_vector(4*cntrl_rate-1 downto 0);
		local_size			: out std_logic_vector(1 downto 0)	
        );
end component;



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


wcmdfifo_data<=(wcmd_brst_en & wcmd_addr & wcmd_data);
-- ---------------------------------------------------------------------------
-- Command fifo instances
-- ---------------------------------------------------------------------------
--writecommand fifo
wcmdfifo	: fifo_inst 
generic map (
			dev_family			=> "Cyclone IV E",
			wrwidth				=> (addr_size+1)+cntrl_bus_size*2*cntrl_rate,
			wrusedw_witdth		=> cmd_fifo_size, --9=256 words 
			rdwidth				=> (addr_size+1)+cntrl_bus_size*2*cntrl_rate,
			rdusedw_width		=> cmd_fifo_size,
			show_ahead			=> "ON"
)
port map (
      reset_n       => wcmd_reset_n, 
      wrclk         => wcmd_clk, 
      wrreq         => wcmd_wr, 
      data          => wcmdfifo_data, 
      wrfull        => wcmdfifo_wrfull, 
		wrempty		  => open, 
      wrusedw       => wcmdfifo_wrusedw, 
      rdclk 	     => ddr2_phy_clk, 
      rdreq         => wcmdfifo_rdreq, 
      q             => wcmdfifo_q, 
      rdempty       => wcmdfifo_rdempty, 
      rdusedw       => wcmdfifo_rdusedw   
);

--read command fifo
rcmdfifo	: fifo_inst 
generic map (
			dev_family			=> "Cyclone IV E",
			wrwidth				=> (addr_size+1),
			wrusedw_witdth		=> cmd_fifo_size, --9=256 words 
			rdwidth				=> (addr_size+1),
			rdusedw_width		=> cmd_fifo_size,
			show_ahead			=> "ON"
)
port map (
      reset_n       => rcmd_reset_n, 
      wrclk         => rcmd_clk, 
      wrreq         => rcmd_wr, 
      data          => rcmdfifo_data, 
      wrfull        => rcmdfifo_wrfull, 
		wrempty		  => open, 
      wrusedw       => open, 
      rdclk 	     => ddr2_phy_clk, 
      rdreq         => rcmdfifo_rdreq, 
      q             => rcmdfifo_q, 
      rdempty       => rcmdfifo_rdempty, 
      rdusedw       => rcmdfifo_rdusedw   
);

--wcmd_rdy		<= not wcmdfifo_wrfull;

wcmd_rdy		<= '1' when unsigned(wcmdfifo_wrusedw)<252 else '0';

rcmd_rdy		<= not rcmdfifo_wrfull;
rcmdfifo_data	<= rcmd_brst_en & rcmd_addr;

-- ---------------------------------------------------------------------------
-- DDR2 arbitrator instance
-- ---------------------------------------------------------------------------
DDR2_arb_inst :  DDR2_arb
	generic map(
		cntrl_rate			=> cntrl_rate, --1 - full rate, 2 - half rate
		cntrl_bus_size		=> cntrl_bus_size,
		addr_size			=> addr_size,
		lcl_bus_size		=> lcl_bus_size,
		lcl_burst_length	=> lcl_burst_length,
		cmd_fifo_size		=> cmd_fifo_size,
		outfifo_size		=> outfifo_size
		)
  port map (
      clk       			=> ddr2_phy_clk,
      reset_n   			=> ddr2_local_init_done,

		wcmd_fifo_wraddr	=> wcmdfifo_q((addr_size+1)+cntrl_bus_size*2*cntrl_rate-1 downto cntrl_bus_size*2*cntrl_rate),
		wcmd_fifo_wrdata	=> wcmdfifo_q(cntrl_bus_size*2*cntrl_rate-1 downto 0),
		wcmd_fifo_rdusedw	=> wcmdfifo_rdusedw,
		wcmd_fifo_rdempty	=> wcmdfifo_rdempty,
		wcmd_fifo_rdreq	=> wcmdfifo_rdreq,
		rcmd_fifo_rdaddr	=> rcmdfifo_q ,
		rcmd_fifo_rdusedw	=> rcmdfifo_rdusedw,
		rcmd_fifo_rdempty	=> rcmdfifo_rdempty,
		rcmd_fifo_rdreq	=> rcmdfifo_rdreq,
		outbuf_wrusedw		=> outbuf_wrusedw, 

		local_ready			=> ddr2_local_ready,
		local_addr			=> ddr2arb_local_addr,
		local_write_req	=> ddr2arb_local_write_req,
		local_read_req		=> ddr2arb_local_read_req,
		local_burstbegin	=> ddr2arb_local_burstbegin,
		local_wdata			=> ddr2arb_local_wdata,
		local_be				=> ddr2arb_local_be,
		local_size			=> ddr2arb_local_size	
        );

-- ---------------------------------------------------------------------------
-- DDR2 controller instance
-- ---------------------------------------------------------------------------
--ddr2_local_ready<=not std_logic(read_cnt(2));
--ddr2_local_init_done<=global_reset_n;
--ddr2_phy_clk<=pll_ref_clk;
--
--process(global_reset_n, ddr2_phy_clk)
--    begin
--      if global_reset_n='0' then
--        read_cnt<=(others=>'0'); 
-- 	    elsif (ddr2_phy_clk'event and ddr2_phy_clk = '1') then
-- 	     		read_cnt<=read_cnt+1;
-- 	    end if;
--    end process;


traffic_gen_inst : ddr2_traffic_gen
	port map (
		avl_ready				=> ddr2_local_ready,
		avl_addr					=> tst_addr,
		avl_size					=> tst_size,
		avl_wdata				=> tst_wdata,
		avl_rdata				=> tst_rdata,
		avl_write_req			=> tst_write_req,
		avl_read_req			=> tst_read_req,
		avl_rdata_valid		=> tst_rdata_valid,
		avl_be					=> tst_be,
		avl_burstbegin			=> tst_burstbegin,
		clk						=> ddr2_phy_clk,
		reset_n					=> begin_test, --ddr2_local_init_done,
		pnf_per_bit				=> pnf_per_bit,
		pnf_per_bit_persist	=> pnf_per_bit_persist,
		pass						=> pass,
		fail						=> fail,
		test_complete			=> test_complete 
	);	

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
		local_ready			=> ddr2_local_ready, 
		local_rdata			=> avl_rdata, 
		local_rdata_valid	=> avl_rdata_valid, 
		local_refresh_ack	=> open, 
		local_init_done	=> ddr2_local_init_done, 
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

avl_addr 		<= tst_addr 		when begin_test='1' else ddr2arb_local_addr;
avl_write_req	<=	tst_write_req 	when begin_test='1' else ddr2arb_local_write_req;
avl_read_req	<=	tst_read_req 	when begin_test='1' else ddr2arb_local_read_req;
avl_burstbegin <= tst_burstbegin when begin_test='1' else ddr2arb_local_burstbegin;
avl_wdata		<= tst_wdata 		when begin_test='1' else ddr2arb_local_wdata;
avl_be			<= tst_be 			when begin_test='1' else ddr2arb_local_be;
avl_size			<= tst_size 		when begin_test='1' else ddr2arb_local_size;

local_rdata				<= avl_rdata;
local_rdata_valid 	<= avl_rdata_valid;

tst_rdata			<= avl_rdata(31 downto 1) & '0' when insert_error='1' else avl_rdata;
tst_rdata_valid 	<= avl_rdata_valid when begin_test='1' else '0';


phy_clk<=ddr2_phy_clk;
local_init_done<=ddr2_local_init_done;




  
end arch;   




