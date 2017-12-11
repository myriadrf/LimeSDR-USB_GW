-- ----------------------------------------------------------------------------	
-- FILE: 	rx_path_top_tb.vhd
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

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity tx_path_top_tb is
end tx_path_top_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of tx_path_top_tb is
   constant clk0_period    : time := 16 ns;   --RX clk, ~180MBs
   constant clk1_period    : time := 10 ns;     --Transfer clk, 100MHz, 400MBs 
   constant clk2_period    : time := 16 ns;   --TX clk, 
   --signals
   signal clk0,clk1,clk2   : std_logic;
   signal reset_n          : std_logic; 
   
   constant smpl_nr_delay  : integer := 1030;
   
   signal sample_width     : std_logic_vector(1 downto 0) := "00"; 
   signal mode             : std_logic:='0'; -- JESD207: 1; TRXIQ: 0
   signal trxiqpulse       : std_logic:='0'; -- trxiqpulse on: 1; trxiqpulse off: 0
   signal ddr_en           : std_logic:='0'; -- DDR: 1; SDR: 0
   signal mimo_en          : std_logic:='0'; -- MIMO: 1; SISO: 0
   signal ch_en            : std_logic_vector(1 downto 0):="11"; --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
   signal fidm             : std_logic:='0'; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
   signal inst1_pct_sync_mode    : std_logic := '1'; --0 - timestamp, 1 - external pulse 
   signal inst1_pct_sync_size    : std_logic_vector(15 downto 0) := x"03FC"; -- valid in external pulse mode only
   signal txant_cyc_before_en    : std_logic_vector(15 downto 0) := x"0001";
   signal txant_cyc_after_en     : std_logic_vector(15 downto 0) := x"0001";

   -- Data to BB
   signal inst0_DIQ           : std_logic_vector(11 downto 0);
   signal inst0_fsync         : std_logic; --Frame start

   --ins0 signals
   signal inst0_fifo_wrreq    : std_logic;
   signal inst0_rdempty       : std_logic;
   signal inst0_rdreq         : std_logic;
   signal inst0_q             : std_logic_vector(31 downto 0);
   
   --inst1
   signal inst1_in_pct_wrreq  : std_logic;
   signal inst1_in_pct_full   : std_logic;
   signal inst1_in_pct_data   : std_logic_vector(31 downto 0);
   signal rx_sample_nr        : std_logic_vector(63 downto 0);
   signal rx_sample_nr_en     : std_logic;
   signal inst1_pct_sync_dis  : std_logic := '1';
   
   --inst2
   signal inst2_pct_sync_pulse   : std_logic;
   signal inst2_wait_cycles      : std_logic_vector(31 downto 0) := x"0000186A";
   


   
   signal rd_pct              : std_logic;
   signal rd_pct_cnt          : unsigned(31 downto 0);
   signal rd_pct_cnt_max      : unsigned(31 downto 0) := (to_unsigned(3072,32));
   signal pct_data            : std_logic_vector(63 downto 0);
   
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
   
     clock2: process is
   begin
      clk2 <= '0'; wait for clk2_period/2;
      clk2 <= '1'; wait for clk2_period/2;
   end process clock2;
   
      res: process is
   begin
      reset_n <= '0'; wait for 20 ns;
      report "reset_n released" severity failure ;     
      reset_n <= '1'; wait;
   end process res;
   
   --inst1_in_pct_full <= '0';


-- ----------------------------------------------------------------------------
-- RX sample Nr. generation
-- ----------------------------------------------------------------------------    
process(clk2, reset_n)
begin
   if reset_n = '0' then 
      rx_sample_nr_en <= '0';
      rx_sample_nr <= (others => '0');
   elsif (clk2'event AND clk2='1') then 
      rx_sample_nr_en <= not rx_sample_nr_en;
      if rx_sample_nr_en = '1' then 
         rx_sample_nr <= std_logic_vector(unsigned(rx_sample_nr)+1);
      else 
         rx_sample_nr <= rx_sample_nr;
      end if;
   end if;
end process;


process(clk2, reset_n)
   begin
      if reset_n = '0' then 
         smpl_nr_array <= (others=>(others=>'0'));
      elsif (clk2'event AND clk2='1') then 
         for i in 0 to smpl_nr_delay-1 loop
            if i = 0 then 
               smpl_nr_array(0) <= rx_sample_nr;
            else 
               smpl_nr_array(i) <= smpl_nr_array(i-1);
            end if;
         end loop;
      end if;
   end process;
   
   
process(clk0, reset_n)
   begin
      if reset_n = '0' then 
         rd_pct         <= '0';
         inst0_fifo_wrreq <= '0';
      elsif (clk0'event AND clk0='1') then
         --if inst1_in_pct_full = '0' then
         if rd_pct_cnt < rd_pct_cnt_max-1 then 
            rd_pct <= '1';
            --rd_pct <= NOT rd_pct;
         else 
            rd_pct <= '0';
         end if;
         inst0_fifo_wrreq <= rd_pct;
      end if;
   end process;
   
   process(clk0, reset_n)
   begin
      if reset_n = '0' then 
         rd_pct_cnt <= (others => '0');
      elsif (clk0'event AND clk0='1') then 
         if rd_pct = '1' then 
            rd_pct_cnt <= rd_pct_cnt +1;
         end if;
      end if;
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
      pct_data <= (others=>'0');
   elsif (clk0'event AND clk0='1') then 
      if rd_pct = '1' then 
         READLINE(in_file, in_line);
         HREAD(in_line, data);
         pct_data <= data;
      else 
         pct_data <= pct_data;
      end if;

   end if;
end process;

-- ----------------------------------------------------------------------------
-- Packet data placed to FIFO for resizing bus width
-- ----------------------------------------------------------------------------
inst0_rdreq <= NOT inst0_rdempty;
fifo_inst_isnt0 : entity work.fifo_inst
      generic map(
         dev_family      =>  "Cyclone IV E",
         wrwidth         => 64,
         wrusedw_witdth  => 18,
         rdwidth         => 32,
         rdusedw_width   => 19,
         show_ahead      => "OFF"
      ) 
      port map(
         --input ports 
         reset_n       => reset_n,
         wrclk         => clk0,
         wrreq         => inst0_fifo_wrreq,
         data          => pct_data,
         wrfull        => open,
         wrempty       => open,
         wrusedw       => open,
         rdclk         => clk1,
         rdreq         => inst0_rdreq,
         q             => inst0_q,
         rdempty       => inst0_rdempty,
         rdusedw       => open          
         );

inst1_in_pct_data <= inst0_q;



   
process(clk1, reset_n)
   begin
      if reset_n = '0' then 
         inst1_in_pct_wrreq <= '0';
      elsif (clk1'event AND clk1='1') then 
         inst1_in_pct_wrreq   <= inst0_rdreq;   
      end if;
   end process;    
    
tx_path_top_inst0 : entity work.tx_path_top
   generic map( 
      dev_family           => "Cyclone IV E",
      iq_width             => 12,
      pct_size_w           => 16,
      n_buff               => 4,
      in_pct_data_w        => 32,
      out_pct_data_w       => 64,
      decomp_fifo_size     => 9
      )
   port map(
      pct_wrclk            => clk1,
      iq_rdclk             => clk2,
      reset_n              => reset_n,
      en                   => reset_n,

      rx_sample_clk        => clk2,
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

      in_pct_wrreq         => inst1_in_pct_wrreq,
      in_pct_data          => inst1_in_pct_data,
      in_pct_full          => inst1_in_pct_full
        );
        
pulse_gen_inst2 : entity work.pulse_gen
   port map(
      clk         => clk2,
      reset_n     => reset_n,
      wait_cycles => inst2_wait_cycles,
      pulse       => inst2_pct_sync_pulse
   );



	end tb_behave;
  
  


  
