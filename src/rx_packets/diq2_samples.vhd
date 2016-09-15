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
signal ddin_data_out_h, ddin_data_out_l : std_logic_vector (diq_width downto 0);

--signals from test_data_dd module
signal test_data_h, test_data_l : std_logic_vector (diq_width downto 0);

--data mux
signal mux_data_h, mux_data_l		: std_logic_vector (diq_width downto 0);

-- synchronized enable
signal en_reg, en_synch	: std_logic; 

signal rstn_with_synch_en	: std_logic;
	
COMPONENT lms7002_ddin
GENERIC (dev_family 	: STRING;
			iq_width 	: INTEGER
			);
	PORT(clk 		: IN STD_LOGIC;
		 reset_n 	: IN STD_LOGIC;
		 rxiqsel	 	: IN STD_LOGIC;
		 rxiq 		: IN STD_LOGIC_VECTOR(iq_width-1 DOWNTO 0);
		 data_out_h : OUT STD_LOGIC_VECTOR(iq_width DOWNTO 0);
		 data_out_l : OUT STD_LOGIC_VECTOR(iq_width DOWNTO 0)
	);
END COMPONENT;

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
-- Component instances
-- ----------------------------------------------------------------------------
lms7002_ddin_inst : lms7002_ddin
GENERIC MAP(dev_family 	=> dev_family,
				iq_width 	=> diq_width
			)
PORT MAP(clk 		=> clk,
		 reset_n 	=> rstn_with_synch_en,
		 rxiqsel 	=> rxiqsel,
		 rxiq 		=> rxiq,
		 data_out_h => ddin_data_out_h,
		 data_out_l => ddin_data_out_l);

test_data_dd_inst : test_data_dd
PORT MAP(clk 		=> clk,
		 reset_n 	=> rstn_with_synch_en,
		 fr_start 	=> fr_start,
		 mimo_en		=> mimo_en,
		 data_h 		=> test_data_h,
		 data_l 		=> test_data_l);

mux_data_h <= ddin_data_out_h when data_src='0' else test_data_h;
mux_data_l <= ddin_data_out_l when data_src='0' else test_data_l;


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






