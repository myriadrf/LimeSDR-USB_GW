-- ----------------------------------------------------------------------------	
-- FILE: 	tx_path_top.vhd
-- DESCRIPTION:	describe file
-- DATE:	March 27, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.general_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity tx_path_top is
   generic( 
      g_DEV_FAMILY         : string := "Cyclone IV E";
      g_IQ_WIDTH           : integer := 12;
      g_PCT_MAX_SIZE       : integer := 4096; -- TX packet size in bytes
      g_PCT_HDR_SIZE       : integer := 16;
      g_BUFF_COUNT         : integer := 4; -- 2,4 valid values
      g_FIFO_DATA_W        : integer := 128
      );
   port (
      pct_wrclk            : in std_logic;
      iq_rdclk             : in std_logic;
      reset_n              : in std_logic;
      en                   : in std_logic;
      
      rx_sample_clk        : in std_logic;
      rx_sample_nr         : in std_logic_vector(63 downto 0);
      
      pct_sync_mode        : in std_logic := '1'; -- 0 - timestamp, 1 - external pulse 
      pct_sync_dis         : in std_logic;
      pct_sync_pulse       : in std_logic; -- external packet synchronisation pulse signal
      pct_sync_size        : in std_logic_vector(15 downto 0):=x"03FC"; -- valid in external pulse mode only
            
      pct_loss_flg         : out std_logic;
      pct_loss_flg_clr     : in std_logic;
      
      --txant
      txant_cyc_before_en  : in std_logic_vector(15 downto 0) := x"0001";
      txant_cyc_after_en   : in std_logic_vector(15 downto 0) := x"0001";
      txant_en             : out std_logic;
      
      --Mode settings
      mode                 : in std_logic; -- JESD207: 1; TRXIQ: 0
      trxiqpulse           : in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
      ddr_en               : in std_logic; -- DDR: 1; SDR: 0
      mimo_en              : in std_logic; -- SISO: 1; MIMO: 0
      ch_en                : in std_logic_vector(1 downto 0); --"11" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
      fidm                 : in std_logic; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      sample_width         : in std_logic_vector(1 downto 0); --"10"-12bit, "01"-14bit, "00"-16bit;
      --Tx interface data 
      DIQ                  : out std_logic_vector(g_IQ_WIDTH-1 downto 0);
      fsync                : out std_logic;
      DIQ_h                : out std_logic_vector(g_IQ_WIDTH downto 0);
      DIQ_l                : out std_logic_vector(g_IQ_WIDTH downto 0);
      --FIFO ports
      fifo_rdreq           : out std_logic;
      fifo_data            : in std_logic_vector(g_FIFO_DATA_W-1 downto 0);
      fifo_rdempty         : in std_logic
      );
end tx_path_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of tx_path_top is
--declare signals,  components here

signal reset_n_sync_iq_rdclk        : std_logic;

signal rx_sample_nr_iq_rdclk        : std_logic_vector(63 downto 0);
signal en_sync_rx_sample_clk        : std_logic;
signal en_sync_iq_rdclk             : std_logic;
signal pct_loss_flg_clr_sync_iq_rdclk : std_logic;
signal pct_loss_flg_clr_sync_iq_rdclk_reg : std_logic;

signal mode_sync_iq_rdclk           : std_logic;
signal trxiqpulse_sync_iq_rdclk     : std_logic; 
signal ddr_en_sync_iq_rdclk         : std_logic;
signal mimo_en_sync_iq_rdclk        : std_logic;
signal fidm_sync_iq_rdclk           : std_logic;
signal ch_en_sync_iq_rdclk          : std_logic_vector(1 downto 0);
signal sample_width_sync_iq_rdclk   : std_logic_vector(1 downto 0);

--inst0
signal inst0_reset_n                : std_logic;
signal inst0_pct_rdy                : std_logic;
signal inst0_pct_header             : std_logic_vector(127 downto 0);
signal inst0_pct_data               : std_logic_vector(127 downto 0);
signal inst0_pct_data_rdempty       : std_logic;

--inst1
signal inst1_smpl_buff_rdempty      : std_logic;
signal inst1_smpl_buff_wrfull       : std_logic;
signal inst1_smpl_buff_q            : std_logic_vector(63 downto 0);
signal inst1_pct_size               : std_logic_vector(15 downto 0);
signal inst1_in_pct_clr_flag        : std_logic;
signal inst1_in_pct_clr_flag_reg    : std_logic;
signal inst1_in_pct_buff_rdy        : std_logic_vector(g_BUFF_COUNT-1 downto 0);
signal inst1_in_pct_reset_n_req     : std_logic;
signal inst1_in_pct_rdreq           : std_logic;

--inst2
signal inst2_fifo_rdreq             : std_logic;
signal inst2_fifo_q                 : std_logic_vector(47 downto 0);
signal inst2_pct_buff_rdy           : std_logic;

signal pct_loss_flg_int             : std_logic;

signal pct_sync_num_of_packets      : std_logic_vector(2 downto 0);
signal pct_sync_num_of_packets_12b  : std_logic_vector(2 downto 0);
signal pct_sync_num_of_packets_16b  : std_logic_vector(2 downto 0);
signal pct_sync_num_of_rdy_packets  : unsigned(2 downto 0);
signal pct_rdy_combined_vect        : std_logic_vector(g_BUFF_COUNT downto 0);






begin

--Synchronization registers for asynchronous input ports
sync_reg0 : entity work.sync_reg 
port map(rx_sample_clk, '1', en, en_sync_rx_sample_clk);

sync_reg1 : entity work.sync_reg 
port map(iq_rdclk, '1', en, en_sync_iq_rdclk);

sync_reg2 : entity work.sync_reg 
 port map(iq_rdclk, '1', mode, mode_sync_iq_rdclk);

sync_reg3 : entity work.sync_reg 
 port map(iq_rdclk, '1', trxiqpulse, trxiqpulse_sync_iq_rdclk);
 
sync_reg4 : entity work.sync_reg 
 port map(iq_rdclk, '1', ddr_en, ddr_en_sync_iq_rdclk);
 
sync_reg5 : entity work.sync_reg 
 port map(iq_rdclk, '1', mimo_en, mimo_en_sync_iq_rdclk);
 
sync_reg6 : entity work.sync_reg 
 port map(iq_rdclk, '1', fidm, fidm_sync_iq_rdclk);

sync_reg7 : entity work.sync_reg 
 port map(iq_rdclk, '1', pct_loss_flg_clr, pct_loss_flg_clr_sync_iq_rdclk);

sync_reg8 : entity work.sync_reg 
 port map(iq_rdclk, '1', reset_n, reset_n_sync_iq_rdclk); 
 
 
bus_sync_reg0 : entity work.bus_sync_reg
 generic map (2) 
 port map(iq_rdclk, '1', ch_en, ch_en_sync_iq_rdclk);

bus_sync_reg1 : entity work.bus_sync_reg
 generic map (2) 
 port map(iq_rdclk, '1', sample_width, sample_width_sync_iq_rdclk); 
 

--to determine required number of buffers
process(iq_rdclk, reset_n)
begin
   if reset_n = '0' then
      pct_sync_num_of_packets_12b   <= (others => '0');
      pct_sync_num_of_packets_16b   <= (others => '0');
      pct_sync_num_of_packets       <= (others => '0');
   elsif (iq_rdclk'event AND iq_rdclk = '1') then
   
      --to determine required number of buffers when sample_width = 12bit
      if unsigned(pct_sync_size) > 0 AND unsigned(pct_sync_size) < 1361 then
         pct_sync_num_of_packets_12b <= "000";
      elsif unsigned(pct_sync_size) > 1360 AND unsigned(pct_sync_size) < 2721 then 
         pct_sync_num_of_packets_12b <= "001";
      elsif unsigned(pct_sync_size) > 2720 AND unsigned(pct_sync_size) < 4081 then
         pct_sync_num_of_packets_12b <= "010";
      else 
         pct_sync_num_of_packets_12b <= "011";         
      end if;
      
      --to determine required number of buffers when sample_width = 16bit
      if unsigned(pct_sync_size) > 0 AND unsigned(pct_sync_size) < 1021 then
         pct_sync_num_of_packets_16b <= "000";
      elsif unsigned(pct_sync_size) > 1020 AND unsigned(pct_sync_size) < 2041 then 
         pct_sync_num_of_packets_16b <= "001";
      elsif unsigned(pct_sync_size) > 2040 AND unsigned(pct_sync_size) < 3061 then
         pct_sync_num_of_packets_16b <= "010";
      else 
         pct_sync_num_of_packets_16b <= "011";         
      end if;
           
      --mux
      if sample_width_sync_iq_rdclk = "10" then 
         pct_sync_num_of_packets <= pct_sync_num_of_packets_12b;
      else 
         pct_sync_num_of_packets <= pct_sync_num_of_packets_16b;
      end if;
            
   end if;
end process;


--count number of buffers that are ready with data
process(iq_rdclk, reset_n)
begin
   if reset_n = '0' then 
      pct_sync_num_of_rdy_packets <= (others => '0');
   elsif (iq_rdclk'event AND iq_rdclk='1') then 
      pct_sync_num_of_rdy_packets <= to_unsigned(COUNT_ONES(inst1_in_pct_buff_rdy), 3);
   end if; 
end process;

--inst2_pct_buff_rdy signal formation for fifo2diq module
process(iq_rdclk, reset_n)
begin
   if reset_n = '0' then 
      inst2_pct_buff_rdy <= '0';
   elsif (iq_rdclk'event AND iq_rdclk = '1') then
      if inst1_smpl_buff_wrfull = '1' then 
         if pct_sync_num_of_rdy_packets >= unsigned(pct_sync_num_of_packets)then 
            inst2_pct_buff_rdy <= '1';
         else 
            inst2_pct_buff_rdy <= '0';
         end if;
      else 
         inst2_pct_buff_rdy <= '0';
      end if;
   end if;
end process;


process(sample_width)
begin
      if sample_width = "01" then 
         inst1_pct_size <= x"0100";
      else 
         inst1_pct_size <= x"0400";
      end if;
end process;

-- reset_n_sync_iq_rdclk is delayed two cycles, this helps awoid throwing 
-- pct_loss_flg_int on reset_n at stream start 
 process(iq_rdclk, reset_n_sync_iq_rdclk)
 begin
   if reset_n_sync_iq_rdclk = '0' then 
      pct_loss_flg_int           <= '0';
      inst1_in_pct_clr_flag_reg  <= '1';
      pct_loss_flg_clr_sync_iq_rdclk_reg <= '0';
   elsif (iq_rdclk'event AND iq_rdclk='1') then
      inst1_in_pct_clr_flag_reg <= inst1_in_pct_clr_flag;
      pct_loss_flg_clr_sync_iq_rdclk_reg <= pct_loss_flg_clr_sync_iq_rdclk;
      
      if inst1_in_pct_clr_flag = '1' AND inst1_in_pct_clr_flag_reg = '0' then 
         pct_loss_flg_int <= '1';
      elsif pct_loss_flg_clr_sync_iq_rdclk = '1' AND pct_loss_flg_clr_sync_iq_rdclk_reg = '0' then 
         pct_loss_flg_int <= '0';
      else 
         pct_loss_flg_int <= pct_loss_flg_int;
      end if;
   end if;
 end process;

pct_loss_flg<= pct_loss_flg_int;

-- ----------------------------------------------------------------------------
-- To synchronize rx_sample_nr to iq_rdclk clock domain
-- ----------------------------------------------------------------------------
sync_fifo_rw_inst : entity work.sync_fifo_rw
generic map( 
   dev_family  => g_DEV_FAMILY,
   data_w      => 64
  )
  port map(
        --input ports 
        wclk         => rx_sample_clk,      
        rclk         => iq_rdclk,
        reset_n      => reset_n,
        sync_en      => en_sync_rx_sample_clk,
        sync_data    => rx_sample_nr,
        sync_q       => rx_sample_nr_iq_rdclk
        );

inst0_one_pct_fifo : entity work.one_pct_fifo
   generic map(
      dev_family              => g_DEV_FAMILY,
      g_INFIFO_DATA_WIDTH     => g_FIFO_DATA_W,
      g_PCT_MAX_SIZE          => g_PCT_MAX_SIZE, -- Packet FIFO size in bytes
      g_PCT_HDR_SIZE          => g_PCT_HDR_SIZE,
      g_PCTFIFO_RDATA_WIDTH   => 128
   )
   port map(
      clk               => pct_wrclk,
      reset_n           => reset_n,
      infifo_rdreq      => fifo_rdreq,
      infifo_data       => fifo_data,
      infifo_rdempty    => fifo_rdempty,
      pct_rdclk         => pct_wrclk,
      pct_aclr_n        => inst1_in_pct_reset_n_req,
      pct_rdy           => inst0_pct_rdy,
      pct_header        => inst0_pct_header,
      pct_data_rdreq    => inst1_in_pct_rdreq,
      pct_data          => inst0_pct_data,
      pct_data_rdempty  => inst0_pct_data_rdempty
   ); 
        
-- ----------------------------------------------------------------------------
-- packets2data_top instance
-- ----------------------------------------------------------------------------
  packets2data_top_inst1 : entity work.packets2data_top
   generic map (
      g_DEV_FAMILY      => g_DEV_FAMILY,
      g_PCT_MAX_SIZE    => g_PCT_MAX_SIZE,    
      g_PCT_HDR_SIZE    => g_PCT_HDR_SIZE,
      g_BUFF_COUNT      => g_BUFF_COUNT, -- 2,4 valid values
      in_pct_data_w     => g_FIFO_DATA_W,
      out_pct_data_w    => 64
   )
   port map(

      wclk              => pct_wrclk,
      rclk              => iq_rdclk, 
      reset_n           => reset_n,
      
      mode              => mode_sync_iq_rdclk, 
      trxiqpulse        => trxiqpulse_sync_iq_rdclk,	
      ddr_en            => ddr_en_sync_iq_rdclk,
      mimo_en           => mimo_en_sync_iq_rdclk,	
      ch_en             => ch_en_sync_iq_rdclk,
      sample_width      => sample_width_sync_iq_rdclk,
      
      pct_size          => inst1_pct_size,
      
      pct_sync_dis      => pct_sync_dis,
      sample_nr         => rx_sample_nr_iq_rdclk,
      
      in_pct_reset_n_req=> inst1_in_pct_reset_n_req,
      in_pct_rdreq      => inst1_in_pct_rdreq,
      in_pct_data       => inst0_pct_data,
      in_pct_rdy        => inst0_pct_rdy,
      in_pct_clr_flag   => inst1_in_pct_clr_flag,
      in_pct_buff_rdy   => inst1_in_pct_buff_rdy,
      
      smpl_buff_rdempty => inst1_smpl_buff_rdempty,
      smpl_buff_wrfull  => inst1_smpl_buff_wrfull,
      smpl_buff_q       => inst1_smpl_buff_q,    
      smpl_buff_rdreq   => inst2_fifo_rdreq
        );
        
        
pct_rdy_combined_vect <= inst1_in_pct_buff_rdy & inst1_smpl_buff_wrfull;
        
               
-- ----------------------------------------------------------------------------
-- fifo2diq instance
-- ----------------------------------------------------------------------------       
inst2_fifo_q <=   inst1_smpl_buff_q(63 downto 52) & 
                  inst1_smpl_buff_q(47 downto 36) &
                  inst1_smpl_buff_q(31 downto 20) & 
                  inst1_smpl_buff_q(15 downto 4);

diq2fifo_inst2 : entity work.fifo2diq
   generic map( 
      dev_family     => g_DEV_FAMILY,
      iq_width       => g_IQ_WIDTH
   )
   port map (
      clk                  => iq_rdclk,
      reset_n              => en_sync_iq_rdclk,
      mode                 => mode_sync_iq_rdclk,
      trxiqpulse           => trxiqpulse_sync_iq_rdclk,
      ddr_en               => ddr_en_sync_iq_rdclk,
      mimo_en              => mimo_en_sync_iq_rdclk,
      ch_en                => ch_en_sync_iq_rdclk,
      fidm                 => fidm_sync_iq_rdclk,
      pct_sync_mode        => pct_sync_mode,      
      pct_sync_pulse       => pct_sync_pulse,
      pct_sync_size        => pct_sync_size,
      pct_buff_rdy         => inst2_pct_buff_rdy,
      --txant              
      txant_cyc_before_en  => txant_cyc_before_en,
      txant_cyc_after_en   => txant_cyc_after_en,
      txant_en             => txant_en,
      DIQ                  => DIQ,
      fsync                => fsync,
      DIQ_h                => DIQ_h,
      DIQ_l                => DIQ_l,
      fifo_rdempty         => inst1_smpl_buff_rdempty,
      fifo_rdreq           => inst2_fifo_rdreq,
      fifo_q               => inst2_fifo_q 
   
      );
end arch;   





