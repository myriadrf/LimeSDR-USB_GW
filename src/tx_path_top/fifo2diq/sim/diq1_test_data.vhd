-- ----------------------------------------------------------------------------	
-- FILE: 	diq1_test_data.vhd
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
entity diq1_test_data is
   generic( 
      dev_family	: string := "Cyclone IV E";
      iq_width		: integer := 12
   );
   port (
      clk         : in std_logic;
      reset_n     : in std_logic;
      --Mode settings
      trxiqpulse	: in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
		ddr_en 		: in std_logic; -- DDR: 1; SDR: 0
		mimo_en		: in std_logic; -- SISO: 1; MIMO: 0
		ch_en			: in std_logic_vector(1 downto 0); --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B.  
		fidm			: in std_logic; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      --fifo ports 
      fifo_wrfull : in std_logic;
      fifo_wrreq  : out std_logic;
      fifo_q      : out std_logic_vector(iq_width*4-1 downto 0)        
        );
end diq1_test_data;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of diq1_test_data is
--declare signals,  components here
type nco_array_type is array (0 to 7) of std_logic_vector(iq_width-1 downto 0);
signal nco_mimo_I 	: nco_array_type;
signal nco_mimo_Q 	: nco_array_type;  
signal nco_siso_I 	: nco_array_type;
signal nco_siso_Q 	: nco_array_type;
signal nco_cnt		   : unsigned(2 downto 0);

signal fifo_q_nco_mimo   : std_logic_vector(iq_width*4-1 downto 0); 
signal fifo_q_nco_siso   : std_logic_vector(iq_width*4-1 downto 0);



begin

-- nco_array_h<= (x"07ff",x"17ff",x"0000",x"1000",x"0800",x"1800",x"0000",x"1000");
-- nco_array_l<= (x"0000",x"1000",x"07ff",x"17ff",x"0000",x"1000",x"0800",x"1800");


nco_mimo_I<= (x"7ff",x"7ff",x"000",x"000",x"800",x"800",x"000",x"000");
nco_mimo_Q<= (x"000",x"000",x"7ff",x"7ff",x"000",x"000",x"800",x"800");

nco_siso_I<= (x"7ff",x"000",x"800",x"000",x"7ff",x"000",x"800",x"000");
nco_siso_Q<= (x"000",x"7ff",x"000",x"800",x"000",x"7ff",x"000",x"800");


 process(reset_n, clk)
    begin
      if reset_n='0' then
         nco_cnt<=(others=>'0');  
      elsif (clk'event and clk = '1') then
         nco_cnt<=nco_cnt+2;
 	    end if;
    end process;
    
    
     process(reset_n, clk)
    begin
      if reset_n='0' then
         fifo_q_nco_mimo<=(others=>'0');
         fifo_q_nco_siso<=(others=>'0');          
      elsif (clk'event and clk = '1') then
         fifo_q_nco_mimo <= nco_mimo_I(to_integer(nco_cnt)) & nco_mimo_Q(to_integer(nco_cnt)) & nco_mimo_I(to_integer(nco_cnt+1)) & nco_mimo_Q(to_integer(nco_cnt+1));
 	    end if;
    end process;
  
end arch;   





