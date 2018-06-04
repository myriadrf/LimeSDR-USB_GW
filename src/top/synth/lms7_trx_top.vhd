-- ----------------------------------------------------------------------------
-- FILE:          lms7_trx_top.vhd
-- DESCRIPTION:   Top level file for LimeSDR-USB board
-- DATE:          10:06 AM Friday, May 11, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fpgacfg_pkg.all;
use work.pllcfg_pkg.all;
use work.tstcfg_pkg.all;
use work.periphcfg_pkg.all;
use work.FIFO_PACK.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity lms7_trx_top is
   generic(
      -- General parameters
      DEV_FAMILY              : string := "Cyclone IV E";
      -- LMS7002 related 
      LMS_DIQ_WIDTH           : integer := 12;
      -- FX3 (USB3) related
      FX3_PCLK_PERIOD         : integer := 10;
      FX3_DQ_WIDTH            : integer := 32;     -- FX3 Data bus size
      FX3_EP01_SIZE           : integer := 4096;   -- Stream PC->FPGA, FIFO size in bytes, same size for FX3_EP01_0 and FX3_EP01_1
      FX3_EP01_0_RWIDTH       : integer := 128;     -- Stream PC->FPGA, FIFO rd width, FIFO number - 0
      FX3_EP01_1_RWIDTH       : integer := 32;     -- Stream PC->FPGA, FIFO rd width, FIFO number - 1  
      FX3_EP81_SIZE           : integer := 16384;  -- Stream FPGA->PC, FIFO size in bytes
      FX3_EP81_WWIDTH         : integer := 64;     -- Stream FPGA->PC, FIFO wr width
      FX3_EP0F_SIZE           : integer := 1024;   -- Control PC->FPGA, FIFO size in bytes
      FX3_EP0F_RWIDTH         : integer := 32;     -- Control PC->FPGA, rd width
      FX3_EP8F_SIZE           : integer := 1024;   -- Control FPGA->PC, FIFO size in bytes
      FX3_EP8F_WWIDTH         : integer := 32;     -- Control FPGA->PC, wr width
      -- 
      TX_N_BUFF               : integer := 4;      -- N 4KB buffers in TX interface (2 OR 4)
      TX_PCT_SIZE             : integer := 4096;   -- TX packet size in bytes
      TX_IN_PCT_HDR_SIZE      : integer := 16;
      WFM_INFIFO_SIZE         : integer := 4096;   -- WFM in FIFO buffer size in bytes 
      -- Internal configuration memory 
      FPGACFG_START_ADDR      : integer := 0;
      PLLCFG_START_ADDR       : integer := 32;
      TSTCFG_START_ADDR       : integer := 96;
      PERIPHCFG_START_ADDR    : integer := 192;
      -- External periphery
      N_GPIO                  : integer := 8
   );
   port (
      -- ----------------------------------------------------------------------------
      -- External GND pin for reset
      EXT_GND           : in     std_logic;
      -- ----------------------------------------------------------------------------
      -- Clock sources
         -- Reference clock, coming from LMK clock buffer.
      LMK_CLK           : in     std_logic;
         -- Clock generator si5351c
      SI_CLK0           : in     std_logic;
      SI_CLK1           : in     std_logic;
      SI_CLK2           : in     std_logic;
      SI_CLK3           : in     std_logic;
      SI_CLK5           : in     std_logic;
      SI_CLK6           : in     std_logic;
      SI_CLK7           : in     std_logic;
      -- ----------------------------------------------------------------------------
      -- LMS7002 Digital
         -- PORT1
      LMS_MCLK1         : in     std_logic;
      LMS_FCLK1         : out    std_logic;
      LMS_TXNRX1        : out    std_logic;
      LMS_DIQ1_IQSEL    : out    std_logic;
      LMS_DIQ1_D        : out    std_logic_vector(LMS_DIQ_WIDTH-1 downto 0);
         -- PORT2
      LMS_MCLK2         : in     std_logic;
      LMS_FCLK2         : out    std_logic;
      LMS_TXNRX2        : out    std_logic;
      LMS_DIQ2_IQSEL2   : in     std_logic;
      LMS_DIQ2_D        : in     std_logic_vector(LMS_DIQ_WIDTH-1 downto 0);
         --MISC
      LMS_RESET         : out    std_logic := '1';
      LMS_TXEN          : out    std_logic;
      LMS_RXEN          : out    std_logic;
      LMS_CORE_LDO_EN   : out    std_logic;
      -- ----------------------------------------------------------------------------
      -- FX3 (USB3)
         -- Clock source
      FX3_PCLK          : in     std_logic;
         -- Control, flags
      FX3_CTL0          : out    std_logic;
      FX3_CTL1          : out    std_logic;
      FX3_CTL2          : out    std_logic;
      FX3_CTL3          : out    std_logic;
      FX3_CTL4          : in     std_logic;
      FX3_CTL5          : in     std_logic;
      FX3_CTL7          : out    std_logic;
      FX3_CTL8          : in     std_logic;
      FX3_CTL12         : out    std_logic;
      FX3_CTL11         : out    std_logic;
         -- DATA
      FX3_DQ            : inout  std_logic_vector(FX3_DQ_WIDTH-1 downto 0);
      -- ----------------------------------------------------------------------------
      -- External memory (ddr2)
         -- DDR2_1
      DDR2_1_CLK        : inout  std_logic_vector(0 to 0);
      DDR2_1_CLK_N      : inout  std_logic_vector(0 to 0);
      DDR2_1_DQ         : inout  std_logic_vector(15 downto 0);
      DDR2_1_DQS        : inout  std_logic_vector(1 downto 0);
      DDR2_1_RAS_N      : out    std_logic;
      DDR2_1_CAS_N      : out    std_logic;
      DDR2_1_WE_N       : out    std_logic;
      DDR2_1_ADDR       : out    std_logic_vector(12 downto 0);
      DDR2_1_BA         : out    std_logic_vector(2 downto 0);
      DDR2_1_CKE        : out    std_logic_vector(0 to 0);
      DDR2_1_CS_N       : out    std_logic_vector(0 to 0);
      DDR2_1_DM         : out    std_logic_vector(1 downto 0);
      DDR2_1_ODT        : out    std_logic_vector(0 to 0);
         -- DDR2_2
      DDR2_2_CLK        : inout  std_logic_vector(0 to 0);
      DDR2_2_CLK_N      : inout  std_logic_vector(0 to 0);
      DDR2_2_DQ         : inout  std_logic_vector(15 downto 0);
      DDR2_2_DQS        : inout  std_logic_vector(1 downto 0); 
      DDR2_2_RAS_N      : out    std_logic;
      DDR2_2_CAS_N      : out    std_logic;
      DDR2_2_WE_N       : out    std_logic;
      DDR2_2_ADDR       : out    std_logic_vector(12 downto 0);
      DDR2_2_BA         : out    std_logic_vector(2 downto 0);
      DDR2_2_CKE        : out    std_logic_vector(0 to 0);
      DDR2_2_CS_N       : out    std_logic_vector(0 to 0);
      DDR2_2_DM         : out    std_logic_vector(1 downto 0);
      DDR2_2_ODT        : out    std_logic_vector(0 to 0);         
      -- ----------------------------------------------------------------------------
      -- External communication interfaces
         -- FPGA_SPI0
      FPGA_SPI0_SCLK    : out    std_logic;
      FPGA_SPI0_MOSI    : out    std_logic;
      FPGA_SPI0_MISO    : in     std_logic;      
      FPGA_SPI0_LMS_SS  : out    std_logic;
         -- FPGA_SPI1
      FPGA_SPI1_SCLK    : out    std_logic;
      FPGA_SPI1_MOSI    : out    std_logic;
      FPGA_SPI1_DAC_SS  : out    std_logic;
      FPGA_SPI1_ADF_SS  : out    std_logic;
         -- BRDG_SPI
      BRDG_SPI_SCLK     : in     std_logic;
      BRDG_SPI_MOSI     : in     std_logic;
      BRDG_SPI_MISO     : out    std_logic;
      BRDG_SPI_FPGA_SS  : in     std_logic;
         -- FPGA I2C
      FPGA_I2C_SCL      : inout  std_logic;
      FPGA_I2C_SDA      : inout  std_logic;
      -- ----------------------------------------------------------------------------
      -- General periphery
         -- Power source monitoring pin
      PWR_SRC           : in     std_logic;
         -- LEDs          
      FPGA_LED1_R       : out    std_logic;
      FPGA_LED1_G       : out    std_logic;
      FPGA_LED2_G       : out    std_logic;
      FPGA_LED2_R       : out    std_logic;
      FX3_LED_G         : out    std_logic;
      FX3_LED_R         : out    std_logic;
         -- GPIO 
      FPGA_GPIO         : inout  std_logic_vector(N_GPIO-1 downto 0);
         -- ADF lock status
      ADF_MUXOUT        : in     std_logic;
         -- Temperature sensor
      LM75_OS           : in     std_logic;
         -- Fan control 
      FAN_CTRL          : out    std_logic;
         -- RF loop back control 
      TX2_2_LB_L        : out    std_logic;
      TX2_2_LB_H        : out    std_logic;
      TX2_2_LB_AT       : out    std_logic;
      TX2_2_LB_SH       : out    std_logic;
      TX1_2_LB_L        : out    std_logic;
      TX1_2_LB_H        : out    std_logic;
      TX1_2_LB_AT       : out    std_logic;
      TX1_2_LB_SH       : out    std_logic;   
         -- Bill Of material and hardware version 
      BOM_VER           : in     std_logic_vector(3 downto 0);
      HW_VER            : in     std_logic_vector(3 downto 0)

   );
end lms7_trx_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of lms7_trx_top is
--declare signals,  components here
signal reset_n                   : std_logic; 
signal reset_n_fx3_pclk          : std_logic;
signal reset_n_si_clk0           : std_logic;

--inst0 (NIOS CPU instance)
signal inst0_exfifo_if_rd        : std_logic;
signal inst0_exfifo_of_d         : std_logic_vector(FX3_DQ_WIDTH-1 downto 0);
signal inst0_exfifo_of_wr        : std_logic;
signal inst0_exfifo_of_rst          : std_logic;
signal inst0_gpo                : std_logic_vector(7 downto 0);
signal inst0_lms_ctr_gpio        : std_logic_vector(3 downto 0);
signal inst0_spi_0_MISO          : std_logic;
signal inst0_spi_0_MOSI          : std_logic;
signal inst0_spi_0_SCLK          : std_logic;
signal inst0_spi_0_SS_n          : std_logic_vector(4 downto 0);
signal inst0_spi_1_MOSI          : std_logic;
signal inst0_spi_1_SCLK          : std_logic;
signal inst0_spi_1_SS_n          : std_logic_vector(1 downto 0);
signal inst0_from_fpgacfg        : t_FROM_FPGACFG;
signal inst0_to_fpgacfg          : t_TO_FPGACFG;
signal inst0_from_pllcfg         : t_FROM_PLLCFG;
signal inst0_to_pllcfg           : t_TO_PLLCFG;
signal inst0_from_tstcfg         : t_FROM_TSTCFG;
signal inst0_to_tstcfg           : t_TO_TSTCFG;
signal inst0_from_periphcfg      : t_FROM_PERIPHCFG;
signal inst0_to_periphcfg        : t_TO_PERIPHCFG;

--inst1 (pll_top instance)
signal inst1_txpll_c1            : std_logic;
signal inst1_txpll_locked        : std_logic;
signal inst1_txpll_smpl_cmp_en   : std_logic;
signal inst1_txpll_smpl_cmp_cnt  : std_logic_vector(15 downto 0);
signal inst1_rxpll_c1            : std_logic;
signal inst1_rxpll_locked        : std_logic;
signal inst1_rxpll_smpl_cmp_en   : std_logic;
signal inst1_rxpll_smpl_cmp_cnt  : std_logic_vector(15 downto 0);

--inst2
constant C_EP01_0_RDUSEDW_WIDTH  : integer := FIFO_WORDS_TO_Nbits(FX3_EP01_SIZE/(FX3_EP01_0_RWIDTH/8),true);
constant C_EP01_1_RDUSEDW_WIDTH  : integer := FIFO_WORDS_TO_Nbits(FX3_EP01_SIZE/(FX3_EP01_1_RWIDTH/8),true);
constant C_EP81_WRUSEDW_WIDTH    : integer := FIFO_WORDS_TO_Nbits(FX3_EP81_SIZE/(FX3_EP81_WWIDTH/8),true);
constant C_EP0F_RDUSEDW_WIDTH    : integer := FIFO_WORDS_TO_Nbits(FX3_EP0F_SIZE/(FX3_EP0F_RWIDTH/8),true);
constant C_EP8F_WRUSEDW_WIDTH    : integer := FIFO_WORDS_TO_Nbits(FX3_EP8F_SIZE/(FX3_EP8F_WWIDTH/8),true);
signal inst2_ext_buff_data       : std_logic_vector(FX3_DQ_WIDTH-1 downto 0);
signal inst2_ext_buff_wr         : std_logic;
signal inst2_EP81_wfull          : std_logic;
signal inst2_EP81_wrusedw        : std_logic_vector(C_EP81_WRUSEDW_WIDTH-1 downto 0);
signal inst2_EP0F_rdata          : std_logic_vector(FX3_EP0F_RWIDTH-1 downto 0);
signal inst2_EP0F_rempty         : std_logic;
signal inst2_EP8F_wfull          : std_logic;
signal inst2_GPIF_busy           : std_logic;
signal inst2_faddr               : std_logic_vector(4 downto 0);
signal inst2_EP01_0_rdata        : std_logic_vector(FX3_EP01_0_RWIDTH-1 downto 0);
signal inst2_EP01_0_rempty       : std_logic;
signal inst2_EP01_0_rdusedw      : std_logic_vector(C_EP01_0_RDUSEDW_WIDTH-1 downto 0);
signal inst2_EP01_1_rdata        : std_logic_vector(FX3_EP01_1_RWIDTH-1 downto 0);
signal inst2_EP01_1_rempty       : std_logic;
signal inst2_EP01_1_rdusedw      : std_logic_vector(C_EP01_1_RDUSEDW_WIDTH-1 downto 0);


--inst5
signal inst5_busy : std_logic;

--inst6
constant C_WFM_INFIFO_SIZE          : integer := FIFO_WORDS_TO_Nbits(WFM_INFIFO_SIZE/(FX3_DQ_WIDTH/8),true);
signal inst6_tx_pct_loss_flg        : std_logic;
signal inst6_tx_txant_en            : std_logic;
signal inst6_tx_in_pct_full         : std_logic;
signal inst6_rx_pct_fifo_wrreq      : std_logic;
signal inst6_rx_pct_fifo_wdata      : std_logic_vector(63 downto 0);
signal inst6_rx_smpl_cmp_done       : std_logic;
signal inst6_rx_smpl_cmp_err        : std_logic;
signal inst6_to_tstcfg_from_rxtx    : t_TO_TSTCFG_FROM_RXTX;
signal inst6_rx_pct_fifo_aclrn_req  : std_logic;
signal inst6_tx_in_pct_rdreq        : std_logic;
signal inst6_tx_in_pct_reset_n_req  : std_logic;
signal inst6_wfm_in_pct_reset_n_req : std_logic;
signal inst6_wfm_in_pct_rdreq       : std_logic;
signal inst6_wfm_phy_clk            : std_logic;




begin
   
-- ----------------------------------------------------------------------------
-- Reset logic
-- ----------------------------------------------------------------------------  
   -- Reset from FPGA pin. 
   reset_n <= not EXT_GND;
   
   -- Reset signal with synchronous removal to FX3_PCLK clock domain, 
   sync_reg0 : entity work.sync_reg 
   port map(FX3_PCLK, reset_n, '1', reset_n_fx3_pclk);
   
   -- Reset signal with synchronous removal to SI_CLK0 clock domain, 
   sync_reg1 : entity work.sync_reg 
   port map(SI_CLK0, reset_n, '1', reset_n_si_clk0);
     
-- ----------------------------------------------------------------------------
-- NIOS CPU instance.
-- CPU is responsible for communication interfaces and control logic
-- ----------------------------------------------------------------------------   
   inst0_nios_cpu : entity work.nios_cpu
   generic map (
      FPGACFG_START_ADDR   => FPGACFG_START_ADDR,
      PLLCFG_START_ADDR    => PLLCFG_START_ADDR,
      TSTCFG_START_ADDR    => TSTCFG_START_ADDR,
      PERIPHCFG_START_ADDR => PERIPHCFG_START_ADDR
   )
   port map(
      clk                        => FX3_PCLK,
      reset_n                    => reset_n_fx3_pclk,
      -- Control data FIFO
      exfifo_if_d                => inst2_EP0F_rdata,
      exfifo_if_rd               => inst0_exfifo_if_rd, 
      exfifo_if_rdempty          => inst2_EP0F_rempty,
      exfifo_of_d                => inst0_exfifo_of_d, 
      exfifo_of_wr               => inst0_exfifo_of_wr, 
      exfifo_of_wrfull           => inst2_EP8F_wfull,
      exfifo_of_rst              => inst0_exfifo_of_rst, 
      -- SPI 0 
      spi_0_MISO                 => FPGA_SPI0_MISO,
      spi_0_MOSI                 => inst0_spi_0_MOSI,
      spi_0_SCLK                 => inst0_spi_0_SCLK,
      spi_0_SS_n                 => inst0_spi_0_SS_n,
      -- SPI 1
      spi_1_MOSI                 => inst0_spi_1_MOSI,
      spi_1_SCLK                 => inst0_spi_1_SCLK,
      spi_1_SS_n                 => inst0_spi_1_SS_n,
      -- I2C
      i2c_scl                    => FPGA_I2C_SCL,
      i2c_sda                    => FPGA_I2C_SDA,
      -- Genral purpose I/O
      gpi                        => (others=>'0'),
      gpo                        => inst0_gpo, 
      -- LMS7002 control 
      lms_ctr_gpio               => inst0_lms_ctr_gpio,
      -- Configuration registers
      from_fpgacfg               => inst0_from_fpgacfg,
      to_fpgacfg                 => inst0_to_fpgacfg,
      from_pllcfg                => inst0_from_pllcfg,
      to_pllcfg                  => inst0_to_pllcfg,
      from_tstcfg                => inst0_from_tstcfg,
      to_tstcfg                  => inst0_to_tstcfg,
      to_tstcfg_from_rxtx        => inst6_to_tstcfg_from_rxtx,
      from_periphcfg             => inst0_from_periphcfg,
      to_periphcfg               => inst0_to_periphcfg
   );
   
   inst0_to_fpgacfg.HW_VER    <= HW_VER;
   inst0_to_fpgacfg.BOM_VER   <= BOM_VER; 
   inst0_to_fpgacfg.PWR_SRC   <= PWR_SRC;
   
-- ----------------------------------------------------------------------------
-- pll_top instance.
-- Clock source for LMS7002 RX and TX logic
-- ----------------------------------------------------------------------------   
   inst1_pll_top : entity work.pll_top
   generic map(
      N_PLL                         => 2,
      -- TX pll parameters          
      TXPLL_BANDWIDTH_TYPE          => "AUTO",
      TXPLL_CLK0_DIVIDE_BY          => 1,
      TXPLL_CLK0_DUTY_CYCLE         => 50,
      TXPLL_CLK0_MULTIPLY_BY        => 1,
      TXPLL_CLK0_PHASE_SHIFT        => "0",
      TXPLL_CLK1_DIVIDE_BY          => 1,
      TXPLL_CLK1_DUTY_CYCLE         => 50,
      TXPLL_CLK1_MULTIPLY_BY        => 1,
      TXPLL_CLK1_PHASE_SHIFT        => "0",
      TXPLL_COMPENSATE_CLOCK        => "CLK1",
      TXPLL_INCLK0_INPUT_FREQUENCY  => 6250,
      TXPLL_INTENDED_DEVICE_FAMILY  => "Cyclone IV E",
      TXPLL_OPERATION_MODE          => "SOURCE_SYNCHRONOUS",
      TXPLL_SCAN_CHAIN_MIF_FILE     => "ip/txpll/pll.mif",
      TXPLL_DRCT_C0_NDLY            => 1,
      TXPLL_DRCT_C1_NDLY            => 2,
      -- RX pll parameters         
      RXPLL_BANDWIDTH_TYPE          => "AUTO",
      RXPLL_CLK0_DIVIDE_BY          => 1,
      RXPLL_CLK0_DUTY_CYCLE         => 50,
      RXPLL_CLK0_MULTIPLY_BY        => 1,
      RXPLL_CLK0_PHASE_SHIFT        => "0",
      RXPLL_CLK1_DIVIDE_BY          => 1,
      RXPLL_CLK1_DUTY_CYCLE         => 50,
      RXPLL_CLK1_MULTIPLY_BY        => 1,
      RXPLL_CLK1_PHASE_SHIFT        => "0",
      RXPLL_COMPENSATE_CLOCK        => "CLK1",
      RXPLL_INCLK0_INPUT_FREQUENCY  => 6250,
      RXPLL_INTENDED_DEVICE_FAMILY  => "Cyclone IV E",
      RXPLL_OPERATION_MODE          => "SOURCE_SYNCHRONOUS",
      RXPLL_SCAN_CHAIN_MIF_FILE     => "ip/pll/pll.mif",
      RXPLL_DRCT_C0_NDLY            => 1,
      RXPLL_DRCT_C1_NDLY            => 2
   )
   port map(
      -- TX PLL ports
      txpll_inclk          => LMS_MCLK1,
      txpll_reconfig_clk   => LMK_CLK,
      txpll_logic_reset_n  => reset_n,
      txpll_clk_ena        => inst0_from_fpgacfg.CLK_ENA(1 downto 0),
      txpll_drct_clk_en    => inst0_from_fpgacfg.drct_clk_en(0) & inst0_from_fpgacfg.drct_clk_en(0),
      txpll_c0             => LMS_FCLK1,
      txpll_c1             => inst1_txpll_c1,
      txpll_locked         => inst1_txpll_locked,
      txpll_smpl_cmp_en    => inst1_txpll_smpl_cmp_en,
      txpll_smpl_cmp_done  => inst6_rx_smpl_cmp_done,
      txpll_smpl_cmp_error => inst6_rx_smpl_cmp_err,
      txpll_smpl_cmp_cnt   => inst1_txpll_smpl_cmp_cnt,

      -- RX pll ports
      rxpll_inclk          => LMS_MCLK2,
      rxpll_reconfig_clk   => LMK_CLK,
      rxpll_logic_reset_n  => reset_n,
      rxpll_clk_ena        => inst0_from_fpgacfg.CLK_ENA(3 downto 2),
      rxpll_drct_clk_en    => inst0_from_fpgacfg.drct_clk_en(1) & inst0_from_fpgacfg.drct_clk_en(1),
      rxpll_c0             => LMS_FCLK2,
      rxpll_c1             => inst1_rxpll_c1,
      rxpll_locked         => inst1_rxpll_locked,
      rxpll_smpl_cmp_en    => inst1_rxpll_smpl_cmp_en,      
      rxpll_smpl_cmp_done  => inst6_rx_smpl_cmp_done,
      rxpll_smpl_cmp_error => inst6_rx_smpl_cmp_err,
      rxpll_smpl_cmp_cnt   => inst1_rxpll_smpl_cmp_cnt,       
      -- pllcfg ports
      from_pllcfg          => inst0_from_pllcfg,
      to_pllcfg            => inst0_to_pllcfg
   );
      
-- ----------------------------------------------------------------------------
-- FX3_slaveFIFO5b_top instance.
-- USB3 interface 
-- ----------------------------------------------------------------------------
   inst2_FX3_slaveFIFO5b_top : entity work.FX3_slaveFIFO5b_top
   generic map(
      dev_family           => DEV_FAMILY,
      data_width           => FX3_DQ_WIDTH,
      -- Stream, socket 0, (PC->FPGA) 
      EP01_0_rdusedw_width => C_EP01_0_RDUSEDW_WIDTH,
      EP01_0_rwidth		   => FX3_EP01_0_RWIDTH,
      EP01_1_rdusedw_width => C_EP01_1_RDUSEDW_WIDTH,
      EP01_1_rwidth		   => FX3_EP01_1_RWIDTH,
      -- Stream, socket 2, (FPGA->PC)
      EP81_wrusedw_width	=> C_EP81_WRUSEDW_WIDTH,
      EP81_wwidth				=> FX3_EP81_WWIDTH,
      -- Control, socket 1, (PC->FPGA)
      EP0F_rdusedw_width   => C_EP0F_RDUSEDW_WIDTH,
      EP0F_rwidth				=> FX3_EP0F_RWIDTH,
      -- Control, socket 3, (FPGA->PC)
      EP8F_wrusedw_width   => C_EP8F_WRUSEDW_WIDTH,
      EP8F_wwidth				=> FX3_EP8F_WWIDTH 
   )
   port map(
      reset_n              => reset_n_fx3_pclk, --input reset active low
      clk                  => FX3_PCLK,         --input clk 100 Mhz  
      --clk_out              => open,             --output clk 100 Mhz 
      usb_speed            => '1',              --USB3.0 - 1, USB2.0 - 0
      slcs                 => FX3_CTL0,         --output chip select
      fdata                => FX3_DQ,         
      faddr                => inst2_faddr,      --output fifo address
      slrd                 => FX3_CTL3,         --output read select
      sloe                 => FX3_CTL2,         --output output enable select
      slwr                 => FX3_CTL1,         --output write select
                  
      flaga                => FX3_CTL4,                                
      flagb                => FX3_CTL5,
      flagc                => '0',   --Not used in 5bit address mode
      flagd                => '0',   --Not used in 5bit address mode
      
      pktend               => FX3_CTL7,  --output pkt end 
      EPSWITCH             => open,
      
      EP01_sel             => inst0_from_fpgacfg.wfm_load,
      --stream endpoint fifo (PC->FPGA) 
      EP01_0_rdclk         => inst1_txpll_c1,
      EP01_0_aclrn         => inst6_tx_in_pct_reset_n_req,
      EP01_0_rd            => inst6_tx_in_pct_rdreq,
      EP01_0_rdata         => inst2_EP01_0_rdata,
      EP01_0_rempty        => inst2_EP01_0_rempty,
      EP01_0_rdusedw       => inst2_EP01_0_rdusedw,
     
      EP01_1_rdclk         => inst1_txpll_c1,
      EP01_1_aclrn         => inst6_wfm_in_pct_reset_n_req,
      EP01_1_rd            => inst6_wfm_in_pct_rdreq,
      EP01_1_rdata         => inst2_EP01_1_rdata,
      EP01_1_rempty        => inst2_EP01_1_rempty,
      EP01_1_rdusedw       => inst2_EP01_1_rdusedw, 
      
      --stream endpoint fifo (FPGA->PC)
      EP81_wclk            => inst1_rxpll_c1,
      EP81_aclrn           => inst6_rx_pct_fifo_aclrn_req,
      EP81_wr              => inst6_rx_pct_fifo_wrreq,
      EP81_wdata           => inst6_rx_pct_fifo_wdata,
      EP81_wfull           => inst2_EP81_wfull,
      EP81_wrusedw         => inst2_EP81_wrusedw,
      --controll endpoint fifo (PC->FPGA)
      EP0F_rdclk           => FX3_PCLK,
      EP0F_aclrn           => reset_n,
      EP0F_rd              => inst0_exfifo_if_rd,
      EP0F_rdata           => inst2_EP0F_rdata,
      EP0F_rempty          => inst2_EP0F_rempty,
      --controll endpoint fifo (FPGA->PC)
      EP8F_wclk            => FX3_PCLK,
      EP8F_aclrn           => not inst0_exfifo_of_rst,
      EP8F_wr              => inst0_exfifo_of_wr,
      EP8F_wdata           => inst0_exfifo_of_d,
      EP8F_wfull           => inst2_EP8F_wfull,
      GPIF_busy            => inst2_GPIF_busy
      );
      
-- ----------------------------------------------------------------------------
-- tst_top instance.
-- Clock and External DDR2 memroy test logic
-- ----------------------------------------------------------------------------
   inst3_tst_top : entity work.tst_top
   port map(
      --input ports 
      FX3_clk           => FX3_PCLK,
      reset_n           => reset_n_fx3_pclk,    
      Si5351C_clk_0     => SI_CLK0,
      Si5351C_clk_1     => SI_CLK1,
      Si5351C_clk_2     => SI_CLK2,
      Si5351C_clk_3     => SI_CLK3,
      Si5351C_clk_5     => SI_CLK5,
      Si5351C_clk_6     => SI_CLK6,
      Si5351C_clk_7     => SI_CLK7,
      LMK_CLK           => LMK_CLK,
      ADF_MUXOUT        => ADF_MUXOUT,    
      --DDR2 external memory signals
      mem_pllref_clk    => SI_CLK1,
      mem_odt           => DDR2_2_ODT,
      mem_cs_n          => DDR2_2_CS_N,
      mem_cke           => DDR2_2_CKE,
      mem_addr          => DDR2_2_ADDR,
      mem_ba            => DDR2_2_BA,
      mem_ras_n         => DDR2_2_RAS_N,
      mem_cas_n         => DDR2_2_CAS_N,
      mem_we_n          => DDR2_2_WE_N,
      mem_dm            => DDR2_2_DM,
      mem_clk           => DDR2_2_CLK,
      mem_clk_n         => DDR2_2_CLK_N,
      mem_dq            => DDR2_2_DQ,
      mem_dqs           => DDR2_2_DQS,     
      -- To configuration memory
      to_tstcfg         => inst0_to_tstcfg,
      from_tstcfg       => inst0_from_tstcfg
   );    
   
-- ----------------------------------------------------------------------------
-- general_periph_top instance.
-- Control module for external periphery
-- ----------------------------------------------------------------------------
   inst4_general_periph_top : entity work.general_periph_top
   generic map(
      DEV_FAMILY  => DEV_FAMILY,
      N_GPIO      => N_GPIO
   )
   port map(
      -- General ports
      clk                  => SI_CLK0,
      reset_n              => reset_n_si_clk0,
      -- configuration memory
      to_periphcfg         => inst0_to_periphcfg,
      from_periphcfg       => inst0_from_periphcfg,     
      -- Dual colour LEDs
      -- LED1 (Clock and PLL lock status)
      led1_pll1_locked     => inst1_txpll_locked,
      led1_pll2_locked     => inst1_rxpll_locked,
      led1_ctrl            => inst0_from_fpgacfg.FPGA_LED1_CTRL,
      led1_g               => FPGA_LED1_G,
      led1_r               => FPGA_LED1_R,      
      --LED2 (TCXO control status)
      led2_clk             => inst0_spi_1_SCLK,
      led2_adf_muxout      => ADF_MUXOUT,
      led2_dac_ss          => inst0_spi_1_SS_n(0),
      led2_adf_ss          => inst0_spi_1_SS_n(1),
      led2_ctrl            => inst0_from_fpgacfg.FPGA_LED2_CTRL,
      led2_g               => FPGA_LED2_G,
      led2_r               => FPGA_LED2_R,     
      --LED3 (FX3 and NIOS CPU busy)
      led3_g_in            => not inst5_busy,
      led3_r_in            => inst5_busy,
      led3_ctrl            => inst0_from_fpgacfg.FX3_LED_CTRL,
      led3_hw_ver          => HW_VER,
      led3_g               => FX3_LED_G,
      led3_r               => FX3_LED_R,     
      --GPIO
      gpio_dir             => (others=>'1'),
      gpio_out_val         => "0000" & inst6_tx_pct_loss_flg & inst1_txpll_locked & inst1_rxpll_locked & inst6_tx_txant_en,
      gpio_rd_val          => open,
      gpio                 => FPGA_GPIO,      
      --Fan control
      fan_sens_in          => LM75_OS,
      fan_ctrl_out         => FAN_CTRL
   );
   
   inst5_busy_delay : entity work.busy_delay
   generic map(
      clock_period   => FX3_PCLK_PERIOD,
      delay_time     => 200  -- delay time in ms
      --counter_value=delay_time*1000/clock_period<2^32
      --delay counter is 32bit wide, 
   )
   port map(
      --input ports 
      clk      => FX3_PCLK,
      reset_n  => reset_n_fx3_pclk,
      busy_in  => inst0_gpo(0) OR inst2_GPIF_busy OR FX3_CTL8,
      busy_out => inst5_busy
   );
   
-- ----------------------------------------------------------------------------
-- rxtx_top instance.
-- Receive and transmit interface for LMS7002
-- ----------------------------------------------------------------------------
   inst6_rxtx_top : entity work.rxtx_top
   generic map(
      DEV_FAMILY              => DEV_FAMILY,
      -- TX parameters
      TX_IQ_WIDTH             => LMS_DIQ_WIDTH,
      TX_N_BUFF               => TX_N_BUFF,              -- 2,4 valid values
      TX_IN_PCT_SIZE          => TX_PCT_SIZE,
      TX_IN_PCT_HDR_SIZE      => TX_IN_PCT_HDR_SIZE,
      TX_IN_PCT_DATA_W        => FX3_EP01_0_RWIDTH,      -- 
      TX_IN_PCT_RDUSEDW_W     => C_EP01_0_RDUSEDW_WIDTH,
      
      -- RX parameters
      RX_IQ_WIDTH             => LMS_DIQ_WIDTH,
      RX_INVERT_INPUT_CLOCKS  => "ON",
      RX_PCT_BUFF_WRUSEDW_W   => C_EP81_WRUSEDW_WIDTH, --bus width in bits 
      
      -- WFM
      --DDR2 controller parameters
      WFM_CNTRL_RATE          => 1, --1 - full rate, 2 - half rate
      WFM_CNTRL_BUS_SIZE      => 16,
      WFM_ADDR_SIZE           => 25,
      WFM_LCL_BUS_SIZE        => 64,
      WFM_LCL_BURST_LENGTH    => 2,
      --WFM player parameters
      WFM_WFM_INFIFO_SIZE     => C_WFM_INFIFO_SIZE,
      WFM_DATA_WIDTH          => FX3_DQ_WIDTH,
      WFM_IQ_WIDTH            => LMS_DIQ_WIDTH
   )
   port map(                                             
      from_fpgacfg            => inst0_from_fpgacfg,
      to_tstcfg_from_rxtx     => inst6_to_tstcfg_from_rxtx,
      from_tstcfg             => inst0_from_tstcfg,
      
      -- TX module signals
      tx_clk                  => inst1_txpll_c1,
      tx_clk_reset_n          => inst1_txpll_locked,     
      tx_pct_loss_flg         => inst6_tx_pct_loss_flg,
      tx_txant_en             => inst6_tx_txant_en,  
      --Tx interface data 
      tx_DIQ                  => LMS_DIQ1_D,
      tx_fsync                => LMS_DIQ1_IQSEL,
      --fifo ports
      tx_in_pct_reset_n_req   => inst6_tx_in_pct_reset_n_req,
      tx_in_pct_rdreq         => inst6_tx_in_pct_rdreq,
      tx_in_pct_data          => inst2_EP01_0_rdata,
      tx_in_pct_rdempty       => inst2_EP01_0_rempty,
      tx_in_pct_rdusedw       => inst2_EP01_0_rdusedw,
      
      -- WFM Player
      wfm_pll_ref_clk         => SI_CLK0,
      wfm_pll_ref_clk_reset_n => reset_n_si_clk0,    
      wfm_phy_clk             => inst6_wfm_phy_clk,
         -- WFM FIFO read ports
      wfm_in_pct_reset_n_req  => inst6_wfm_in_pct_reset_n_req,
      wfm_in_pct_rdreq        => inst6_wfm_in_pct_rdreq, 
      wfm_in_pct_data         => inst2_EP01_1_rdata,
      wfm_in_pct_rdempty      => inst2_EP01_1_rempty,
      wfm_in_pct_rdusedw      => inst2_EP01_1_rdusedw,

      --DDR2 external memory signals
      wfm_mem_odt             => DDR2_1_ODT,
      wfm_mem_cs_n            => DDR2_1_CS_N,
      wfm_mem_cke             => DDR2_1_CKE,
      wfm_mem_addr            => DDR2_1_ADDR,
      wfm_mem_ba              => DDR2_1_BA,
      wfm_mem_ras_n           => DDR2_1_RAS_N,
      wfm_mem_cas_n           => DDR2_1_CAS_N,
      wfm_mem_we_n            => DDR2_1_WE_N,
      wfm_mem_dm              => DDR2_1_DM,
      wfm_mem_clk             => DDR2_1_CLK,
      wfm_mem_clk_n           => DDR2_1_CLK_N,
      wfm_mem_dq              => DDR2_1_DQ,
      wfm_mem_dqs             => DDR2_1_DQS,
      
      -- RX path
      rx_clk                  => inst1_rxpll_c1,
      rx_clk_reset_n          => inst1_rxpll_locked,
      --Rx interface data 
      rx_DIQ                  => LMS_DIQ2_D,
      rx_fsync                => LMS_DIQ2_IQSEL2,
      --Packet fifo ports
      rx_pct_fifo_aclrn_req   => inst6_rx_pct_fifo_aclrn_req,
      rx_pct_fifo_wusedw      => inst2_EP81_wrusedw,
      rx_pct_fifo_wrreq       => inst6_rx_pct_fifo_wrreq,
      rx_pct_fifo_wdata       => inst6_rx_pct_fifo_wdata,
      --sample compare
      rx_smpl_cmp_start       => inst1_txpll_smpl_cmp_en OR inst1_rxpll_smpl_cmp_en,
      rx_smpl_cmp_length      => inst1_rxpll_smpl_cmp_cnt,
      rx_smpl_cmp_done        => inst6_rx_smpl_cmp_done,
      rx_smpl_cmp_err         => inst6_rx_smpl_cmp_err     
   );
   
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------
   FX3_CTL11         <= inst2_faddr(1);
   FX3_CTL12         <= inst2_faddr(0);
   
   FPGA_SPI0_MOSI    <= inst0_spi_0_MOSI;
   FPGA_SPI0_SCLK    <= inst0_spi_0_SCLK;
   FPGA_SPI0_LMS_SS  <= inst0_spi_0_SS_n(0);
   
   LMS_RESET         <= inst0_from_fpgacfg.LMS1_RESET AND inst0_lms_ctr_gpio(0);
   LMS_TXEN          <= inst0_from_fpgacfg.LMS1_TXEN;
   LMS_RXEN          <= inst0_from_fpgacfg.LMS1_RXEN;
   LMS_CORE_LDO_EN   <= inst0_from_fpgacfg.LMS1_CORE_LDO_EN;
   LMS_TXNRX1        <= inst0_from_fpgacfg.LMS1_TXNRX1;
   LMS_TXNRX2        <= inst0_from_fpgacfg.LMS1_TXNRX2;
   
   TX1_2_LB_L        <= not inst0_from_fpgacfg.GPIO(0);
   TX1_2_LB_H        <= inst0_from_fpgacfg.GPIO(0);
   TX1_2_LB_AT       <= inst0_from_fpgacfg.GPIO(1);
   TX1_2_LB_SH       <= inst0_from_fpgacfg.GPIO(2);
   
   TX2_2_LB_L        <= not inst0_from_fpgacfg.GPIO(4);
   TX2_2_LB_H        <= inst0_from_fpgacfg.GPIO(4);
   TX2_2_LB_AT       <= inst0_from_fpgacfg.GPIO(5);
   TX2_2_LB_SH       <= inst0_from_fpgacfg.GPIO(6);
   
   FPGA_SPI1_MOSI    <= inst0_spi_1_MOSI;
   FPGA_SPI1_SCLK    <= inst0_spi_1_SCLK;
   FPGA_SPI1_DAC_SS  <= inst0_spi_1_SS_n(0);
   FPGA_SPI1_ADF_SS  <= inst0_spi_1_SS_n(1);


end arch;   



