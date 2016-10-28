-- ----------------------------------------------------------------------------	
-- FILE: 	stream_switch.vhd
-- DESCRIPTION:	to mux incomming stream 
-- DATE:	Oct 17, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity stream_switch is
	generic(
			data_width					: integer := 32;
			wfm_fifo_wrusedw_size	: integer := 12;
			wfm_limit					: integer := 4096
	);
	port (
        clk       			: in std_logic;
        reset_n   			: in std_logic;
		  data_in 				: in std_logic_vector(data_width-1 downto 0);
		  data_in_valid		: in std_logic;
		  data_in_rdy			: out std_logic;
		  
		  dest_sel				: in std_logic;
		  
		  tx_fifo_rdy			: in std_logic;
		  tx_fifo_wr			: out std_logic;
		  tx_fifo_data			: out std_logic_vector(data_width-1 downto 0);
		  
		  wfm_rdy				: in std_logic;
		  wfm_fifo_wr			: out std_logic;
		  wfm_data				: out std_logic_vector(data_width-1 downto 0);
		  wfm_fifo_wrusedw	: in std_logic_vector(wfm_fifo_wrusedw_size-1 downto 0)
		  
        
        );
end stream_switch;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of stream_switch is
--declare signals,  components here
signal wfm_fifo_wrwords 					: unsigned (wfm_fifo_wrusedw_size-1 downto 0);
signal wfm_rdy_int							: std_logic;
signal dest_sel_syncreg						: std_logic_vector(2 downto 0);


component pct_payload_extrct is
	generic (data_w			: integer := 32;
				header_size		: integer := 16; --pct header size in bytes 
				pct_size			: integer := 4096 --pct size in bytes
		);
  port (
      --input ports 
		clk					: in std_logic;
		reset_n				: in std_logic;
		pct_data				: in std_logic_vector(data_w-1 downto 0);
		pct_wr				: in std_logic;
		pct_payload_data	: out std_logic_vector(data_w-1 downto 0);
		pct_payload_valid	: out std_logic;
		pct_payload_dest	: out std_logic_vector(1 downto 0)
        
        );
end component;
  
begin

process(reset_n, clk)
begin
	if reset_n = '0' then 
		dest_sel_syncreg<=(others=>'0');
	elsif	(clk'event and clk='0') then 
		dest_sel_syncreg<=dest_sel_syncreg(1 downto 0) & dest_sel;
	end if;
end process;


inst0 :  pct_payload_extrct
	generic map (data_w			=> 32,
					header_size		=> 16, --pct header size in bytes 
					pct_size			=> 4096 --pct size in bytes
		)
  port map (
      --input ports 
		clk					=> clk,
		reset_n				=> dest_sel_syncreg(1),
		pct_data				=> data_in,
		pct_wr				=> data_in_valid,
		pct_payload_data	=> wfm_data,
		pct_payload_valid	=> wfm_fifo_wr,
		pct_payload_dest	=> open
        
        );

wfm_fifo_wrwords <= ((wfm_fifo_wrusedw_size-1) =>'1', others=>'0');
	  
tx_fifo_wr 		<= data_in_valid when dest_sel_syncreg(1)='0' else '0';
tx_fifo_data	<= data_in;


wfm_rdy_int		<= '1' when ((wfm_fifo_wrwords - unsigned(wfm_fifo_wrusedw)) > (wfm_limit*8/32)+5 and wfm_rdy='1' )else '0'; 

data_in_rdy		<= tx_fifo_rdy when dest_sel_syncreg(1)='0' else wfm_rdy_int;
  
end arch;





