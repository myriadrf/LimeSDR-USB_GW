
-- ----------------------------------------------------------------------------	
-- FILE: 	wr_rx_fifo_v3_tb.vhd
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
entity wr_rx_fifo_v3tb is
end wr_rx_fifo_v3tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of wr_rx_fifo_v3tb is
	constant clk0_period   : time := 10 ns;
	constant clk1_period   : time := 10 ns; 
  --signals
  
  signal data_h : std_logic_vector(12 downto 0);
  signal data_l : std_logic_vector(12 downto 0); 
	signal clk0,clk1		: std_logic;
	signal reset_n : std_logic; 

  
  -- tb componets
  
  signal fr_start   : std_logic:='1';
  signal mimo_en    : std_logic:='0';
 	signal ch_en      : std_logic_vector(1 downto 0):="11";
 	
 	
 	signal fifo_wr    : std_logic;
 	signal diq        : std_logic_vector(23 downto 0);
 	signal diq_tx, fifo_q    : std_logic_vector(31 downto 0);
 	signal rdempty    : std_logic;
 	signal fifo_read  : std_logic; 
 	signal diq_h : std_logic_vector(15 downto 0); 
 	signal diq_l : std_logic_vector(15 downto 0);  
 	
 	
 	component fifo_inst is
  generic(dev_family	     : string  := "Cyclone IV E";
          wrwidth         : integer := 24;
          wrusedw_witdth  : integer := 12; --12=2048 words 
          rdwidth         : integer := 48;
          rdusedw_width   : integer := 11;
          show_ahead      : string  := "ON"
  );  

  port (
      --input ports 
      reset_n       : in std_logic;
      wrclk         : in std_logic;
      wrreq         : in std_logic;
      data          : in std_logic_vector(wrwidth-1 downto 0);
      wrfull        : out std_logic;
		wrempty		  : out std_logic;
      wrusedw       : out std_logic_vector(wrusedw_witdth-1 downto 0);
      rdclk 	     : in std_logic;
      rdreq         : in std_logic;
      q             : out std_logic_vector(rdwidth-1 downto 0);
      rdempty       : out std_logic;
      rdusedw       : out std_logic_vector(rdusedw_width-1 downto 0)     



      --output ports 
        
        );
end component;

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
	
		  -- design under test  
	  dut: entity work.test_data_dd
	  port map 
	(
        clk       => clk0, 
        reset_n   => reset_n,
		    fr_start	 => fr_start,
		    mimo_en   => mimo_en,
		  
		    data_h		  => data_h, 
		    data_l		  => data_l    

  );
  
  dut2 : entity work.wr_rx_fifo_v3
    generic map (sample_wdth => 12)
  port map (
        --input ports 
			clk			     => clk0, 
			reset_n   	=> reset_n,
			fr_start		 => fr_start,
			mimo_en		  => mimo_en,
			ch_en			   => ch_en, 
			en				   => reset_n,
			diq_h			   => data_h, 
			diq_l			   => data_l, 
			diq			     => diq, 
			fifo_wr		  => fifo_wr, 
			fifo_wfull	=> '0'
        );
        
        
        
 fifo :  fifo_inst 
  generic map (
			dev_family	    => "Cyclone IV", 
			wrwidth         => 32, 
			wrusedw_witdth  => 10, 
			rdwidth         => 32, 
			rdusedw_width   => 10,
			show_ahead      => "ON"
  )  
  port map (
      --input ports 
      reset_n       => reset_n, 
      wrclk         => clk0,
      wrreq         => fifo_wr,
      data          => diq_tx, 
      wrfull        => open,
		  wrempty		     => open, 
      wrusedw       => open,
      rdclk 	       => clk1,
      rdreq         => fifo_read,
      q             => fifo_q,
      rdempty       => rdempty,
      rdusedw       => open    		
        );
        
diq_tx<="0000" & diq(23 downto 12) & "0000" & diq(11 downto 0);


txfifo_rd : entity work.rd_tx_fifo 
  generic map (sampl_width => 12)
  port map(
        --input ports 
      clk		       => clk1, 
      reset_n     => reset_n,
      fr_start    => fr_start,
      ch_en			    => ch_en, 
      mimo_en		   => mimo_en, 
      fifo_empty	 => rdempty,
      fifo_data	  => fifo_q,
		--output ports 
      fifo_read	  => fifo_read, 
      diq_h			    => diq_h, 
      diq_l			    => diq_l
        );
        
dd : entity work.lms7002_ddout 
 	generic map ( dev_family	=> "Cyclone IV E",
				        iq_width		=> 12
	)
	port map(
      --input ports 
      clk       	=> clk1,
      reset_n   	=> reset_n, 
		  data_in_h	 => diq_l(12 downto 0),
		  data_in_l	 => diq_h(12 downto 0),
		--output ports 
		  txiq		 	   => open, 
		  txiqsel	 	 => open 
		
        );
        
        
	
	end tb_behave;
  
  


  