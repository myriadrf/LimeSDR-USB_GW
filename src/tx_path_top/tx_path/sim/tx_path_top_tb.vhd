-- ----------------------------------------------------------------------------	
-- FILE: 	tx_path_top_tb.vhd
-- DESCRIPTION:	
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_TEXTIO.ALL;
use STD.textio.all;
use work.FIFO_PACK.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity tx_path_top_tb is
end tx_path_top_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of tx_path_top_tb is
   -- TB parameters
   constant C_DEV_FAMILY         : string := "Cyclone IV E";
   constant clk0_period          : time := 16 ns;     -- RX clk,
   constant clk1_period          : time := 10 ns;     -- Transfer clk, 100MHz, 400MBs 
   constant clk2_period          : time := 16 ns;     -- TX clk, 
   --signals   
   signal clk0,clk1,clk2         : std_logic;
   signal reset_n                : std_logic; 
   
   
   -- Data packet parameters
   constant C_STREAM_PCT_SIZE    : integer := 4096;   -- Stream packet size in bytes
   constant C_STREAM_PCT_HDR_SIZE: integer := 16;
   -- File reading 
   constant C_FILE_RDATA_WIDTH   : integer := 64;     -- File data format
   signal file_rdreq             : std_logic;
   signal file_rdata             : std_logic_vector(C_FILE_RDATA_WIDTH-1 downto 0);
   
   constant C_SMPL_NR_START      : integer := 3400;
   
   signal sample_width     : std_logic_vector(1 downto 0) := "10"; 
   signal mode             : std_logic:='0'; -- JESD207: 1; TRXIQ: 0
   signal trxiqpulse       : std_logic:='0'; -- trxiqpulse on: 1; trxiqpulse off: 0
   signal ddr_en           : std_logic:='1'; -- DDR: 1; SDR: 0
   signal mimo_en          : std_logic:='1'; -- MIMO: 1; SISO: 0
   signal ch_en            : std_logic_vector(1 downto 0):="01"; --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
   signal fidm             : std_logic:='0'; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
   signal inst1_pct_sync_mode    : std_logic := '0'; --0 - timestamp, 1 - external pulse 
   signal inst1_pct_sync_size    : std_logic_vector(15 downto 0) := x"03FC"; -- valid in external pulse mode only
   signal txant_cyc_before_en    : std_logic_vector(15 downto 0) := x"0001";
   signal txant_cyc_after_en     : std_logic_vector(15 downto 0) := x"0001";

   --ins0 signals
   constant C_INST0_RDWIDTH         : integer := 128; -- Can not be changed
   constant C_INST0_WRUSEDW_WIDTH   : integer := FIFO_WORDS_TO_Nbits((C_STREAM_PCT_SIZE*8)/C_FILE_RDATA_WIDTH, true);
   constant C_INST0_RDUSEDW_WIDTH   : integer := FIFO_WORDS_TO_Nbits((C_STREAM_PCT_SIZE*8)/C_INST0_RDWIDTH, true);
   signal inst0_fifo_wrreq          : std_logic;
   signal inst0_wrempty             : std_logic;
   signal inst0_rdempty             : std_logic;
   signal inst0_rdusedw             : std_logic_vector(C_INST0_RDUSEDW_WIDTH-1 downto 0);
   signal inst0_q                   : std_logic_vector(C_INST0_RDWIDTH-1 downto 0);
   
   --inst1
   signal rx_sample_nr        : std_logic_vector(63 downto 0);
   signal rx_sample_nr_en     : std_logic;
   signal inst1_pct_sync_dis  : std_logic := '0';
   signal inst1_in_pct_rdy    : std_logic;
   signal inst1_in_pct_rdreq  : std_logic;
   signal inst1_in_pct_reset_n_req  : std_logic;
   
   --inst2
   signal inst2_pct_sync_pulse   : std_logic;
   signal inst2_wait_cycles      : std_logic_vector(31 downto 0) := x"0000186A";
   
   signal rd_pct              : std_logic;
   signal rd_pct_cnt          : unsigned(31 downto 0);
   signal pct_data            : std_logic_vector(63 downto 0);
   
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
   
     clock2: process is
   begin
      clk2 <= '0'; wait for clk2_period/2;
      clk2 <= '1'; wait for clk2_period/2;
   end process clock2;
   
      res: process is
   begin
      reset_n <= '0'; wait for 20 ns;
      --report "reset_n released" severity failure ;     
      reset_n <= '1'; wait;
   end process res;

-- ----------------------------------------------------------------------------
-- RX sample Nr. generation
-- ----------------------------------------------------------------------------    
process(clk0, reset_n)
begin
   if reset_n = '0' then 
      rx_sample_nr_en <= '0';
      rx_sample_nr <= std_logic_vector(to_unsigned(C_SMPL_NR_START,64));
   elsif (clk0'event AND clk0='1') then 
      rx_sample_nr_en <= not rx_sample_nr_en;
      if rx_sample_nr_en = '1' then 
         rx_sample_nr <= std_logic_vector(unsigned(rx_sample_nr)+1);
      else 
         rx_sample_nr <= rx_sample_nr;
      end if;
   end if;
end process;
  
-- ----------------------------------------------------------------------------
-- TEST data generation. 
-- Test data is read from external file and written to FIFO. Simulating data
-- coming from PC or ect.
-- ----------------------------------------------------------------------------

   -- File read request generation. Data is read from file in full packets when 
   -- FIFO is empty.
   file_rdreq_proc : process 
   begin
      file_rdreq <= '0';
      wait until rising_edge(clk1) AND reset_n = '1';
         for i in 0 to (C_STREAM_PCT_SIZE*8)/C_FILE_RDATA_WIDTH - 1 loop
            file_rdreq <= '1';
            wait until rising_edge(clk1);
         end loop;
         file_rdreq <= '0';
         wait until inst0_wrempty = '1';
         wait until rising_edge(clk1);
   end process;

   -- File read process
   file_rd_prc : process(clk1, reset_n)
      --select one of the three files depending on sample width
      FILE in_file      : TEXT OPEN READ_MODE IS "sim/out_pct_6_12b";
      --FILE in_file      : TEXT OPEN READ_MODE IS "sim/out_pct_6_14b";
      --FILE in_file      : TEXT OPEN READ_MODE IS "sim/out_pct_6_16b";   
      VARIABLE in_line  : LINE;
      VARIABLE data     : std_logic_vector(63 downto 0);
   begin
      if reset_n = '0' then 
         file_rdata <= (others=>'0');
      elsif (clk1'event AND clk1='1') then 
         if file_rdreq = '1' then 
            READLINE(in_file, in_line);
            HREAD(in_line, data);
            file_rdata <= data;
         else 
            file_rdata <= file_rdata;
         end if;
   
      end if;
   end process;
   
   -- FIFO write request signal
   fifo_wr_proc : process(clk1, reset_n)
   begin
      if reset_n = '0' then 
         inst0_fifo_wrreq <= '0';
      elsif (clk1'event AND clk1='1') then 
         inst0_fifo_wrreq <= file_rdreq;
      end if;
   end process;

-- ----------------------------------------------------------------------------
-- Packet data placed to FIFO for resizing bus width and clock domain crossing
-- ----------------------------------------------------------------------------
   fifo_inst_isnt0 : entity work.fifo_inst
   generic map(
      dev_family      => C_DEV_FAMILY,
      wrwidth         => C_FILE_RDATA_WIDTH,
      wrusedw_witdth  => C_INST0_WRUSEDW_WIDTH,
      rdwidth         => C_INST0_RDWIDTH,
      rdusedw_width   => C_INST0_RDUSEDW_WIDTH,
      show_ahead      => "OFF"
   ) 
   port map(
      --input ports 
      reset_n       => inst1_in_pct_reset_n_req,
      wrclk         => clk1,
      wrreq         => inst0_fifo_wrreq,
      data          => file_rdata,
      wrfull        => open,
      wrempty       => inst0_wrempty,
      wrusedw       => open,
      rdclk         => clk2,
      rdreq         => inst1_in_pct_rdreq,
      q             => inst0_q,
      rdempty       => inst0_rdempty,
      rdusedw       => inst0_rdusedw          
   );
   
   -- inst1_in_pct_rdy is asserted when full packet is placed to FIFO
   process(clk2, reset_n)
   begin
      if reset_n = '0' then 
         inst1_in_pct_rdy <= '0';
      elsif (clk2'event AND clk2='1') then 
         if unsigned(inst0_rdusedw) < (C_STREAM_PCT_SIZE*8)/C_INST0_RDWIDTH then
            inst1_in_pct_rdy <= '0';
         else 
            inst1_in_pct_rdy <= '1';
         end if;
      end if;
   end process;    

-- ----------------------------------------------------------------------------
-- tx_path_top module instance
-- ----------------------------------------------------------------------------
   tx_path_top_inst1 : entity work.tx_path_top
   generic map( 
      dev_family           => "Cyclone IV E",
      iq_width             => 12,
      TX_IN_PCT_SIZE       => C_STREAM_PCT_SIZE,
      TX_IN_PCT_HDR_SIZE   => C_STREAM_PCT_HDR_SIZE,
      pct_size_w           => 16,
      n_buff               => 4,
      in_pct_data_w        => 128,
      out_pct_data_w       => 64,
      decomp_fifo_size     => 9
      )
   port map(
      pct_wrclk            => clk2,
      iq_rdclk             => clk2,
      reset_n              => reset_n,
      en                   => reset_n,

      rx_sample_clk        => clk0,
      rx_sample_nr         => rx_sample_nr,

      pct_sync_mode        => inst1_pct_sync_mode,
      pct_sync_dis         => inst1_pct_sync_dis,
      pct_sync_pulse       => inst2_pct_sync_pulse,
      pct_sync_size        => inst1_pct_sync_size,
      pct_loss_flg         => open,
      pct_loss_flg_clr     => '0',
      
      txant_cyc_before_en  => txant_cyc_before_en,
      txant_cyc_after_en   => txant_cyc_after_en,
      txant_en             => open,
      

      mode                 => mode,
      trxiqpulse           => trxiqpulse,
      ddr_en               => ddr_en,
      mimo_en              => mimo_en,
      ch_en                => ch_en,
      fidm                 => fidm,
      sample_width         => sample_width,

      DIQ                  => open,
      fsync                => open,
      
      in_pct_reset_n_req   => inst1_in_pct_reset_n_req,
      in_pct_rdreq         => inst1_in_pct_rdreq,
      in_pct_data          => inst0_q,
      in_pct_rdy           => inst1_in_pct_rdy
   );
        
pulse_gen_inst2 : entity work.pulse_gen
   port map(
      clk         => clk2,
      reset_n     => reset_n,
      wait_cycles => inst2_wait_cycles,
      pulse       => inst2_pct_sync_pulse
   );

 
	end tb_behave;
  
  


  
