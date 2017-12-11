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
entity data2packets_fsm_tb is
end data2packets_fsm_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of data2packets_fsm_tb is
constant clk0_period          : time := 10 ns;
constant clk1_period          : time := 10 ns; 
   --signals
signal clk0,clk1		         : std_logic;
signal reset_n                : std_logic; 
   
   --dut0 signals
signal dut0_pct_buff_rdy      : std_logic;
signal dut0_smpl_rd_size      : std_logic_vector(11 downto 0):=x"007";
signal dut0_smpl_buff_rdy     : std_logic;
signal dut0_data2packets_done : std_logic;
signal dut0_smpl_buff_rdreq   : std_logic;
  

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
   
  
    
    
proc_name : process(clk0, reset_n)
begin
   if reset_n = '0' then 
      dut0_pct_buff_rdy <= '0';
   elsif (clk0'event AND clk0='1') then 
      dut0_pct_buff_rdy <= not dut0_pct_buff_rdy;
   end if;
end process;
    


 process is
	begin
		dut0_smpl_buff_rdy <= '0'; wait for 200 ns;
      wait until rising_edge(clk0);
		dut0_smpl_buff_rdy <= '1'; wait;
	end process;
   
   
    process is
	begin
		dut0_data2packets_done <= '0';
      wait until falling_edge(dut0_smpl_buff_rdreq);
      wait until rising_edge(clk0);
      wait until rising_edge(clk0);
      wait until rising_edge(clk0);
		dut0_data2packets_done <= '1';
      wait until rising_edge(clk0);
      dut0_data2packets_done <= '0';
      wait until rising_edge(dut0_smpl_buff_rdreq);
	end process;
   
   
   


   

  
  dut0 : entity work.data2packets_fsm            
   port map(              
      clk               => clk0,
      reset_n           => reset_n,  
      pct_buff_rdy      => dut0_pct_buff_rdy,  
      pct_buff_wr_dis   => open,  
      smpl_rd_size      => dut0_smpl_rd_size,  
      smpl_buff_rdy     => dut0_smpl_buff_rdy,  
      smpl_buff_rdreq   => dut0_smpl_buff_rdreq,  
      data2packets_done => dut0_data2packets_done 
   
   
   
      );
      
	
	end tb_behave;
  
  


  
