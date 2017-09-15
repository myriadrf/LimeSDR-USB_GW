-- ----------------------------------------------------------------------------	
-- FILE: 	data2packets_fsm_tb.vhd
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
entity data2packets_tb is
end data2packets_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of data2packets_tb is
constant clk0_period   : time := 10 ns;
constant clk1_period   : time := 10 ns; 
   --signals
signal clk0,clk1		: std_logic;
signal reset_n       : std_logic; 
   
   --dut0 signals
signal dut0_pct_size          : std_logic_vector(15 downto 0):=x"0006";
signal dut0_pct_hdr_0         : std_logic_vector(63 downto 0):=x"0F0F0F0F0F0F0F0F";
signal dut0_pct_hdr_1         : std_logic_vector(63 downto 0);
signal dut0_pct_data          : std_logic_vector(63 downto 0);
signal dut0_pct_data_wrreq    : std_logic;
signal dut0_pct_data_wrreq_delay : std_logic;
signal dut0_pct_state         : std_logic_vector(1 downto 0);
signal pct_cnt                : unsigned(63 downto 0);
  

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
   
   
 process is 
    begin
      dut0_pct_data_wrreq <= '0';
      wait until reset_n = '1';
      wait until rising_edge(clk0) AND dut0_pct_state(1)='0';
      loop
         if rising_edge(clk0) AND dut0_pct_state(1)='1' then 
            exit;
         else 
            wait until rising_edge(clk0);
            dut0_pct_data_wrreq <= not dut0_pct_data_wrreq;
            --dut0_pct_data_wrreq <=  '1';
         end if;
      end loop;
    end process;
    
    
     process(reset_n, clk0)
    begin
      if reset_n='0' then
        pct_cnt <= (others=>'0');  
      elsif (clk0'event and clk0 = '1') then
         if dut0_pct_data_wrreq = '1' then 
            pct_cnt <= pct_cnt + 1;
         else 
            pct_cnt <= pct_cnt;
         end if;
 	    end if;
    end process;
    
    dut0_pct_hdr_1 <= std_logic_vector(pct_cnt);
    dut0_pct_data  <= std_logic_vector(pct_cnt);
   

  
  dut0 : entity work.data2packets
   generic map(
      pct_size_w        => 15
   )
   port map(              
      clk               => clk0,
      reset_n           => reset_n,
      pct_size          => dut0_pct_size,
      pct_hdr_0         => dut0_pct_hdr_0,
      pct_hdr_1         => dut0_pct_hdr_1,
      pct_data          => dut0_pct_data,
      pct_data_wrreq    => dut0_pct_data_wrreq,
      pct_state         => dut0_pct_state,
      pct_wrreq         => open,
      pct_q             => open
      );
      
	
	end tb_behave;
  
  


  
