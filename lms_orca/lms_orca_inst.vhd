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

	u0 : component lms_orca
		port map (
			clk_clk                                     => CONNECTED_TO_clk_clk,                                     --                                  clk.clk
			controlled_reset_external_connection_export => CONNECTED_TO_controlled_reset_external_connection_export, -- controlled_reset_external_connection.export
			exfifo_if_d_export                          => CONNECTED_TO_exfifo_if_d_export,                          --                          exfifo_if_d.export
			exfifo_if_rd_export                         => CONNECTED_TO_exfifo_if_rd_export,                         --                         exfifo_if_rd.export
			exfifo_if_rdempty_export                    => CONNECTED_TO_exfifo_if_rdempty_export,                    --                    exfifo_if_rdempty.export
			exfifo_of_d_export                          => CONNECTED_TO_exfifo_of_d_export,                          --                          exfifo_of_d.export
			exfifo_of_wr_export                         => CONNECTED_TO_exfifo_of_wr_export,                         --                         exfifo_of_wr.export
			exfifo_of_wrfull_export                     => CONNECTED_TO_exfifo_of_wrfull_export,                     --                     exfifo_of_wrfull.export
			exfifo_rst_export                           => CONNECTED_TO_exfifo_rst_export,                           --                           exfifo_rst.export
			i2c_opencores_0_interrupt_sender_irq        => CONNECTED_TO_i2c_opencores_0_interrupt_sender_irq,        --     i2c_opencores_0_interrupt_sender.irq
			in_reset_reset_n                            => CONNECTED_TO_in_reset_reset_n,                            --                             in_reset.reset_n
			leds_external_connection_export             => CONNECTED_TO_leds_external_connection_export,             --             leds_external_connection.export
			lms_ctr_gpio_external_connection_export     => CONNECTED_TO_lms_ctr_gpio_external_connection_export,     --     lms_ctr_gpio_external_connection.export
			scl_exp_export                              => CONNECTED_TO_scl_exp_export,                              --                              scl_exp.export
			sda_exp_export                              => CONNECTED_TO_sda_exp_export,                              --                              sda_exp.export
			spi_1_dac_external_MISO                     => CONNECTED_TO_spi_1_dac_external_MISO,                     --                   spi_1_dac_external.MISO
			spi_1_dac_external_MOSI                     => CONNECTED_TO_spi_1_dac_external_MOSI,                     --                                     .MOSI
			spi_1_dac_external_SCLK                     => CONNECTED_TO_spi_1_dac_external_SCLK,                     --                                     .SCLK
			spi_1_dac_external_SS_n                     => CONNECTED_TO_spi_1_dac_external_SS_n,                     --                                     .SS_n
			spi_1_dac_irq_irq                           => CONNECTED_TO_spi_1_dac_irq_irq,                           --                        spi_1_dac_irq.irq
			spi_lms_external_MISO                       => CONNECTED_TO_spi_lms_external_MISO,                       --                     spi_lms_external.MISO
			spi_lms_external_MOSI                       => CONNECTED_TO_spi_lms_external_MOSI,                       --                                     .MOSI
			spi_lms_external_SCLK                       => CONNECTED_TO_spi_lms_external_SCLK,                       --                                     .SCLK
			spi_lms_external_SS_n                       => CONNECTED_TO_spi_lms_external_SS_n,                       --                                     .SS_n
			spi_lms_irq_irq                             => CONNECTED_TO_spi_lms_irq_irq,                             --                          spi_lms_irq.irq
			switch_external_connection_export           => CONNECTED_TO_switch_external_connection_export,           --           switch_external_connection.export
			vectorblox_orca_0_global_interrupts_export  => CONNECTED_TO_vectorblox_orca_0_global_interrupts_export   --  vectorblox_orca_0_global_interrupts.export
		);

