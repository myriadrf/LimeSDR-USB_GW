-- ----------------------------------------------------------------------------	
-- FILE: 	data2packets_top_tb.vhd
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
entity data2packets_top_tb is
end data2packets_top_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of data2packets_top_tb is
constant clk0_period          : time := 10 ns;
constant clk1_period          : time := 10 ns; 
   --signals
signal clk0,clk1		         : std_logic;
signal reset_n                : std_logic; 
   
--dut0 signals
signal dut0_sample_width      : std_logic_vector(1 downto 0) := "10"; --"10"-12bit, "01"-14bit, "00"-16bit;
signal dut0_pct_hdr_0         : std_logic_vector(63 downto 0) := (others=>'1');
signal dut0_pct_hdr_1         : std_logic_vector(63 downto 0);         
signal dut0_pct_buff_wrreq    : std_logic;
signal dut0_pct_buff_wrdata   : std_logic_vector(63 downto 0);
signal dut0_smpl_buff_rdreq   : std_logic;

signal smpl_fifo_size         : integer := 11;
signal pct_fifo_size          : integer := 12;

--inst1
signal inst1_wrreq            : std_logic;
signal inst1_data             : std_logic_vector(47 downto 0);
signal inst1_q                : std_logic_vector(47 downto 0);
signal inst1_rdusedw          : std_logic_vector(10 downto 0);

--inst2 
signal inst2_wrusedw          : std_logic_vector(11 downto 0);

 

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
         dut0_pct_hdr_1 <= (others=>'0');
      elsif (clk0'event AND clk0='1') then 
         if dut0_smpl_buff_rdreq = '1' then 
            dut0_pct_hdr_1 <= std_logic_vector(unsigned(dut0_pct_hdr_1)+1);
         else 
            dut0_pct_hdr_1 <= dut0_pct_hdr_1;
         end if;
      end if;
   end process;
   
   

  
  dut0 : entity work.data2packets_top 
   generic map (
      smpl_buff_rdusedw_w => 11, --bus width in bits 
      pct_buff_wrusedw_w  => 12 --bus width in bits  
   )
   port map(              
      clk               => clk0,
      reset_n           => reset_n,
      sample_width      => dut0_sample_width,
      pct_hdr_0         => dut0_pct_hdr_0,
      pct_hdr_1         => dut0_pct_hdr_1,
      pct_buff_wrusedw  => inst2_wrusedw,
      pct_buff_wrreq    => dut0_pct_buff_wrreq,
      pct_buff_wrdata   => dut0_pct_buff_wrdata,
      smpl_buff_rdusedw => inst1_rdusedw,
      smpl_buff_rdreq   => dut0_smpl_buff_rdreq,
      smpl_buff_rddata  => (others=>'0')
      );
      
      
 proc_name : process(clk0, reset_n)
 begin
    if reset_n = '0' then 
       inst1_wrreq <= '0';
    elsif (clk0'event AND clk0='1') then 
       inst1_wrreq <= NOT inst1_wrreq;
    end if;
 end process;
      
      
fifo_inst_inst1 : entity work.fifo_inst
  generic map (
      dev_family	    => "Cyclone IV E",
      wrwidth         => 48,
      wrusedw_witdth  => 11, --12=2048 words 
      rdwidth         => 48,
      rdusedw_width   => 11,
      show_ahead      => "OFF"
  ) 
  port map(
      --input ports 
      reset_n       => reset_n,
      wrclk         => clk0,
      wrreq         => inst1_wrreq,
      data          => inst1_data,
      wrfull        => open,
		wrempty		  => open,
      wrusedw       => open,
      rdclk 	     => clk0,
      rdreq         => dut0_smpl_buff_rdreq,
      q             => inst1_q,
      rdempty       => open,
      rdusedw       => inst1_rdusedw
        );
        
        
fifo_inst_inst2 : entity work.fifo_inst
  generic map (
      dev_family	    => "Cyclone IV E",
      wrwidth         => 64,
      wrusedw_witdth  => 12, --12=2048 words 
      rdwidth         => 64,
      rdusedw_width   => 12,
      show_ahead      => "OFF"
  ) 
  port map(
      --input ports 
      reset_n       => reset_n,
      wrclk         => clk0,
      wrreq         => dut0_pct_buff_wrreq,
      data          => dut0_pct_buff_wrdata,
      wrfull        => open,
		wrempty		  => open,
      wrusedw       => inst2_wrusedw,
      rdclk 	     => clk0,
      rdreq         => '0',
      q             => open,
      rdempty       => open,
      rdusedw       => open
        );
	
	end tb_behave;
  
  


  
