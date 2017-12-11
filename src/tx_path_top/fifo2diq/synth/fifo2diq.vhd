-- ----------------------------------------------------------------------------	
-- FILE: 	fifo2diq.vhd
-- DESCRIPTION:	Writes DIQ data to FIFO, FIFO word size = 4  DIQ samples 
-- DATE:	Jan 13, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity fifo2diq is
   generic( 
      dev_family           : string := "Cyclone IV E";
      iq_width             : integer := 12
      );
   port (
      clk                  : in std_logic;
      reset_n              : in std_logic;
      --Mode settings
      mode                 : in std_logic; -- JESD207: 1; TRXIQ: 0
      trxiqpulse           : in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
      ddr_en               : in std_logic; -- DDR: 1; SDR: 0
      mimo_en              : in std_logic; -- SISO: 1; MIMO: 0
      ch_en                : in std_logic_vector(1 downto 0); --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
      fidm                 : in std_logic; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      pct_sync_mode        : in std_logic; -- 0 - timestamp, 1 - external pulse 
      pct_sync_pulse       : in std_logic; -- external packet synchronisation pulse signal
      pct_sync_size        : in std_logic_vector(15 downto 0); -- valid in external pulse mode only
      pct_buff_rdy         : in std_logic;
      --txant
      txant_cyc_before_en  : in std_logic_vector(15 downto 0); -- valid in external pulse sync mode only
      txant_cyc_after_en   : in std_logic_vector(15 downto 0); -- valid in external pulse sync mode only 
      txant_en             : out std_logic;                 
      --Tx interface data 
      DIQ                  : out std_logic_vector(iq_width-1 downto 0);
      fsync                : out std_logic;
      DIQ_h                : out std_logic_vector(iq_width downto 0);
      DIQ_l                : out std_logic_vector(iq_width downto 0);
      --fifo ports 
      fifo_rdempty         : in std_logic;
      fifo_rdreq           : out std_logic;
      fifo_q               : in std_logic_vector(iq_width*4-1 downto 0) 

        );
end fifo2diq;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of fifo2diq is
--declare signals,  components here
signal inst0_DIQ_h         : std_logic_vector (iq_width downto 0); 
signal inst0_DIQ_l         : std_logic_vector (iq_width downto 0);
--inst1 signals
signal inst1_fifo_rdreq    : std_logic;
signal inst1_txant_en      : std_logic;
--inst3 signals
signal inst3_txiq_en       : std_logic;
signal inst3_pct_sync_size : std_logic_vector(15 downto 0);
signal inst3_txant_en      : std_logic;

signal int_mode            : std_logic_vector(1 downto 0);

signal txant_en_mux        : std_logic;
  
begin
   
   -- ----------------------------------------------------------------------------
--Internal mode selection for DIQ position
-- "00" - MIMO DDR both channels enabled, SISO DDR, TXIQ_PULSE
-- "01" - MIMO DDR, TXIQ_PULSE first channel enabled
-- "10" - MIMO DDR, TXIQ_PULSE second channel enabled
-- "11" - SISO SDR 
-- ----------------------------------------------------------------------------
 int_mode <= "00" when (mimo_en='0' AND ddr_en='1') OR ((mimo_en='1' OR trxiqpulse ='1') AND ch_en="11") else 
             "01" when ((mimo_en='1' OR trxiqpulse ='1') AND ch_en="01") else
             "10" when ((mimo_en='1' OR trxiqpulse ='1') AND ch_en="10") else
             "11";

process(clk, reset_n)
begin
   if reset_n = '0' then 
      inst3_pct_sync_size <= (others=> '0');
   elsif (clk'event AND clk='1') then 
      if  int_mode = "00" then 
         inst3_pct_sync_size <= pct_sync_size;
      else 
         inst3_pct_sync_size <= '0' & pct_sync_size(15 downto 1); 
      end if;
   end if;
end process;

        
inst0_lms7002_dout : entity work.lms7002_ddout
   generic map( 
      dev_family  => dev_family,
      iq_width    => iq_width
   )
   port map(
      clk         => clk,
      reset_n     => reset_n,
      data_in_h   => inst0_DIQ_h,
      data_in_l   => inst0_DIQ_l,
      txiq        => DIQ,
      txiqsel     => fsync
      );
        
        
 inst1_txiq : entity work.txiq
   generic map( 
      dev_family     => dev_family,
      iq_width       => iq_width
   )
   port map (
      clk            => clk,
      reset_n        => reset_n,
      en             => inst3_txiq_en,
      trxiqpulse     => trxiqpulse,
      ddr_en         => ddr_en,
      mimo_en        => mimo_en,
      ch_en          => ch_en, 
      fidm           => fidm,
      DIQ_h          => inst0_DIQ_h,
      DIQ_l          => inst0_DIQ_l,
      fifo_rdempty   => fifo_rdempty,
      fifo_rdreq     => inst1_fifo_rdreq,
      fifo_q         => fifo_q,
      txant_en       => inst1_txant_en
        );
        
txiq_ctrl_inst3 : entity work.txiq_ctrl
   port map(
      clk                  => clk,
      reset_n              => reset_n,
      --Mode settings
      pct_sync_mode        => pct_sync_mode,
      pct_sync_pulse       => pct_sync_pulse,
      pct_sync_size        => inst3_pct_sync_size,
      pct_buff_rdy         => pct_buff_rdy,
      txiq_rdreq_in        => inst1_fifo_rdreq,
      txiq_en              => inst3_txiq_en,
      txant_cyc_before_en  => txant_cyc_before_en,
      txant_cyc_after_en   => txant_cyc_after_en,
      txant_en             => inst3_txant_en
        );
        
process(clk, reset_n)
begin
   if reset_n = '0' then 
      txant_en_mux <= '0';
   elsif (clk'event AND clk='1') then 
      if  pct_sync_mode = '0' then 
         txant_en_mux <= inst1_txant_en;
      else 
         txant_en_mux <= inst3_txant_en; 
      end if;
   end if;
end process;



txant_en    <= txant_en_mux;
fifo_rdreq  <= inst1_fifo_rdreq;
DIQ_h       <= inst0_DIQ_h;
DIQ_l       <= inst0_DIQ_l;

  
end arch;