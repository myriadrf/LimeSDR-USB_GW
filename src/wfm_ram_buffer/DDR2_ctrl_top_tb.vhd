-- ----------------------------------------------------------------------------	
-- FILE: 	file_name_tb.vhd
-- DESCRIPTION:	
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity DDR2_ctrl_top_tb is
end DDR2_ctrl_top_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of DDR2_ctrl_top_tb is
	constant clk0_period   	: time := 6.66 ns;
	constant clk1_period   	: time := 10 ns; 
  --signals
	signal clk0,clk1			: std_logic;
	signal reset_n 			: std_logic; 
	
	signal wcmd_clk				: std_logic;
	signal wcmd_rdy			: std_logic;
	signal wcmd_addr			: std_logic_vector(24 downto 0);
	signal wcmd_wr				: std_logic;
	signal wcmd_data			: std_logic_vector(31 downto 0);
	signal rcmd_clk			: std_logic;
	signal rcmd_rdy			: std_logic;
	signal rcmd_addr			: std_logic_vector(24 downto 0);
	signal rcmd_wr				: std_logic;
	signal wcmd_brst_en		: std_logic;
	signal rcmd_brst_en		: std_logic;

	signal local_ready			: std_logic;
	signal local_rdata			: std_logic_vector(31 downto 0);
	signal local_rdata_valid	: std_logic;
	signal local_init_done		: std_logic;

	signal wr_addr				: unsigned(24 downto 0);
	signal wr_data				: unsigned(31 downto 0);

	signal pct_wr				: std_logic;
	signal pct_wr_cnt			: unsigned(15 downto 0);


	signal pct_payload_valid 	: std_logic;
	signal pct_payload_data		: std_logic_vector(31 downto 0);

   signal data_fifo_rdreq		: std_logic;
	signal data_fifo_rdempty	: std_logic;
	signal data_fifo_rdusedw	: std_logic_vector(8 downto 0); 


 
begin 
  
   	clock0: process is
	begin
		clk0 <= '0'; wait for clk0_period/2;
		clk0 <= '1'; wait for clk0_period/2;
	end process clock0;

   	clock: process is
	begin
		clk1 <= '0'; wait for clk1_period/2;
		clk1 <= '1'; wait for clk1_period/2;
	end process clock;
	
		res: process is
	begin
		reset_n <= '0'; wait for 20 ns;
		reset_n <= '1'; wait;
	end process res;
	
  DDR2_ctrl_top_inst : entity work.DDR2_ctrl_top 
generic map (
    		cntrl_rate			=> 1, --1 - full rate, 2 - half rate
			cntrl_bus_size		=> 16,
			addr_size			=> 25,
			lcl_bus_size		=> 63,
			lcl_burst_length	=> 2,
			cmd_fifo_size		=> 9
)
port map(
      pll_ref_clk       => clk0,
      global_reset_n   	=> reset_n,
		soft_reset_n		=> reset_n,

		wcmd_clk				=> wcmd_clk,
		wcmd_rdy				=> wcmd_rdy,
		wcmd_addr			=> wcmd_addr,
		wcmd_wr				=> wcmd_wr,
		wcmd_brst_en		=> wcmd_brst_en, 
		wcmd_data			=> wcmd_data,
		rcmd_rdy				=> rcmd_rdy,
		rcmd_clk				=> rcmd_clk,
		rcmd_addr			=> rcmd_addr,
		rcmd_wr				=> rcmd_wr,
		rcmd_brst_en		=> rcmd_brst_en,

		local_ready			=> local_ready,
		local_rdata			=> local_rdata,
		local_rdata_valid	=> local_rdata_valid,
		local_init_done	=> local_init_done,

		mem_odt				=> open,
		mem_cs_n				=> open,
		mem_cke				=> open,
		mem_addr				=> open,
		mem_ba				=> open,
		mem_ras_n			=> open,
		mem_cas_n			=> open,
		mem_we_n				=> open,
		mem_dm				=> open,
		phy_clk				=> open,
		--aux_full_rate_clk	: out std_logic;
		--aux_half_rate_clk	: out std_logic;
		--reset_request_n	: out std_logic;
		mem_clk				=> open,
		mem_clk_n			=> open,
		mem_dq				=> open,
		mem_dqs				=> open
	
    );






process (reset_n, clk0) 
	begin 
		if reset_n='0' then 
			pct_wr_cnt<=(others=>'0');
		elsif (clk0'event and clk0='1') then 
			pct_wr_cnt<=pct_wr_cnt+1;
		end if;
end process;

pct_wr<='1' when pct_wr_cnt<8 else '0';

payload_extract_inst : entity work.pct_payload_extrct 
	generic map (data_w			=> 32,
					header_size		=> 16,  --pct header size in bytes 
					pct_size			=> 4096 --pct size in bytes
		)
  port map (
      --input ports 
		clk						=> clk0,
		reset_n					=> reset_n,
		pct_wr					=> pct_wr,
		pct_data					=> x"00000008",
		pct_payload_valid		=> pct_payload_valid,
		pct_payload_data		=> pct_payload_data,
		pct_payload_dest		=> open
        );


data_fifo	: entity work.fifo_inst 
generic map (
			dev_family			=> "Cyclone IV E",
			wrwidth				=> 32,
			wrusedw_witdth		=> 9, --9=256 words 
			rdwidth				=> 32,
			rdusedw_width		=> 9,
			show_ahead			=> "ON"
)
port map (
      reset_n       => reset_n, 
      wrclk         => clk0, 
      wrreq         => pct_payload_valid, 
      data          => pct_payload_data, 
      wrfull        => open, 
		wrempty		  => open, 
      wrusedw       => open, 
      rdclk 	     => clk0, 
      rdreq         => data_fifo_rdreq, 
      q             => open, 
      rdempty       => data_fifo_rdempty, 
      rdusedw       => data_fifo_rdusedw   
);

data_fifo_rdreq<= '1' when unsigned(data_fifo_rdusedw)>=2 else '0';


	end tb_behave;
  
  


  
