-- ----------------------------------------------------------------------------	
-- FILE: 	diq2_sampling.vhd
-- DESCRIPTION:	describe
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
entity diq2_sampling is
	GENERIC (dev_family			: string		:= "Cyclone IV E";
				diq_width 			: integer 	:= 12;
				fifo_size			: integer 	:= 12;
				invert_ddio_clk	: string 	:= "ON"
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
end diq2_sampling;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of diq2_sampling is
--declare signals,  components here

--signals from lms7002_ddin inst1 module
signal inst1_data_out_h, inst1_data_out_l : std_logic_vector (diq_width downto 0);

signal dddin_data	: std_logic_vector(diq_width*2+1 downto 0);
--inst2 signals

signal inst2_wreq		: std_logic;
signal ins2_rdreq		: std_logic;
signal inst2_wrfull 	: std_logic;
signal inst2_q			: std_logic_vector(diq_width*2+1 downto 0);
signal inst2_rdepty 	: std_logic;



COMPONENT lms7002_ddin
GENERIC (dev_family 				: STRING;
			iq_width 				: INTEGER;
			invert_input_clocks	: string
			);
	PORT(clk 		: IN STD_LOGIC;
		 reset_n 	: IN STD_LOGIC;
		 rxiqsel	 	: IN STD_LOGIC;
		 rxiq 		: IN STD_LOGIC_VECTOR(iq_width-1 DOWNTO 0);
		 data_out_h : OUT STD_LOGIC_VECTOR(iq_width DOWNTO 0);
		 data_out_l : OUT STD_LOGIC_VECTOR(iq_width DOWNTO 0)
	);
END COMPONENT;

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

  
begin

-- ----------------------------------------------------------------------------
-- DDRIO instance
-- ----------------------------------------------------------------------------
lms7002_ddin_inst1 : lms7002_ddin
GENERIC MAP(dev_family 				=> dev_family,
				iq_width 				=> diq_width,
				invert_input_clocks	=> invert_ddio_clk
			)
PORT MAP(clk 		=> clk_io,
		 reset_n 	=> reset_n,
		 rxiqsel 	=> rxiqsel,
		 rxiq 		=> rxiq,
		 data_out_h => inst1_data_out_h,
		 data_out_l => inst1_data_out_l
		 );
		 
dddin_data<= inst1_data_out_h & inst1_data_out_l;	 
		 
		 
inst2 : fifo_inst
GENERIC MAP(
			dev_family 		=> dev_family,
			rdusedw_width 	=> fifo_size,
			rdwidth 			=> diq_width*2+2,
			show_ahead 		=> "ON",
			wrusedw_witdth => fifo_size,
			wrwidth 			=> diq_width*2+2
			)
PORT MAP(
			reset_n 			=> reset_n,
			wrclk 			=> clk_io,
			wrreq 			=> inst2_wreq,
			data 				=> dddin_data,
			rdclk 			=> clk_int,
			rdreq 			=> ins2_rdreq,
			wrfull 			=> inst2_wrfull,
			wrempty			=> open,
			wrusedw			=> open, 
			q 					=> inst2_q,
			rdempty 			=> inst2_rdepty,
			rdusedw 			=> open
			);		 

inst2_wreq <= not inst2_wrfull;
ins2_rdreq <= not inst2_rdepty;

data_out_h <= inst2_q(diq_width*2+1 downto diq_width+1);
data_out_l <= inst2_q(diq_width downto 0);
  
end arch;





