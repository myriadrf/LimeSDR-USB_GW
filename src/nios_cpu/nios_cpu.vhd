-- ----------------------------------------------------------------------------	
-- FILE: 	nios_cpu.vhd
-- DESCRIPTION:	NIOS CPU top level
-- DATE:	Feb 12, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity nios_cpu is
  port (
			clk100							: in    std_logic;
			exfifo_if_d					: in    std_logic_vector(7 downto 0);
			exfifo_if_rd				: out   std_logic;
			exfifo_if_rdempty		: in    std_logic;
			exfifo_of_d					: out   std_logic_vector(7 downto 0);
			exfifo_of_wr				: out   std_logic;
			exfifo_of_wrfull		: in    std_logic;
			exfifo_rst					: out   std_logic;
			leds								: out   std_logic_vector(7 downto 0);
			lms_ctr_gpio				: out   std_logic_vector(3 downto 0);
			spi_1_MISO					: in    std_logic;
			spi_1_MOSI					: out   std_logic;
			spi_1_SCLK					: out   std_logic;
			spi_1_SS_n					: out   std_logic_vector(1 downto 0);
			spi_fpga_as_MISO		: in    std_logic;
			spi_fpga_as_MOSI		: out   std_logic;
			spi_fpga_as_SCLK		: out   std_logic;
			spi_fpga_as_SS_n		: out   std_logic;
			spi_lms_MISO				: in    std_logic;
			spi_lms_MOSI				: out   std_logic;
			spi_lms_SCLK				: out   std_logic;
			spi_lms_SS_n				: out   std_logic_vector(4 downto 0);
			switch							: in    std_logic_vector(7 downto 0);
			uart_rxd						: in    std_logic;
			uart_txd						: out   std_logic;
			i2c_scl							: inout std_logic;
			i2c_sda							: inout std_logic
        );
end nios_cpu;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of nios_cpu is
--declare signals,  components here
	
	signal adf4002_MOSI, adf4002_SCLK, adf4002_SS_n: std_logic;
	signal ad5601_MOSI, ad5601_SCLK: std_logic;
	signal ad5601_SS_n: std_logic_vector(1 downto 0);

	component lms_ctr is
		port (
			clk_clk                                 : in    std_logic                    := 'X';             -- clk
			exfifo_if_d_export                      : in    std_logic_vector(7 downto 0) := (others => 'X'); -- export
			exfifo_if_rd_export                     : out   std_logic;                                       -- export
			exfifo_if_rdempty_export                : in    std_logic                    := 'X';             -- export
			exfifo_of_d_export                      : out   std_logic_vector(7 downto 0);                    -- export
			exfifo_of_wr_export                     : out   std_logic;                                       -- export
			exfifo_of_wrfull_export                 : in    std_logic                    := 'X';             -- export
			exfifo_rst_export                       : out   std_logic;                                       -- export
			leds_external_connection_export         : out   std_logic_vector(7 downto 0);                    -- export
			lms_ctr_gpio_external_connection_export : out   std_logic_vector(3 downto 0);                    -- export
			spi_1_ext_MISO                          : in    std_logic                    := 'X';             -- MISO
			spi_1_ext_MOSI                          : out   std_logic;                                       -- MOSI
			spi_1_ext_SCLK                          : out   std_logic;                                       -- SCLK
			spi_1_ext_SS_n                          : out   std_logic_vector(1 downto 0);                    -- SS_n
			spi_fpga_as_MISO                        : in    std_logic                    := 'X';             -- MISO
			spi_fpga_as_MOSI                        : out   std_logic;                                       -- MOSI
			spi_fpga_as_SCLK                        : out   std_logic;                                       -- SCLK
			spi_fpga_as_SS_n                        : out   std_logic;                                       -- SS_n
			spi_lms_external_MISO                   : in    std_logic                    := 'X';             -- MISO
			spi_lms_external_MOSI                   : out   std_logic;                                       -- MOSI
			spi_lms_external_SCLK                   : out   std_logic;                                       -- SCLK
			spi_lms_external_SS_n                   : out   std_logic_vector(4 downto 0);                    -- SS_n
			switch_external_connection_export       : in    std_logic_vector(7 downto 0) := (others => 'X'); -- export
			uart_external_connection_rxd            : in    std_logic                    := 'X';             -- rxd
			uart_external_connection_txd            : out   std_logic;                                       -- txd
			i2c_scl_export                          : inout std_logic                    := 'X';             -- export
			i2c_sda_export                          : inout std_logic                    := 'X';             -- export
			spi_1_adf4002_MISO                      : in    std_logic                    := 'X';             -- MISO
			spi_1_adf4002_MOSI                      : out   std_logic;                                       -- MOSI
			spi_1_adf4002_SCLK                      : out   std_logic;                                       -- SCLK
			spi_1_adf4002_SS_n                      : out   std_logic                                        -- SS_n 
		);
	end component lms_ctr;
  
begin

	u0 : component lms_ctr
		port map (
			clk_clk                                 => clk100,
			exfifo_if_d_export                      => exfifo_if_d,
			exfifo_if_rd_export                     => exfifo_if_rd,
			exfifo_if_rdempty_export                => exfifo_if_rdempty,
			exfifo_of_d_export                      => exfifo_of_d,
			exfifo_of_wr_export                     => exfifo_of_wr,
			exfifo_of_wrfull_export                 => exfifo_of_wrfull,
			exfifo_rst_export                       => exfifo_rst,
			leds_external_connection_export         => leds,
			lms_ctr_gpio_external_connection_export => lms_ctr_gpio,
			spi_1_ext_MISO                          => spi_1_MISO,
			spi_1_ext_MOSI                          => ad5601_MOSI,
			spi_1_ext_SCLK                          => ad5601_SCLK,
			spi_1_ext_SS_n                          => ad5601_SS_n,
			spi_fpga_as_MISO                        => spi_fpga_as_MISO,
			spi_fpga_as_MOSI                        => spi_fpga_as_MOSI,
			spi_fpga_as_SCLK                        => spi_fpga_as_SCLK,
			spi_fpga_as_SS_n                        => spi_fpga_as_SS_n,
			spi_lms_external_MISO                   => spi_lms_MISO,
			spi_lms_external_MOSI                   => spi_lms_MOSI,
			spi_lms_external_SCLK                   => spi_lms_SCLK,
			spi_lms_external_SS_n                   => spi_lms_SS_n,
			switch_external_connection_export       => switch,
			uart_external_connection_rxd            => uart_rxd,
			uart_external_connection_txd            => uart_txd,
			i2c_scl_export                          => i2c_scl,
			i2c_sda_export                          => i2c_sda,
			spi_1_adf4002_MISO                      => '0',
			spi_1_adf4002_MOSI                      => adf4002_MOSI,
			spi_1_adf4002_SCLK                      => adf4002_SCLK,
			spi_1_adf4002_SS_n                      => adf4002_SS_n
		);
		
		
		-- SPI switch to select between ADF4002 and AD5601.
		-- This is neccessary, while ADF4002 CLOCK_PHASE = 0, while AD5601 CLOCK_PHASE = 1
		spi_1_MOSI <= adf4002_MOSI when adf4002_SS_n = '0' else ad5601_MOSI;
		spi_1_SCLK <= adf4002_SCLK when adf4002_SS_n = '0' else ad5601_SCLK;
		
		spi_1_SS_n <= adf4002_SS_n & ad5601_SS_n(0);


end arch;   




