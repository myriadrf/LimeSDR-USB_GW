-- ----------------------------------------------------------------------------	
-- FILE: 	diq2_samples.vhd
-- DESCRIPTION:	Writes diq samples to fifo 
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
entity diq2_samples is
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
end diq2_samples;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of diq2_samples is
--declare signals,  components here
--signals from lms7002_ddin module
signal inst1_data_out_h, inst1_data_out_l : std_logic_vector (diq_width downto 0);
signal inst2_data_out_h, inst2_data_out_l : std_logic_vector (diq_width downto 0);

--signals from test_data_dd module
signal test_data_h, test_data_l : std_logic_vector (diq_width downto 0);

--data mux
signal mux_data_h, mux_data_l		: std_logic_vector (diq_width downto 0);

-- synchronized enable
signal en_reg, en_synch	: std_logic; 

signal rstn_with_synch_en	: std_logic;
	
COMPONENT diq2_sampling is
	GENERIC (dev_family		: string		:= "Cyclone IV E";
				diq_width 		: integer 	:= 12;
				fifo_size		: integer 	:= 12;
				invert_ddio_clk: string 	:= "ON"
				);
	port (
		clk_io       	: in std_logic;
		clk_int			: in std_logic;
		reset_n   		: in std_logic;
		--data in ports
		rxiq				: in std_logic_vector(diq_width-1 downto 0);
		rxiqsel			: in std_logic;
		data_out_h 		: OUT STD_LOGIC_VECTOR(diq_width DOWNTO 0);
		data_out_l 		: OUT STD_LOGIC_VECTOR(diq_width DOWNTO 0)

        );
end COMPONENT;

COMPONENT test_data_dd is
  PORT (
			clk       		: in std_logic;
			reset_n   		: in std_logic;
			fr_start	 		: in std_logic;
			mimo_en			: in std_logic;
			data_h		  	: out std_logic_vector(12 downto 0);
			data_l		  	: out std_logic_vector(12 downto 0)
        );
END COMPONENT;

COMPONENT wr_rx_fifo_v3
GENERIC (sample_wdth : INTEGER
			);
	PORT(	clk			: in std_logic;
			reset_n   	: in std_logic;
			fr_start		: in std_logic;
			mimo_en		: in std_logic; -- mimo mode enable -1, disable-0
			ch_en			: in std_logic_vector(1 downto 0); -- first bit ch A, second bit ch B
			en				: in std_logic;
			diq_h			: in std_logic_vector(sample_wdth downto 0);    --iqsel & diq
			diq_l			: in std_logic_vector(sample_wdth downto 0);    --iqsel & diq
			diq			: out std_logic_vector((2*sample_wdth)-1 downto 0); --diq
			fifo_wr		: out std_logic;
			fifo_wfull	: in std_logic
	);
END COMPONENT;

begin


-- ----------------------------------------------------------------------------
-- DDRIO to sample data from PLL clk
-- ----------------------------------------------------------------------------
lms7002_ddin_inst1 : diq2_sampling
GENERIC MAP(dev_family 			=> dev_family,
				diq_width 			=> diq_width,
				fifo_size			=> 9,
				invert_ddio_clk	=> "ON"
			)
PORT MAP(
		clk_io 		=> clk_iopll,
		clk_int		=> clk,
		reset_n 		=> reset_n,
		rxiqsel 		=> rxiqsel,
		rxiq 			=> rxiq,
		data_out_h 	=> inst1_data_out_h,
		data_out_l	=> inst1_data_out_l
		);
		
-- ----------------------------------------------------------------------------
-- DDRIO to sample data from direct clk
-- ----------------------------------------------------------------------------
lms7002_ddin_inst2 : diq2_sampling
GENERIC MAP(dev_family 			=> dev_family,
				diq_width 			=> diq_width,
				fifo_size			=> 9,
				invert_ddio_clk	=> "OFF"
			)
PORT MAP(
		clk_io 		=> clk_iodirect,
		clk_int		=> clk,
		reset_n 		=> reset_n,
		rxiqsel 		=> rxiqsel,
		rxiq 			=> rxiq,
		data_out_h 	=> inst2_data_out_h,
		data_out_l	=> inst2_data_out_l
		);		


mux_data_h <= inst1_data_out_h when data_src='0' else inst2_data_out_h;
mux_data_l <= inst1_data_out_l when data_src='0' else inst2_data_out_l;


wr_rx_fifo_v3_inst : wr_rx_fifo_v3
GENERIC MAP(sample_wdth => 12
			)
PORT MAP(clk 		=> clk,
		 reset_n 	=> rstn_with_synch_en,
		 fr_start 	=> fr_start,
		 mimo_en 	=> mimo_en,
		 en 			=> en_synch,
		 fifo_wfull => fifo_full,
		 ch_en 		=> ch_en,
		 diq_h 		=> mux_data_h,
		 diq_l 		=> mux_data_l,
		 fifo_wr 	=> fifo_wr,
		 diq 			=> diq);

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


end arch;   






