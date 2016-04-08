-- ----------------------------------------------------------------------------	
-- FILE: 	fifo_inst.vhd
-- DESCRIPTION:	describe
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
LIBRARY altera_mf;
USE altera_mf.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity fifo_inst is
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



      --output ports 
        
        );
end fifo_inst;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of fifo_inst is
--declare signals,  components here
signal aclr : std_logic;


	COMPONENT dcfifo_mixed_widths
	GENERIC (
		add_usedw_msb_bit				: STRING;
		intended_device_family		: STRING;
		lpm_numwords					: NATURAL;
		lpm_showahead					: STRING;
		lpm_type							: STRING;
		lpm_width						: NATURAL;
		lpm_widthu						: NATURAL;
		lpm_widthu_r					: NATURAL;
		lpm_width_r						: NATURAL;
		overflow_checking				: STRING;
		rdsync_delaypipe				: NATURAL;
		read_aclr_synch				: STRING;
		underflow_checking			: STRING;
		use_eab							: STRING;
		write_aclr_synch				: STRING;
		wrsync_delaypipe				: NATURAL
	);
	PORT (
			aclr		: IN STD_LOGIC ;
			data		: IN STD_LOGIC_VECTOR (wrwidth-1 downto 0);
			rdclk	   : IN STD_LOGIC ;
			rdreq	   : IN STD_LOGIC ;
			wrclk	   : IN STD_LOGIC ;
			wrreq	   : IN STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR(rdwidth-1 downto 0);
			rdempty	: OUT STD_LOGIC ;
			rdusedw	: OUT STD_LOGIC_VECTOR (rdusedw_width-1 downto 0); 
			wrempty	: out std_logic;
			wrfull	: OUT STD_LOGIC;
			wrusedw	: OUT STD_LOGIC_VECTOR (wrusedw_witdth-1 downto 0)
	);
	END COMPONENT;
	

  
begin
  
  aclr<= not reset_n;
  
  
  	dcfifo_mixed_widths_component : dcfifo_mixed_widths
	GENERIC MAP (
		add_usedw_msb_bit       => "ON",
		intended_device_family  => dev_family,
		lpm_numwords            => 2**(wrusedw_witdth-1),
		lpm_showahead           => show_ahead,
		lpm_type                => "dcfifo_mixed_widths",
		lpm_width               => wrwidth,
		lpm_widthu              => wrusedw_witdth,
		lpm_widthu_r            => rdusedw_width,
		lpm_width_r             => rdwidth,
		overflow_checking       => "ON",
		rdsync_delaypipe        => 4,
		read_aclr_synch         => "OFF",
		underflow_checking      => "ON",
		use_eab                 => "ON",
		write_aclr_synch        => "OFF",
		wrsync_delaypipe        => 4
	)
	PORT MAP (
		aclr    	=> aclr,
		data    	=> data,
		rdclk   	=> rdclk,
		rdreq   	=> rdreq,
		wrclk   	=> wrclk,
		wrreq   	=> wrreq,
		q       	=> q,
		rdempty 	=> rdempty,
		rdusedw 	=> rdusedw,
		wrempty	=> wrempty,
		wrfull  	=> wrfull,
		wrusedw	=> wrusedw
	);

  
end arch;   





