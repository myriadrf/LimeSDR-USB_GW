-- ----------------------------------------------------------------------------	
-- FILE: 	wfm_player_top.vhd
-- DESCRIPTION:	describe
-- DATE:	June 20, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity wfm_player_top is
	generic(
			dev_family			: string  := "Cyclone IV E"; 
			--DDR2 controller parameters
			cntrl_rate			: integer := 1; --1 - full rate, 2 - half rate
			cntrl_bus_size		: integer := 16;
			addr_size			: integer := 24;
			lcl_bus_size		: integer := 63;
			lcl_burst_length	: integer := 2;
			cmd_fifo_size		: integer := 9;
			--WFM player parameters
			wfm_infifo_size	: integer := 11;
			wfm_outfifo_size	: integer := 11;
			data_width			: integer := 32;
			iq_width				: integer := 12;
			dcmpr_fifo_size	: integer := 10
);
  port (
      --input ports
		reset_n					: in std_logic;
		ddr2_pll_ref_clk		: in std_logic;
	 
		wcmd_clk					: in std_logic;
		
		rcmd_clk					: in std_logic;
		
		wfm_load					: in std_logic;
		wfm_play_stop			: in std_logic; -- 1- play, 0- stop

		wfm_data					: in std_logic_vector(data_width-1 downto 0);
		wfm_wr					: in std_logic;
		wfm_rdy					: out std_logic;
		wfm_infifo_wrusedw 	: out std_logic_vector(wfm_infifo_size-1 downto 0);
		
		sample_width    		: in std_logic_vector(1 downto 0); -- "00"-16bit, "01"-14bit, "10"-12bit
		fr_start					: in std_logic;
		ch_en						: in std_logic_vector(1 downto 0);
      mimo_en					: in std_logic;

		iq_clk					: in std_logic;
		dd_iq_h					: out std_logic_vector(15 downto 0);
		dd_iq_l					: out std_logic_vector(15 downto 0);
--		dd_iq_h_uns				: out std_logic_vector(15 downto 0);
--		dd_iq_l_uns				: out std_logic_vector(15 downto 0);

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
		phy_clk					: out std_logic;
		mem_clk					: inout std_logic_vector (0 DOWNTO 0);
		mem_clk_n				: inout std_logic_vector (0 DOWNTO 0);
		mem_dq					: inout std_logic_vector (15 DOWNTO 0);
		mem_dqs					: inout std_logic_vector (1 DOWNTO 0);
		begin_test				: in std_logic;
		insert_error			: in std_logic;
		pnf_per_bit			 	: out std_logic_vector(31 downto 0);
		pnf_per_bit_persist 	: out std_logic_vector(31 downto 0);
		pass                	: out std_logic;
		fail                	: out std_logic; 
		test_complete       	: out std_logic
		
        
        );
end wfm_player_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of wfm_player_top is
--declare signals,  components here


--reset signals
signal ddr2_reset_n 					: std_logic;
signal wcmd_reset_n					: std_logic;
signal rcmd_reset_n					: std_logic;

--ddr2 controller signals
signal ddr2_phy_clk : std_logic;

--wfm player signals
signal wfm_player_wcmd_rdy			: std_logic;
signal wfm_player_wcmd_addr		: std_logic_vector(addr_size-1 downto 0);
signal wfm_player_wcmd_wr			: std_logic;
signal wfm_player_wcmd_brst_en	: std_logic;	
signal wfm_player_wcmd_data		: std_logic_vector(cntrl_bus_size*2*cntrl_rate-1 downto 0);
signal wfm_player_rcmd_addr		: std_logic_vector(addr_size-1 downto 0);
signal wfm_player_rcmd_wr			: std_logic;
signal wfm_player_rcmd_brst_en	: std_logic;
signal wfm_player_wcmd_reset_n	: std_logic;
signal wfm_player_rcmd_reset_n	: std_logic;

--DDR2 controller signals
signal DDR2_ctrl_wcmd_rdy				: std_logic;
signal DDR2_ctrl_rcmd_rdy				: std_logic;
signal DDR2_ctrl_phy_clk				: std_logic;
signal DDR2_ctrl_local_ready			: std_logic;
signal DDR2_ctrl_local_rdata			: std_logic_vector(cntrl_bus_size*2*cntrl_rate-1 downto 0);
signal DDR2_ctrl_local_rdata_valid	: std_logic;
signal DDR2_ctrl_local_init_done		: std_logic;
signal DDR2_ctrl_init_done_wcmd0 	: std_logic;
signal DDR2_ctrl_init_done_wcmd1 	: std_logic;
signal DDR2_ctrl_init_done_rcmd0 	: std_logic;
signal DDR2_ctrl_init_done_rcmd1 	: std_logic;

--wfm outfifo signals
signal wfm_out_fifo_rdreq				: std_logic;

signal wfm_out_fifo_rdempty			: std_logic; 

signal dcmpr_rdempty						: std_logic;
signal dcmpr_q								: std_logic_vector(data_width-1 downto 0);
signal dcmpr_wusedw						: std_logic_vector(dcmpr_fifo_size-1 downto 0); 

signal rdfifo_read						: std_logic;

signal wfm_load_i							: std_logic;

signal dd_iq_l_int						: std_logic_vector(15 downto 0);
signal dd_iq_h_int						: std_logic_vector(15 downto 0);

signal wfm_load_reg_pll_refclk		: std_logic_vector(2 downto 0);


component wfm_player is
	generic(
			dev_family			: string  := "Cyclone IV E"; 
			wfm_infifo_size	: integer := 11;
			wfm_outfifo_size	: integer := 11;
			data_width			: integer := 32;
			iq_width				: integer := 12;
			addr_size			: integer := 24;
			cntrl_bus_size		: integer := 16;
			lcl_burst_length	: integer := 2;
			cntrl_rate			: integer := 1 --1 - full rate, 2 - half rate
);
  port (
		ddr2_phy_clk			: in std_logic;
		ddr2_phy_reset_n		: in std_logic;

		wfm_load					: in std_logic;
		wfm_play_stop			: in std_logic; -- 1- play, 0- stop

		wfm_data					: in std_logic_vector(data_width-1 downto 0);
		wfm_wr					: in std_logic;
		wfm_infifo_wrusedw 	: out std_logic_vector(wfm_infifo_size-1 downto 0);

		wcmd_clk					: in std_logic;
		wcmd_reset_n			: in  std_logic;
		wcmd_rdy					: in std_logic;
		wcmd_addr				: out std_logic_vector(addr_size-1 downto 0);
		wcmd_wr					: out std_logic;
		wcmd_brst_en			: out std_logic; --1- writes in burst, 0- single write
		wcmd_data				: out std_logic_vector(cntrl_bus_size*2*cntrl_rate-1 downto 0);
		rcmd_clk					: in std_logic;
		rcmd_reset_n			: in std_logic;
		rcmd_rdy					: in std_logic;
		rcmd_addr				: out std_logic_vector(addr_size-1 downto 0);
		rcmd_wr					: out std_logic;
		rcmd_brst_en			: out std_logic --1- reads in burst, 0- single read
		
        );
end component;


component DDR2_ctrl_top is
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
		pnf_per_bit				: out std_logic_vector(31 downto 0);
		pnf_per_bit_persist 	: out std_logic_vector(31 downto 0);
		pass                	: out std_logic;
		fail                	: out std_logic; 
		test_complete       	: out std_logic

      --output ports 
        
        );
end component;


component  fifo_inst is
  generic(
		dev_family	    	: string  := "Cyclone IV E";
		wrwidth         	: integer := 24;
		wrusedw_witdth  	: integer := 12; --12=2048 words 
		rdwidth         	: integer := 48;
		rdusedw_width   	: integer := 11;
		show_ahead      	: string  := "ON"
  );  
  port (
      --input ports 
      reset_n       		: in std_logic;
      wrclk         		: in std_logic;
      wrreq         		: in std_logic;
      data          		: in std_logic_vector(wrwidth-1 downto 0);
      wrfull        		: out std_logic;
		wrempty		  		: out std_logic;
      wrusedw       		: out std_logic_vector(wrusedw_witdth-1 downto 0);
      rdclk 	     		: in std_logic;
      rdreq         		: in std_logic;
      q             		: out std_logic_vector(rdwidth-1 downto 0);
      rdempty       		: out std_logic;
      rdusedw       		: out std_logic_vector(rdusedw_width-1 downto 0)     
        );
end component;

component decompress is
  generic (
			dev_family 		: string  := "Cyclone IV E";
			data_width 		: integer := 31;
			fifo_rsize		: integer := 9 ;
			fifo_wsize		: integer := 10
			);
  port (
        --input ports 
			wclk          : in std_logic;
			rclk          : in std_logic;
			reset_n       : in std_logic;
			data_in       : in std_logic_vector(data_width-1 downto 0);
			data_in_valid : in std_logic; -- data_in leading signal which indicates valid incomong data
			sample_width  : in std_logic_vector(1 downto 0); -- "00"-16bit, "01"-14bit, "10"-12bit
			rdreq         : in std_logic;
			rdempty       : out std_logic;
			rdusedw       : out std_logic_vector(fifo_rsize-1 downto 0);
			wfull         : out std_logic;
			wusedw        : out std_logic_vector(fifo_wsize-1 downto 0);
			dataout_valid : out std_logic;
			decmpr_data   : out std_logic_vector(31 downto 0)    
        );
end component;


component rd_tx_fifo is
  generic(sampl_width : integer:=12);
  port (
        --input ports 
      clk			: in std_logic;
      reset_n		: in std_logic;
      fr_start  	: in std_logic;
      ch_en			: in std_logic_vector(1 downto 0);
      mimo_en		: in std_logic;
      fifo_empty	: in std_logic;
      fifo_data	: in std_logic_vector(31 downto 0);
		--output ports 
      fifo_read	: out std_logic;
      diq_h			: out std_logic_vector(15 downto 0);
      diq_l			: out std_logic_vector(15 downto 0)
        );
end component;

  
begin

wfm_load_i<=not wfm_load;



-- ----------------------------------------------------------------------------
-- To synchronize DDR2_ctrl_local_init_done signal to wcmd_clk
-- ----------------------------------------------------------------------------
process (reset_n, wcmd_clk) is 
begin 
	if reset_n='0' then 
		DDR2_ctrl_init_done_wcmd0<='0';
		DDR2_ctrl_init_done_wcmd1<='0';
		wfm_player_wcmd_reset_n<='0';
	elsif (wcmd_clk'event and wcmd_clk='1') then 
		DDR2_ctrl_init_done_wcmd0<=DDR2_ctrl_local_init_done;
		DDR2_ctrl_init_done_wcmd1<=DDR2_ctrl_init_done_wcmd0;
		
		if DDR2_ctrl_init_done_wcmd1='1' then 
			wfm_player_wcmd_reset_n<='1';
		else 
			wfm_player_wcmd_reset_n<='0';
		end if;
	end if; 		
end process;

-- ----------------------------------------------------------------------------
-- To synchronize DDR2_ctrl_local_init_done signal to rcmd_clk
-- ----------------------------------------------------------------------------
process (reset_n, rcmd_clk) is 
begin 
	if reset_n='0' then 
		DDR2_ctrl_init_done_rcmd0<='0';
		DDR2_ctrl_init_done_rcmd1<='0';
		wfm_player_rcmd_reset_n<='0';
	elsif (rcmd_clk'event and rcmd_clk='1') then 
		DDR2_ctrl_init_done_rcmd0<=DDR2_ctrl_local_init_done;
		DDR2_ctrl_init_done_rcmd1<=DDR2_ctrl_init_done_rcmd0;
		
		if DDR2_ctrl_init_done_rcmd1='1' then 
			wfm_player_rcmd_reset_n<='1';
		else 
			wfm_player_rcmd_reset_n<='0';
		end if;
	end if; 		
end process;

-- ----------------------------------------------------------------------------
-- DDR2 reset 
-- ----------------------------------------------------------------------------
process (reset_n, ddr2_pll_ref_clk) is 
begin 
	if reset_n='0' then 
		ddr2_reset_n<='1';
		wfm_load_reg_pll_refclk<=(others=>'0');
	elsif (ddr2_pll_ref_clk'event and ddr2_pll_ref_clk='1') then 
		wfm_load_reg_pll_refclk<=wfm_load_reg_pll_refclk(1 downto 0) & wfm_load;
		
		if wfm_load_reg_pll_refclk(1)='1' and wfm_load_reg_pll_refclk(2)='0' then
			ddr2_reset_n<='0';
		else 
			ddr2_reset_n<='1';
		end if;
		
	end if; 		
end process;





-- ----------------------------------------------------------------------------
-- WFM player inst
-- ----------------------------------------------------------------------------
wfm_player_inst : wfm_player
	generic map (
			dev_family			=> dev_family, 
			wfm_infifo_size	=> wfm_infifo_size,
			wfm_outfifo_size	=> wfm_outfifo_size,
			data_width			=> data_width, 
			iq_width				=> iq_width, 
			addr_size			=> addr_size, 
			cntrl_bus_size		=> cntrl_bus_size,
			lcl_burst_length	=> lcl_burst_length,
			cntrl_rate			=> cntrl_rate 
)
  port map(


		ddr2_phy_clk			=> DDR2_ctrl_phy_clk,
		ddr2_phy_reset_n		=> DDR2_ctrl_local_init_done,

		wfm_load					=> wfm_load,
		wfm_play_stop			=> wfm_play_stop,

		wfm_data					=> wfm_data,
		wfm_wr					=> wfm_wr,
		wfm_infifo_wrusedw 	=> wfm_infifo_wrusedw,

		wcmd_clk					=> wcmd_clk,
		wcmd_reset_n			=> wfm_player_wcmd_reset_n,
		wcmd_rdy					=> DDR2_ctrl_wcmd_rdy,
		wcmd_addr				=> wfm_player_wcmd_addr,
		wcmd_wr					=> wfm_player_wcmd_wr,
		wcmd_brst_en			=> wfm_player_wcmd_brst_en,
		wcmd_data				=> wfm_player_wcmd_data,
		rcmd_clk					=> rcmd_clk,
		rcmd_reset_n			=> wfm_player_rcmd_reset_n,
		rcmd_rdy					=> DDR2_ctrl_rcmd_rdy,
		rcmd_addr				=> wfm_player_rcmd_addr,
		rcmd_wr					=> wfm_player_rcmd_wr,
		rcmd_brst_en			=> wfm_player_rcmd_brst_en

        );

-- ----------------------------------------------------------------------------
-- DDR2 controller instance
-- ----------------------------------------------------------------------------
  DDR2_ctrl_top_inst : entity work.DDR2_ctrl_top 
generic map (
    		cntrl_rate			=> cntrl_rate, --1 - full rate, 2 - half rate
			cntrl_bus_size		=> cntrl_bus_size,
			addr_size			=> addr_size,
			lcl_bus_size		=> lcl_bus_size,
			lcl_burst_length	=> lcl_burst_length,
			cmd_fifo_size		=> cmd_fifo_size,
			outfifo_size		=> dcmpr_fifo_size
)
port map(
      pll_ref_clk       	=> ddr2_pll_ref_clk,
      global_reset_n   		=> ddr2_reset_n,
		soft_reset_n			=> ddr2_reset_n,

		wcmd_clk					=> wcmd_clk, 
		wcmd_reset_n			=> wfm_player_wcmd_reset_n, 
		wcmd_rdy					=> DDR2_ctrl_wcmd_rdy, 
		wcmd_addr				=> wfm_player_wcmd_addr, 
		wcmd_wr					=> wfm_player_wcmd_wr, 
		wcmd_brst_en			=> wfm_player_wcmd_brst_en, 
		wcmd_data				=> wfm_player_wcmd_data, 
		rcmd_clk					=> rcmd_clk, 
		rcmd_reset_n			=> wfm_player_rcmd_reset_n, 
		rcmd_rdy					=> DDR2_ctrl_rcmd_rdy, 
		rcmd_addr				=> wfm_player_rcmd_addr, 
		rcmd_wr					=> wfm_player_rcmd_wr, 
		rcmd_brst_en			=> wfm_player_rcmd_brst_en,
		outbuf_wrusedw			=> dcmpr_wusedw,	

		local_ready				=> DDR2_ctrl_local_ready,
		local_rdata				=> DDR2_ctrl_local_rdata,
		local_rdata_valid		=> DDR2_ctrl_local_rdata_valid,
		local_init_done		=> DDR2_ctrl_local_init_done,

		mem_odt					=> mem_odt,
		mem_cs_n					=> mem_cs_n,
		mem_cke					=> mem_cke,
		mem_addr					=> mem_addr,
		mem_ba					=> mem_ba,
		mem_ras_n				=> mem_ras_n,
		mem_cas_n				=> mem_cas_n,
		mem_we_n					=> mem_we_n,
		mem_dm					=> mem_dm,
		phy_clk					=> DDR2_ctrl_phy_clk,
		--aux_full_rate_clk	: out std_logic;
		--aux_half_rate_clk	: out std_logic;
		--reset_request_n	: out std_logic;
		mem_clk					=> mem_clk,
		mem_clk_n				=> mem_clk_n,
		mem_dq					=> mem_dq,
		mem_dqs					=> mem_dqs,
		begin_test				=> begin_test,
		insert_error			=> insert_error,
		pnf_per_bit				=> pnf_per_bit, 
		pnf_per_bit_persist  => pnf_per_bit_persist,
		pass                	=> pass,
		fail                	=> fail, 
		test_complete       	=> test_complete
	
    );
	 
-- ----------------------------------------------------------------------------
-- Payload decompress module
-- ----------------------------------------------------------------------------	 
dcmpr :  decompress 
  generic map  (
					dev_family => dev_family,
					data_width => data_width,
               fifo_rsize => dcmpr_fifo_size+2,
					fifo_wsize => dcmpr_fifo_size
					)
  port map(
        --input ports 
        wclk          => DDR2_ctrl_phy_clk,  
        rclk          => iq_clk, 
        reset_n       => wfm_load_i, 
        data_in       => DDR2_ctrl_local_rdata, 
        data_in_valid => DDR2_ctrl_local_rdata_valid, 
        sample_width  => sample_width,
        rdreq         => rdfifo_read,
        rdempty       => dcmpr_rdempty,
        rdusedw       => open, 
        wfull         => open, 
        wusedw        => dcmpr_wusedw,
        dataout_valid => open,  
        decmpr_data   => dcmpr_q    
        );	
		 
-- ----------------------------------------------------------------------------
-- Read and form samples from decompress fifo
-- ----------------------------------------------------------------------------			
rd_fifo : rd_tx_fifo 
  generic map (sampl_width =>12)
  port map (
      clk			=> iq_clk,
      reset_n		=> wfm_load_i, 
      fr_start  	=> fr_start, 
      ch_en			=> ch_en,
      mimo_en		=> mimo_en,
      fifo_empty	=> dcmpr_rdempty,
      fifo_data	=> dcmpr_q, 
      fifo_read	=> rdfifo_read, 
      diq_h			=> dd_iq_h_int, 
      diq_l			=> dd_iq_l_int
        );		



phy_clk<=DDR2_ctrl_phy_clk;

dd_iq_h<=dd_iq_l_int;
dd_iq_l<=dd_iq_h_int;	


--dd_iq_h_uns<="000" & dd_iq_l_int(12) & std_logic_vector(signed(dd_iq_l_int(11 downto 0))+2048);
--dd_iq_l_uns<="000" & dd_iq_l_int(12) & std_logic_vector(signed(dd_iq_h_int(11 downto 0))+2048);

wfm_rdy<=wfm_player_wcmd_reset_n;

  
end arch;   






