-- ----------------------------------------------------------------------------	
-- FILE: 	lpm_cnt_inst.vhd
-- DESCRIPTION:	describe file
-- DATE:	Jan 27, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY lpm;
USE lpm.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity lpm_cnt_inst is
   generic(
      cnt_width   : integer := 64
   );
   port (

      clk      : in std_logic;
      reset_n  : in std_logic;
		cin		: in std_logic ;
		cnt_en	: in std_logic ;
		data		: in std_logic_vector (cnt_width-1 DOWNTO 0);
      sclr     : in std_logic;
		sload		: in std_logic ;
		cout		: out std_logic ;
		q		   : out std_logic_vector (cnt_width-1 DOWNTO 0)


        );
end lpm_cnt_inst;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of lpm_cnt_inst is
--declare signals,  components here

signal aclr : std_logic;


	COMPONENT lpm_counter
	GENERIC (
		lpm_direction		   : STRING;
		lpm_port_updown		: STRING;
		lpm_type		         : STRING;
		lpm_width		      : NATURAL
	);
	PORT (
			aclr	      : IN STD_LOGIC ;
			cin	      : IN STD_LOGIC ;
			clock	      : IN STD_LOGIC ;
			cnt_en	   : IN STD_LOGIC ;
			data	      : IN STD_LOGIC_VECTOR (cnt_width-1 DOWNTO 0);
         sclr        : IN STD_LOGIC;
			sload	      : IN STD_LOGIC ;
			cout	      : OUT STD_LOGIC ;
			q	         : OUT STD_LOGIC_VECTOR (cnt_width-1 DOWNTO 0)
	);
	END COMPONENT;

  
begin

aclr <= NOT reset_n;

	LPM_COUNTER_component : LPM_COUNTER
	GENERIC MAP (
		lpm_direction     => "UP",
		lpm_port_updown   => "PORT_UNUSED",
		lpm_type          => "LPM_COUNTER",
		lpm_width         => cnt_width
	)
	PORT MAP (
		aclr     => aclr,
		cin      => cin,
		clock    => clk,
		cnt_en   => cnt_en,
		data     => data,
      sclr     => sclr,
		sload    => sload,
		cout     => cout,
		q        => q
	);
  
end arch;   





