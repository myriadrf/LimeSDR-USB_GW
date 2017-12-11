-- ----------------------------------------------------------------------------	
-- FILE: 	packets2data_tb.vhd
-- DESCRIPTION:	
-- DATE:	April 03, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity packets2data_top_tb is
end packets2data_top_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of packets2data_top_tb is
constant clk0_period    : time := 10 ns;
constant clk1_period    : time := 10 ns; 

constant smpl_nr_delay  : integer := 13;
   --signals
signal clk0,clk1		   : std_logic;
signal reset_n          : std_logic; 
   
   --dut0 signals
signal dut0_pct_size          : std_logic_vector(15 downto 0):=x"000A";
signal dut0_sample_width      : std_logic_vector(1 downto 0) := "01"; ----"10"-12bit, "01"-14bit, "00"-16bit;
signal dut0_pct_data          : std_logic_vector(31 downto 0);
signal dut0_in_pct_wrreq      : std_logic;
signal dut0_in_pct_last       : std_logic;
signal dut0_sample_nr         : std_logic_vector(63 downto 0);
signal pct_cnt                : unsigned(31 downto 0);
signal pct_cnt_reg            : std_logic_vector(31 downto 0);

type my_array is array (0 to smpl_nr_delay) of std_logic_vector(63 downto 0);

signal smpl_nr_array : my_array;
  

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
   
   
     process(reset_n, clk0)
    begin
      if reset_n='0' then
         pct_cnt <= (others=>'0');
         dut0_in_pct_wrreq <= '1'; 
         pct_cnt_reg <= (others=>'0');
      elsif (clk0'event and clk0 = '1') then
            if dut0_in_pct_last='0' then             
               dut0_in_pct_wrreq <= '1';
               --dut0_in_pct_wrreq <= NOT dut0_in_pct_wrreq;
            else 
               dut0_in_pct_wrreq <= '0';
            end if;
         if dut0_in_pct_wrreq = '1' then 
            pct_cnt <= pct_cnt + 1;
         else 
            pct_cnt <= pct_cnt;
         end if;
         pct_cnt_reg<= std_logic_vector(pct_cnt);
 	    end if;
    end process;
    
  
   dut0_pct_data  <= std_logic_vector(pct_cnt);
   
   dut0_sample_nr <=pct_cnt_reg & std_logic_vector(pct_cnt);
   
   
   
   
   proc_name : process(clk0, reset_n)
   begin
      if reset_n = '0' then 
         smpl_nr_array <= (others=>(others=>'0'));
      elsif (clk0'event AND clk0='1') then 
         for i in 0 to smpl_nr_delay-1 loop
            if i = 0 then 
               smpl_nr_array(0) <= dut0_sample_nr;
            else 
               smpl_nr_array(i) <= smpl_nr_array(i-1);
            end if;
         end loop;
      end if;
   end process;
  
  packets2data_top_dut0 : entity work.packets2data_top
   generic map (
      dev_family        => "Cyclone IV E",
      pct_size_w        =>  16,
      n_buff            =>  4, -- 2,4 valid values
      in_pct_data_w     =>  32,
      out_pct_data_w    =>  64
   )
   port map(

      wclk              => clk0,
      rclk              => clk1, 
      reset_n           => reset_n,
      pct_size          => dut0_pct_size,
      sample_width      => dut0_sample_width,
      
      pct_sync_dis      => '0',
      sample_nr         => smpl_nr_array(smpl_nr_delay-1),
      
      in_pct_wrreq      => dut0_in_pct_wrreq,
      in_pct_data       => dut0_pct_data,
      in_pct_last       => dut0_in_pct_last,
      in_pct_full       => open,
      in_pct_buff_rdy   => open, 
      
      smpl_buff_rdempty => open,
      smpl_buff_q       => open,    
      smpl_buff_rdreq   => '0'
        );
      
	
	end tb_behave;
  
  


  
