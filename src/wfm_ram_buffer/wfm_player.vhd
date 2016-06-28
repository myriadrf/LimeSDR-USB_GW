-- ----------------------------------------------------------------------------	
-- FILE: 	wfm_player.vhd
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
entity wfm_player is
	generic(
		dev_family				: string  := "Cyclone IV E"; 
		wfm_infifo_size		: integer := 11;
		wfm_outfifo_size		: integer := 11;
		data_width				: integer := 32;
		iq_width					: integer := 12;
		addr_size				: integer := 24;
		cntrl_bus_size			: integer := 16;
		lcl_burst_length		: integer := 2;
		cntrl_rate				: integer := 1 --1 - full rate, 2 - half rate
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
end wfm_player;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of wfm_player is
--declare signals,  components here

signal wfm_infifo_rdusedw 	: std_logic_vector(wfm_infifo_size-1 downto 0);
signal wfm_infifo_rdreq		: std_logic;
signal wfm_infifo_q			: std_logic_vector(cntrl_bus_size*2*cntrl_rate-1 downto 0);
signal wfm_infifo_rdempty	: std_logic;

signal wfm_load_wcmd0, wfm_load_wcmd1, wfm_load_wcmd2 : std_logic;

signal wcmd_last_addr : std_logic_vector(addr_size-1 downto 0);

signal wfm_load_wcmd_ext	: std_logic;

component wfm_wcmd_fsm is
	generic(
		dev_family				: string  := "Cyclone IV E"; 
		wfm_infifo_size		: integer := 11;
		addr_size				: integer := 24;
		lcl_burst_length		: integer := 2
);
	port (
		wcmd_clk					: in std_logic;
		wcmd_reset_n			: in  std_logic;
		wcmd_rdy					: in std_logic;
		wcmd_addr				: out std_logic_vector(addr_size-1 downto 0);
		wcmd_wr					: out std_logic;
		wcmd_brst_en			: out std_logic; --1- writes in burst, 0- single write
		wcmd_last_addr			: out std_logic_vector(addr_size-1 downto 0);

		wfm_load					: in std_logic;
		wfm_load_ext			: out std_logic;
		wfm_play_stop			: in std_logic; -- 1- play, 0- stop

		wfm_infifo_rd			: out std_logic;
		wfm_infifo_rdusedw 	: in std_logic_vector(wfm_infifo_size-1 downto 0)
        
        );
end component;


component wfm_rcmd_fsm is
	generic(
			dev_family			: string  := "Cyclone IV E"; 
			wfm_outfifo_size	: integer := 11;
			addr_size			: integer := 24;
			lcl_burst_length	: integer := 2
);
  port (
      --input ports 
		rcmd_clk					: in std_logic;
		rcmd_reset_n			: in std_logic;
		rcmd_rdy					: in std_logic;
		rcmd_addr				: out std_logic_vector(addr_size-1 downto 0);
		rcmd_wr					: out std_logic;
		rcmd_brst_en			: out std_logic; --1- reads in burst, 0- single read

		wcmd_last_addr			: in std_logic_vector(addr_size-1 downto 0);
 
		wfm_load					: in std_logic;
		wfm_play_stop			: in std_logic -- 1- play, 0- stop
        
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

  
begin

-- ----------------------------------------------------------------------------
-- WFM data buffer
-- ----------------------------------------------------------------------------
wfm_in_fifo	: fifo_inst 
generic map (
		dev_family			=> dev_family,
		wrwidth				=> data_width,
		wrusedw_witdth		=> wfm_infifo_size, --9=256 words 
		rdwidth				=> data_width,
		rdusedw_width		=> wfm_infifo_size,
		show_ahead			=> "ON"
)
port map (
      reset_n       		=> wcmd_reset_n, 
      wrclk         		=> wcmd_clk, 
      wrreq         		=> wfm_wr, 
      data          		=> wfm_data, 
      wrfull        		=> open, 
		wrempty		  		=> open, 
      wrusedw       		=> wfm_infifo_wrusedw, 
      rdclk 	     		=> wcmd_clk, 
      rdreq         		=> wfm_infifo_rdreq, 
      q             		=> wfm_infifo_q, 
      rdempty      		=> wfm_infifo_rdempty, 
      rdusedw       		=> wfm_infifo_rdusedw   
);

wcmd_data<=wfm_infifo_q;


-- ----------------------------------------------------------------------------
-- WFM player write command FSM
-- ----------------------------------------------------------------------------
wfm_wcmd_fsm_inst : wfm_wcmd_fsm 
	generic map(
		dev_family				=> dev_family,  
		wfm_infifo_size		=> wfm_infifo_size, 
		addr_size				=> addr_size, 
		lcl_burst_length		=> lcl_burst_length
)
	port map (
		wcmd_clk					=> wcmd_clk, 
		wcmd_reset_n			=> wcmd_reset_n, 
		wcmd_rdy					=> wcmd_rdy, 
		wcmd_addr				=> wcmd_addr, 
		wcmd_wr					=> wcmd_wr, 
		wcmd_brst_en			=> wcmd_brst_en,
		wcmd_last_addr			=> wcmd_last_addr,

		wfm_load					=> wfm_load_wcmd2,
		wfm_load_ext			=> wfm_load_wcmd_ext, 
		wfm_play_stop			=> wfm_play_stop, 

		wfm_infifo_rd			=> wfm_infifo_rdreq, 
		wfm_infifo_rdusedw 	=> wfm_infifo_rdusedw     
        );


process(wcmd_clk, wcmd_reset_n)begin
	if (wcmd_reset_n = '0')then
		wfm_load_wcmd0<='0';
		wfm_load_wcmd1<='0';
		wfm_load_wcmd2<='0';
	elsif(wcmd_clk'event and wcmd_clk = '1')then 
		wfm_load_wcmd0<=wfm_load;
		wfm_load_wcmd1<=wfm_load_wcmd0;

		if wfm_load_wcmd1='1' then 
			wfm_load_wcmd2<='1';
		elsif wfm_load_wcmd1='0' and wfm_infifo_rdempty='1' then
			wfm_load_wcmd2<='0';
		else
			wfm_load_wcmd2<=wfm_load_wcmd2; 
		end if; 
	end if;	
end process;


-- ----------------------------------------------------------------------------
-- WFM player read command FSM
-- ----------------------------------------------------------------------------
wfm_rcmd_fsm_inst : wfm_rcmd_fsm 
	generic map(
			dev_family			=> dev_family,
			wfm_outfifo_size	=> wfm_outfifo_size,
			addr_size			=> addr_size,
			lcl_burst_length	=> lcl_burst_length
)
  port map(
      --input ports 
		rcmd_clk					=> rcmd_clk,
		rcmd_reset_n			=> rcmd_reset_n,
		rcmd_rdy					=> rcmd_rdy,
		rcmd_addr				=> rcmd_addr,
		rcmd_wr					=> rcmd_wr,
		rcmd_brst_en			=> rcmd_brst_en,

		wcmd_last_addr			=> wcmd_last_addr,
 
		wfm_load					=> wfm_load_wcmd_ext,
		wfm_play_stop			=> wfm_play_stop
        
        );



  
end arch;   






