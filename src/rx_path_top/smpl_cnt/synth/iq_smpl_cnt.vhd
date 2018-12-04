-- ----------------------------------------------------------------------------	
-- FILE: 	iq_smpl_cnt.vhd
-- DESCRIPTION:	Sample counter
-- DATE:	March 28, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity iq_smpl_cnt is
   generic(
      cnt_width   : integer := 64
   );
   port (

      clk         : in std_logic;
      reset_n     : in std_logic;
      --Mode settings
      mode			: in std_logic; -- JESD207: 1; TRXIQ: 0
		trxiqpulse	: in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
		ddr_en 		: in std_logic; -- DDR: 1; SDR: 0
		mimo_en		: in std_logic; -- SISO: 1; MIMO: 0
		ch_en			: in std_logic_vector(1 downto 0); --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B.
      --cnt
      sclr        : in std_logic;
      sload       : in std_logic;
      data        : in std_logic_vector(cnt_width-1 downto 0);
      cnt_en      : in std_logic;
      q           : out std_logic_vector(cnt_width-1 downto 0)
          
        );
end ;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of iq_smpl_cnt is
--declare signals,  components here
signal one_ch           : std_logic;
signal shift_cnt_out    : std_logic; 

--inst0
signal inst0_q          : std_logic_vector(cnt_width-1 downto 0);
 
begin

   
lpm_cnt_inst_inst0 : entity work.lpm_cnt_inst
   generic map (
      cnt_width   =>  64
   )
   port map(

      clk      => clk,
      reset_n  => reset_n,
		cin		=> '1',
		cnt_en	=> cnt_en,
		data		=> data,
      sclr     => sclr,
		sload		=> sload,
		cout		=> open,
		q		   => inst0_q

   );

q <= inst0_q;
    
    

  
end arch;   





