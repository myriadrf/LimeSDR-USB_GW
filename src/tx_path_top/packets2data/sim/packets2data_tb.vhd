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
use work.FIFO_PACK.all;
use ieee.STD_LOGIC_TEXTIO.ALL;
use STD.textio.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity packets2data_tb is
end packets2data_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of packets2data_tb is
constant clk0_period    : time := 10 ns;
constant clk1_period    : time := 10 ns; 

constant smpl_nr_delay  : integer := 13;
constant C_PCT_SIZE     : integer := 4096;
   --signals
signal clk0,clk1		   : std_logic;
signal reset_n          : std_logic; 

constant file_data_width   : integer := 64;
signal file_read           : std_logic;
signal file_data           : std_logic_vector(file_data_width-1 downto 0);

constant C_DUT0_SIZE             : integer := 4096;
constant C_DUT0_WRWIDTH          : integer := file_data_width;
constant C_DUT0_WRUSEDW_WITDTH   : integer := FIFO_WORDS_TO_Nbits((C_DUT0_SIZE*8)/C_DUT0_WRWIDTH, true);
constant C_DUT0_RDWIDTH          : integer := 128;
constant C_DUT0_RDUSEDW_WIDTH    : integer := FIFO_WORDS_TO_Nbits((C_DUT0_SIZE*8)/C_DUT0_RDWIDTH, true);

   --dut0 signals
signal dut0_wrreq    : std_logic;
signal dut0_data     : std_logic_vector(C_DUT0_WRWIDTH-1 downto 0);
signal dut0_wrempty  : std_logic;
signal dut0_q        : std_logic_vector(C_DUT0_RDWIDTH-1 downto 0);
signal dut0_rdusedw  : std_logic_vector(C_DUT0_RDUSEDW_WIDTH-1 downto 0);

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
   
-- ----------------------------------------------------------------------------
-- Writing to FIFO. Full packet is written to FIFO when dut0_wrempty is detected
-- ----------------------------------------------------------------------------   
   fifo_wr_proc : process 
   begin
      file_read <= '0';
      wait until rising_edge(clk0) AND reset_n = '1';
         for i in 0 to (C_PCT_SIZE*8)/C_DUT0_WRWIDTH - 1 loop
            file_read <= '1';
            wait until rising_edge(clk0);
         end loop;
         file_read <= '0';
         wait until dut0_wrempty = '1';
         wait until rising_edge(clk0);
   end process;
   
-- ----------------------------------------------------------------------------
-- Read packet data
-- ----------------------------------------------------------------------------   
   process(clk0, reset_n)
      --select one of the three files depending on sample width
      FILE in_file      : TEXT OPEN READ_MODE IS "sim/out_pct_6_12b";
      --FILE in_file      : TEXT OPEN READ_MODE IS "sim/out_pct_6_14b";
      --FILE in_file      : TEXT OPEN READ_MODE IS "sim/out_pct_6_16b";  
      VARIABLE in_line  : LINE;
      VARIABLE data     : std_logic_vector(63 downto 0);
   begin
      if reset_n = '0' then 
         file_data <= (others=>'0');
      elsif (clk0'event AND clk0='1') then 
         if file_read = '1' then 
            READLINE(in_file, in_line);
            HREAD(in_line, data);
            file_data <= data;
         else 
            file_data <= file_data;
         end if;
      end if;
   end process;

   process(clk0, reset_n)
   begin
      if reset_n = '0' then 
         dut0_wrreq <= '0';
      elsif (clk0'event AND clk0='1') then
         dut0_wrreq <= file_read;
      end if;
   end process;
  
-- ----------------------------------------------------------------------------
-- FIFO instance (Simulating stream FIFO)
-- ----------------------------------------------------------------------------   
   fifo_inst_dut0 : entity work.fifo_inst
   generic map(
      dev_family     => "Cyclone IV E",
      wrwidth        => C_DUT0_WRWIDTH,
      wrusedw_witdth => C_DUT0_WRUSEDW_WITDTH,
      rdwidth        => C_DUT0_RDWIDTH,
      rdusedw_width  => C_DUT0_RDUSEDW_WIDTH,
      show_ahead     => "OFF"
   )  
   port map(
      --input ports 
      reset_n  => reset_n,
      wrclk    => clk0,
      wrreq    => dut0_wrreq,
      data     => dut0_data,
      wrfull   => open,
      wrempty  => dut0_wrempty,
      wrusedw  => open,
      rdclk    => clk1,
      rdreq    => '0',
      q        => dut0_q,
      rdempty  => open,
      rdusedw  => dut0_rdusedw
   ); 

   end tb_behave;
  
  


  
