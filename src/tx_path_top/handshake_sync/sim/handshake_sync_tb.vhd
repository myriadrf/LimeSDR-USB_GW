-- ----------------------------------------------------------------------------	
-- FILE: 	handshake_sync_tb.vhd
-- DESCRIPTION:	
-- DATE:	April 13, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity handshake_sync_tb is
end handshake_sync_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of handshake_sync_tb is

   constant clk0_period    : time := 1 ns; 
   constant clk1_period    : time := 6.25 ns; 
   --signals
	signal clk0,clk1        : std_logic;
	signal reset_n          : std_logic; 
   
   signal inst0_en         : std_logic;

begin 
  
   	clock0: process is
	begin
		clk0 <= '0'; wait for clk0_period/2;
		clk0 <= '1'; wait for clk0_period/2;
	end process clock0;

   	clock: process is
	begin
		clk1 <= '0'; wait for clk1_period/2;
		clk1 <= '1'; wait for clk1_period/2;
	end process clock;
	
		res: process is
	begin
		reset_n <= '0'; wait for 20 ns;
		reset_n <= '1'; wait;
	end process res;
   
    inst0en: process is
	begin
		inst0_en <= '0'; wait until reset_n = '1';
      inst0_en <= '0'; wait until rising_edge(clk0);
		inst0_en <= '1'; wait until rising_edge(clk0);
      inst0_en <= '0'; wait;
	end process inst0en;
   
   
   handshake_sync_inst0 : entity work.handshake_sync
   port map(
      src_clk        => clk0,
      src_reset_n    => reset_n,
      src_in         => inst0_en,
      src_busy       => open,

      dst_clk        => clk1,
      dst_reset_n    => reset_n,
      dst_out        => open
      
        );
	

   


	

    
	
	end tb_behave;
   
   
  
  


  