--!  @file soc_wrapper
--! @author 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library orca;


entity soc_wrapper is
	generic(
		cpu_name	:	string := "nios2"
	);
	port (
		-- Clock with 100 MHz frequency
		clk100					: in    std_logic;
		-- External FIFO
		exfifo_if_d				: in    std_logic_vector(31 downto 0);
		exfifo_if_rd			: out   std_logic;
		exfifo_if_rdempty		: in    std_logic;
		exfifo_of_d				: out   std_logic_vector(31 downto 0);
		exfifo_of_wr				: out   std_logic;
		exfifo_of_wrfull		: in    std_logic;
		exfifo_rst				: out   std_logic;
		-- LEDS - GPIO 8 bits output
		leds					: out   std_logic_vector(7 downto 0);
		-- lms_ctr_gpio - GPIO 4 bits output
		lms_ctr_gpio			: out   std_logic_vector(3 downto 0);
		-- SPI lms
		spi_lms_MISO			: in    std_logic;
		spi_lms_MOSI			: out   std_logic;
		spi_lms_SCLK			: out   std_logic;
		spi_lms_SS_n			: out   std_logic_vector(4 downto 0);
		-- SPI 1
		spi_1_MOSI				: out   std_logic;
		spi_1_SCLK				: out   std_logic;
		spi_1_SS_n				: out   std_logic_vector(1 downto 0);
		-- Switch - GPIO 8 bits input
		switch					: in    std_logic_vector(7 downto 0);
		i2c_scl					: inout std_logic;
		i2c_sda					: inout std_logic
			
	);
end entity soc_wrapper;

architecture RTL of soc_wrapper is
	
	    component lms_orca is
        port (
            clk_clk                                     : in    std_logic                     := 'X';             -- clk
            controlled_reset_external_connection_export : out   std_logic;                                        -- export
            exfifo_if_d_export                          : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
            exfifo_if_rd_export                         : out   std_logic;                                        -- export
            exfifo_if_rdempty_export                    : in    std_logic                     := 'X';             -- export
            exfifo_of_d_export                          : out   std_logic_vector(31 downto 0);                    -- export
            exfifo_of_wr_export                         : out   std_logic;                                        -- export
            exfifo_of_wrfull_export                     : in    std_logic                     := 'X';             -- export
            exfifo_rst_export                           : out   std_logic;                                        -- export
            i2c_opencores_0_interrupt_sender_irq        : out   std_logic;                                        -- irq
            in_reset_reset_n                            : in    std_logic                     := 'X';             -- reset_n
            leds_external_connection_export             : out   std_logic_vector(7 downto 0);                     -- export
            lms_ctr_gpio_external_connection_export     : out   std_logic_vector(3 downto 0);                     -- export
            scl_exp_export                              : inout std_logic                     := 'X';             -- export
            sda_exp_export                              : inout std_logic                     := 'X';             -- export
            spi_1_dac_external_MISO                     : in    std_logic                     := 'X';             -- MISO
            spi_1_dac_external_MOSI                     : out   std_logic;                                        -- MOSI
            spi_1_dac_external_SCLK                     : out   std_logic;                                        -- SCLK
            spi_1_dac_external_SS_n                     : out   std_logic_vector(1 downto 0);                     -- SS_n
            spi_1_dac_irq_irq                           : out   std_logic;                                        -- irq
            spi_lms_external_MISO                       : in    std_logic                     := 'X';             -- MISO
            spi_lms_external_MOSI                       : out   std_logic;                                        -- MOSI
            spi_lms_external_SCLK                       : out   std_logic;                                        -- SCLK
            spi_lms_external_SS_n                       : out   std_logic_vector(4 downto 0);                     -- SS_n
            spi_lms_irq_irq                             : out   std_logic;                                        -- irq
            switch_external_connection_export           : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- export
            vectorblox_orca_0_global_interrupts_export  : in    std_logic_vector(0 downto 0)  := (others => 'X')  -- export
        );
    end component lms_orca;
	    signal i2c_opencores_0_interrupt_sender_irq : std_logic;
	    signal spi_lms_irq_irq : std_logic;
	    signal spi_1_dac_irq_irq : std_logic;
	    signal vectorblox_orca_0_global_interrupts_export : std_logic_vector(0 downto 0);
	    signal in_reset_reset_n : std_logic;
	    signal controlled_reset_external_connection_export : std_logic;
	
	 
	 
	 
begin
	
	gen_pulpino : if cpu_name="pulpino_riscv" generate
		
		
	end generate gen_pulpino;
	
	gen_orca : if cpu_name="orca" generate
		
		lms_orca_inst :  lms_orca
			port map(
				clk_clk                                     => clk100,
				exfifo_if_d_export                          => exfifo_if_d,
				exfifo_if_rd_export                         => exfifo_if_rd,
				exfifo_if_rdempty_export                    => exfifo_if_rdempty,
				exfifo_of_d_export                          => exfifo_of_d,
				exfifo_of_wr_export                         => exfifo_of_wr,
				exfifo_of_wrfull_export                     => exfifo_of_wrfull,
				exfifo_rst_export                           => exfifo_rst,
				leds_external_connection_export             => leds,
				lms_ctr_gpio_external_connection_export     => lms_ctr_gpio,
				scl_exp_export                              => i2c_scl,
				sda_exp_export                              => i2c_sda,
				spi_1_dac_external_MISO                     => '0',
				spi_1_dac_external_MOSI                     => spi_1_MOSI,
				spi_1_dac_external_SCLK                     => spi_1_SCLK,
				spi_1_dac_external_SS_n                     => spi_1_SS_n,
				spi_lms_external_MISO                       => spi_lms_MISO,
				spi_lms_external_MOSI                       => spi_lms_MOSI,
				spi_lms_external_SCLK                       => spi_lms_SCLK,
				spi_lms_external_SS_n                       => spi_lms_SS_n,
				switch_external_connection_export           => switch,
				i2c_opencores_0_interrupt_sender_irq        => i2c_opencores_0_interrupt_sender_irq,
				spi_lms_irq_irq                             => spi_lms_irq_irq,
				spi_1_dac_irq_irq                           => spi_1_dac_irq_irq,
				vectorblox_orca_0_global_interrupts_export  => vectorblox_orca_0_global_interrupts_export,
				in_reset_reset_n                            => in_reset_reset_n,
				controlled_reset_external_connection_export => controlled_reset_external_connection_export
			);
			
			vectorblox_orca_0_global_interrupts_export(0) <= i2c_opencores_0_interrupt_sender_irq or  spi_lms_irq_irq or spi_1_dac_irq_irq;
	end generate gen_orca;
	
	gen_picorv32 : if cpu_name="picorv32" generate
		
		
		
	end generate gen_picorv32;
	
	gen_lowrisc : if cpu_name="lowrisc" generate
		
		
		
		
	end generate gen_lowrisc;
	
	gen_mor1kx : if cpu_name="mor1kx" generate
		
		
	end generate gen_mor1kx;
	
	gen_nios2 : if cpu_name="nios2" generate
			
		nios_cpu_inst : entity work.nios_cpu
			port map(
				clk100            => clk100,
				exfifo_if_d       => exfifo_if_d,
				exfifo_if_rd      => exfifo_if_rd,
				exfifo_if_rdempty => exfifo_if_rdempty,
				exfifo_of_d       => exfifo_of_d,
				exfifo_of_wr      => exfifo_of_wr,
				exfifo_of_wrfull  => exfifo_of_wrfull,
				exfifo_rst        => exfifo_rst,
				leds              => leds,
				lms_ctr_gpio      => lms_ctr_gpio,
				spi_lms_MISO      => spi_lms_MISO,
				spi_lms_MOSI      => spi_lms_MOSI,
				spi_lms_SCLK      => spi_lms_SCLK,
				spi_lms_SS_n      => spi_lms_SS_n,
				spi_1_MOSI        => spi_1_MOSI,
				spi_1_SCLK        => spi_1_SCLK,
				spi_1_SS_n        => spi_1_SS_n,
				switch            => switch,
				i2c_scl           => i2c_scl,
				i2c_sda           => i2c_sda
			);
		
		
	end generate gen_nios2;
	

end architecture RTL;
