-- ----------------------------------------------------------------------------	
-- FILE: 	smpl_cnt_tb.vhd
-- DESCRIPTION:	
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
entity smpl_cnt_tb is
end smpl_cnt_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of smpl_cnt_tb is
   constant clk0_period   : time := 10 ns;
   constant clk1_period   : time := 10 ns; 
   --signals
	signal clk0,clk1		: std_logic;
	signal reset_n       : std_logic; 
   
   --dut0
   
   signal dut0_cnt_en : std_logic;
 

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
   
   
 process(clk0, reset_n)
   begin
      if reset_n = '0' then 
         dut0_cnt_en <= '0';
      elsif (clk0'event AND clk0='1') then 
         --dut0_cnt_en <= not dut0_cnt_en;
         dut0_cnt_en <= '1';
      end if;
   end process;
   
	
  
smpl_cnt_dut0 : entity work.smpl_cnt 
   generic map(
      cnt_width   =>  64
   )
   port map(

      clk         => clk0,
      reset_n     => reset_n,
      --Mode settings
      mode			=> '0', -- JESD207: 1; TRXIQ: 0
		trxiqpulse	=> '0', -- trxiqpulse on: 1; trxiqpulse off: 0
		ddr_en 		=> '1', -- DDR: 1; SDR: 0
		mimo_en		=> '1', -- SISO: 1; MIMO: 0
		ch_en			=> "11", --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B.
      --cnt
      sclr        => '1',
      sload       => '0',
      data        => (others=>'1'),
      cnt_en      => dut0_cnt_en,
      q           => open
          
        );
	
	end tb_behave;
  
  


  
