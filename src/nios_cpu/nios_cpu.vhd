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
			spi_lms_MISO				: in    std_logic;
			spi_lms_MOSI				: out   std_logic;
			spi_lms_SCLK				: out   std_logic;
			spi_lms_SS_n				: out   std_logic_vector(4 downto 0);
			switch							: in    std_logic_vector(7 downto 0)
        );
end nios_cpu;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of nios_cpu is
--declare signals,  components here
	

	component lms_ctr is
		port (
			clk_clk                                 : in  std_logic                    := 'X';             -- clk
			exfifo_if_d_export                      : in  std_logic_vector(7 downto 0) := (others => 'X'); -- export
			exfifo_if_rd_export                     : out std_logic;                                       -- export
			exfifo_if_rdempty_export                : in  std_logic                    := 'X';             -- export
			exfifo_of_d_export                      : out std_logic_vector(7 downto 0);                    -- export
			exfifo_of_wr_export                     : out std_logic;                                       -- export
			exfifo_of_wrfull_export                 : in  std_logic                    := 'X';             -- export
			exfifo_rst_export                       : out std_logic;                                       -- export
			leds_external_connection_export         : out std_logic_vector(7 downto 0);                    -- export
			lms_ctr_gpio_external_connection_export : out std_logic_vector(3 downto 0);                    -- export
			spi_lms_external_MISO                   : in  std_logic                    := 'X';             -- MISO
			spi_lms_external_MOSI                   : out std_logic;                                       -- MOSI
			spi_lms_external_SCLK                   : out std_logic;                                       -- SCLK
			spi_lms_external_SS_n                   : out std_logic_vector(4 downto 0);                    -- SS_n
			switch_external_connection_export       : in  std_logic_vector(7 downto 0) := (others => 'X')  -- export		
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
			spi_lms_external_MISO                   => spi_lms_MISO,
			spi_lms_external_MOSI                   => spi_lms_MOSI,
			spi_lms_external_SCLK                   => spi_lms_SCLK,
			spi_lms_external_SS_n                   => spi_lms_SS_n,
			switch_external_connection_export       => switch
		);
		


end arch;   




