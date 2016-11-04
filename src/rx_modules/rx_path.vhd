-- ----------------------------------------------------------------------------	
-- FILE: 	rx_path.vhd
-- DESCRIPTION:	Forms RX packets
-- DATE:	Sep 14, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity rx_path is
generic(
		dev_family 		: STRING := "Cyclone IV E";
		diq_width 		: INTEGER := 12;
		infifo_wrsize 	: INTEGER := 12;
		outfifo_size 	: INTEGER := 13
		);
  port (
      --input ports
		clk_iopll			: in std_logic;
		clk_iodirect		: in std_logic;
		clk       			: in std_logic;
      reset_n   			: in std_logic;
		en						: in std_logic;
		--data input 
		DIQ2					: in std_logic_vector(diq_width-1 downto 0);
		DIQ2_IQSEL2			: in std_logic;
		--config signals 
		data_src				: in std_logic;
		fr_start				: in std_logic;
		mimo_en				: in std_logic;
		ch_en					: in std_logic_vector(15 downto 0);
		smpl_width			: in std_logic_vector(1 downto 0);
		--other
		pct_clr_detect		: in std_logic;
		clr_pct_loss_flag	: in std_logic;
		clr_smpl_nr			: in std_logic;		
		--pct data
		outfifo_full		: in std_logic;
		outfifo_wrusedw	: in std_logic_vector(outfifo_size-1 downto 0);
		outfifo_wr			: out std_logic;
		outfifo_data		: out std_logic_vector (63 downto 0);
		wrrxfifo_wr			: out std_logic
        
        );
end rx_path;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of rx_path is
--declare signals,  components here
signal my_sig_name : std_logic_vector (7 downto 0); 

-- synchronized enable and reset for other modules

signal en_reg, en_synch		: std_logic; 
signal rstn_with_synch_en	: std_logic; 

--inst1 (diq2_samples) signals
signal inst1_diq 				: std_logic_vector(2*diq_width-1 downto 0);
signal inst1_fifo_wr			: std_logic;

--inst2 signals
signal inst2_wrfull 			: std_logic;
signal inst2_q					: std_logic_vector(diq_width*4-1 downto 0);
signal inst2_rdempty			: std_logic;
signal inst2_rdusedw			: std_logic_vector(infifo_wrsize-2 downto 0);

--inst3 signals 
signal inst3_rdreq			: std_logic;
signal inst3_diq0				: std_logic_vector(63 downto 0);

component diq2_samples is
	GENERIC (dev_family		: string		:= "Cyclone IV E";
				diq_width 		: integer 	:= 12;
				ch_num			: integer 	:= 2;
				fifo_wrsize		: integer 	:= 12
				);
  port (
      --input ports
		clk_iopll		: in std_logic;
		clk_iodirect	: in std_logic;	
      clk				: in std_logic;
      reset_n			: in std_logic;
		en					: in std_logic;
		--data in ports
		rxiq				: in std_logic_vector(diq_width-1 downto 0);
		rxiqsel			: in std_logic;
		--config ports
		data_src			: in std_logic; --selects between test data  - 1 and real data - 0 	
		fr_start			: in std_logic;
		mimo_en			: in std_logic;
		ch_en				: in std_logic_vector(ch_num-1 downto 0);
		fifo_full		: in std_logic;
		fifo_wrusedw	: in std_logic_vector(fifo_wrsize-1 downto 0);	
      --output ports to fifo
		diq				: out std_logic_vector(2*diq_width-1 downto 0);
		fifo_wr			: out std_logic
        );
end component;

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

component rx_pct_data_v2 is
  generic (infifo_rdsize  : integer :=7;
           outfifo_wrsize : integer :=7;
           ch_num         : integer :=16;
           pct_size       : integer :=4096 --in bytes
            );
  port (
        --input ports 
        clk             : in std_logic;
        reset_n         : in std_logic;
        diq0            : in std_logic_vector(63 downto 0);
        --infifo
        infifo_empty    : in std_logic; 
        infifo_rdusedw  : in std_logic_vector(infifo_rdsize-1 downto 0);
        infifo_rd       : out std_logic;
        --outfifo
        outfifo_full    : in std_logic; 
        outfifo_wrusedw : in std_logic_vector(outfifo_wrsize-1 downto 0);
        outfifo_wr      : out std_logic;
        outfifo_data    : out std_logic_vector(63 downto 0);
        --general
        en              : in std_logic;
        ch_en           : in std_logic_vector(ch_num-1 downto 0);
        mimo_en         : in std_logic;
        sample_width    : in std_logic_vector(1 downto 0); --"00"-16bit, "01"-14bit, "10"-14bit;
        tx_pct_loss     : in std_logic; -- clock domain of this signal has to be more than 2x slover, othervise 
                                       --implement synchronizer with handshaking
        tx_pct_loss_clr : in std_logic;
		  pct_wr_end		: out std_logic;
		  clr_smpl_nr		: in std_logic
        
        
        );
end component;

begin

-- ----------------------------------------------------------------------------
-- To synchronize enable to clk domain
-- ----------------------------------------------------------------------------
  process(reset_n, clk)
    begin
      if reset_n='0' then
       	en_reg<='0';
			en_synch<='0'; 
      elsif (clk'event and clk = '1') then
       	en_reg<=en;
			en_synch<=en_reg; 
 	    end if;
    end process;
 
rstn_with_synch_en<= reset_n and  en_synch;

-- ----------------------------------------------------------------------------
-- Component instances
-- ----------------------------------------------------------------------------
inst1 : diq2_samples
GENERIC MAP(
			ch_num 		=> 2,
			dev_family 	=> dev_family,
			diq_width 	=> diq_width,
			fifo_wrsize => infifo_wrsize
			)
PORT MAP(
		clk_iopll		=> clk_iopll,
		clk_iodirect	=> clk_iodirect,
		clk				=> clk,
		reset_n			=> rstn_with_synch_en,
		en					=> rstn_with_synch_en,
		rxiq 				=> DIQ2,
		rxiqsel			=> DIQ2_IQSEL2,
		data_src			=> data_src,
		fr_start 		=> fr_start,
		mimo_en			=> mimo_en,
		ch_en				=> ch_en(1 DOWNTO 0),
		fifo_full		=> inst2_wrfull,
		fifo_wrusedw 	=> (others=>'0'),
		diq 				=> inst1_diq,
		fifo_wr 			=> inst1_fifo_wr
);

inst2 : fifo_inst
GENERIC MAP(
			dev_family 		=> dev_family,
			rdusedw_width 	=> infifo_wrsize-1,
			rdwidth 			=> diq_width*4,
			show_ahead 		=> "ON",
			wrusedw_witdth => infifo_wrsize,
			wrwidth 			=> diq_width*2
			)
PORT MAP(
			reset_n 			=> rstn_with_synch_en,
			wrclk 			=> clk,
			wrreq 			=> inst1_fifo_wr,
			data 				=> inst1_diq,
			rdclk 			=> clk,
			rdreq 			=> inst3_rdreq,
			wrfull 			=> inst2_wrfull,
			wrempty			=> open,
			wrusedw			=> open, 
			q 					=> inst2_q,
			rdempty 			=> inst2_rdempty,
			rdusedw 			=> inst2_rdusedw);
 
inst3 : rx_pct_data_v2
GENERIC MAP(
			infifo_rdsize 		=> infifo_wrsize-1,
			outfifo_wrsize 	=> outfifo_size,
			ch_num 				=> 16,
			pct_size 			=> 4096
			)
PORT MAP(
			clk 					=> clk,
			reset_n 				=> rstn_with_synch_en,
			diq0 					=> inst3_diq0,
			infifo_empty 		=> inst2_rdempty,
			infifo_rdusedw 	=> inst2_rdusedw,
			infifo_rd 			=> inst3_rdreq,
			outfifo_full 		=> outfifo_full,
			outfifo_wrusedw 	=> outfifo_wrusedw,
			outfifo_wr 			=> outfifo_wr,
			outfifo_data 		=> outfifo_data,
			en 					=> rstn_with_synch_en,
			ch_en 				=> ch_en,
			mimo_en 				=> mimo_en,
			sample_width 		=> smpl_width,
			tx_pct_loss 		=> pct_clr_detect,
			tx_pct_loss_clr 	=> clr_pct_loss_flag,
			pct_wr_end			=> open,
			clr_smpl_nr 		=> clr_smpl_nr

			);
 
inst3_diq0<=inst2_q(47 downto 36) & "0000" & 
				inst2_q(35 downto 24) & "0000" & 
				inst2_q(23 downto 12) & "0000" & 
				inst2_q(11 downto 0)  & "0000";
				
				
----12bit samples are packed to 16 bit words with sign extension 
--inst3_diq0<=(63 downto 60 => inst2_q(47)) & inst2_q(47 downto 36) & 
--				(47 downto 44 => inst2_q(35)) & inst2_q(35 downto 24) & 
--				(31 downto 28 => inst2_q(23)) & inst2_q(23 downto 12) & 
--				(15 downto 12 => inst2_q(11)) & inst2_q(11 downto 0);				

wrrxfifo_wr<=inst1_fifo_wr;
end arch;   


