-- ----------------------------------------------------------------------------	
-- FILE: 	FIFO_PACK_tb.vhd
-- DESCRIPTION:	
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FIFO_PACK.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity FIFO_PACK_tb is
end FIFO_PACK_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of FIFO_PACK_tb is
   constant clk0_period    : time := 10 ns;
   constant clk1_period    : time := 10 ns; 
   --signals
   signal clk0,clk1        : std_logic;
   signal reset_n          : std_logic; 
   
   signal rdwidth          : integer := FIFORD_SIZE(64, 16, 10);
   
   constant bits           : integer := FIFO_WORDS_TO_Nbits(512, true);
   
begin 
   
  

   
   
   
   

   

   


end tb_behave;
  
  


  
