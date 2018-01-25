-- ----------------------------------------------------------------------------	
-- FILE: 	smpl_cmp_tb.vhd
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
entity smpl_cmp_tb is
end smpl_cmp_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of smpl_cmp_tb is
   constant clk0_period    : time := 10 ns;
   constant clk0_phshift   : time := 0 ns;
   
   constant clk1_period    : time := 10 ns;
   constant clk1_phshift   : time := 2.5 ns;
   
   --signals
	signal clk0,clk1		   : std_logic;
	signal reset_n          : std_logic; 
   

   signal iq_width            : integer := 12;
   signal mode                : std_logic := '0'; -- JESD207: 1; TRXIQ: 0
	signal trxiqpulse          : std_logic := '0'; -- trxiqpulse on: 1; trxiqpulse off: 0
	signal ddr_en              : std_logic := '1'; -- DDR: 1; SDR: 0
	signal mimo_en             : std_logic := '1'; -- SISO: 1; MIMO: 0
	signal fidm                : std_logic := '0'; -- 0 - frame start low, 1 - frame start high
   signal ch_en               : std_logic_vector(1 downto 0) := "11"; --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B.
                           
   
   
   --dut0
   signal inst0_DIQ        : std_logic_vector(11 downto 0);
   signal inst0_fsync      : std_logic;
   
   --dut1
   signal dut1_diq_out_h   : std_logic_vector(12 downto 0);
   signal dut1_diq_out_l   : std_logic_vector(12 downto 0);
   --dut2
   signal dut2_cmp_start    : std_logic;
   signal dut2_cmp_length   : std_logic_vector(15 downto 0) := x"0008";
   signal dut2_cmp_AI       : std_logic_vector(11 downto 0) := x"AAA";
   signal dut2_cmp_AQ       : std_logic_vector(11 downto 0) := x"555";
   signal dut2_cmp_BI       : std_logic_vector(11 downto 0) := x"AAA";
   signal dut2_cmp_BQ       : std_logic_vector(11 downto 0) := x"555";
   signal dut2_cmp_done     : std_logic;
   signal dut2_cmp_error    : std_logic;
   signal dut2_diq_h        : std_logic_vector(12 downto 0);
   signal dut2_diq_l        : std_logic_vector(12 downto 0);


begin 
  
      clock0: process is
	begin
      clk0 <= '0'; wait for clk0_phshift;
      while (true) loop
         clk0 <= '0'; wait for clk0_period/2;
         clk0 <= '1'; wait for clk0_period/2;
      end loop;
	end process clock0;

   	clock: process is
	begin
      clk1 <= '0'; wait for clk1_phshift;
      while (true) loop
         clk1 <= '0'; wait for clk1_period/2;
         clk1 <= '1'; wait for clk1_period/2;
      end loop;
	end process clock;
	
		res: process is
	begin
		reset_n <= '0'; wait for 20 ns;
		reset_n <= '1'; wait;
	end process res;
   
   
   process is
	begin
		dut2_cmp_start <= '0'; wait for 40 ns;
      wait until rising_edge(clk1);
		dut2_cmp_start <= '1'; wait until  dut2_cmp_done = '1';
	end process;
   
   
 process(clk0, reset_n)
   begin
      if reset_n = '0' then 
         
      elsif (clk0'event AND clk0='1') then 
         
      end if;
   end process;
   
   LMS7002_DIQ2_dut0 : entity work.LMS7002_DIQ2_sim 
generic map (
	file_name => "sim/adc_data",
	data_width => 12
)
port map(
	clk       	=> clk0,
	reset_n   	=> reset_n, 
	mode			=> mode,
	trxiqpulse	=> trxiqpulse,
	ddr_en 		=> ddr_en, 
	mimo_en		=> mimo_en,
	fidm			=> fidm, 

	-- Data to BB
	DIQ 			=> inst0_DIQ,
	fsync			=> inst0_fsync
	
    );
    
    lms7002_ddin_dut1 : entity work.lms7002_ddin
	generic map( 
      dev_family				=> "Cyclone IV E",
      iq_width					=> iq_width,
      invert_input_clocks	=> "ON"
	)
	port map (
      clk       	=> clk1,
      reset_n   	=> reset_n, 
		rxiq		 	=> inst0_DIQ, 
		rxiqsel	 	=> inst0_fsync, 
		data_out_h	=> dut1_diq_out_h, 
		data_out_l	=> dut1_diq_out_l 
        );
   
	
  
smpl_cmp_dut2 : entity work.smpl_cmp
   generic map(
      smpl_width   =>  12
   )
   port map(

      clk            => clk1,
      reset_n        => reset_n,
      --Mode settings
      mode			   => mode, -- JESD207: 1; TRXIQ: 0
		trxiqpulse	   => trxiqpulse, -- trxiqpulse on: 1; trxiqpulse off: 0
		ddr_en 		   => ddr_en, -- DDR: 1; SDR: 0
		mimo_en		   => mimo_en, -- SISO: 1; MIMO: 0
		ch_en			   => ch_en, --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B.
      fidm			   => fidm,
      --control and status
      cmp_start      => dut2_cmp_start,
      cmp_length     => dut2_cmp_length,
      cmp_AI         => dut2_cmp_AI,
      cmp_AQ         => dut2_cmp_AQ,
      cmp_BI         => dut2_cmp_BI,
      cmp_BQ         => dut2_cmp_BQ,
      cmp_done       => dut2_cmp_done,
      cmp_error      => dut2_cmp_error,
      cmp_error_cnt  => open,
      --DIQ bus
      diq_h          => dut1_diq_out_h,
      diq_l          => dut1_diq_out_l          
        );
	
	end tb_behave;
  
  


  
