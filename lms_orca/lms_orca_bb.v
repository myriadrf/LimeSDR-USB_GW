
module lms_orca (
	clk_clk,
	controlled_reset_external_connection_export,
	exfifo_if_d_export,
	exfifo_if_rd_export,
	exfifo_if_rdempty_export,
	exfifo_of_d_export,
	exfifo_of_wr_export,
	exfifo_of_wrfull_export,
	exfifo_rst_export,
	i2c_opencores_0_interrupt_sender_irq,
	in_reset_reset_n,
	leds_external_connection_export,
	lms_ctr_gpio_external_connection_export,
	scl_exp_export,
	sda_exp_export,
	spi_1_dac_external_MISO,
	spi_1_dac_external_MOSI,
	spi_1_dac_external_SCLK,
	spi_1_dac_external_SS_n,
	spi_1_dac_irq_irq,
	spi_lms_external_MISO,
	spi_lms_external_MOSI,
	spi_lms_external_SCLK,
	spi_lms_external_SS_n,
	spi_lms_irq_irq,
	switch_external_connection_export,
	vectorblox_orca_0_global_interrupts_export);	

	input		clk_clk;
	output		controlled_reset_external_connection_export;
	input	[31:0]	exfifo_if_d_export;
	output		exfifo_if_rd_export;
	input		exfifo_if_rdempty_export;
	output	[31:0]	exfifo_of_d_export;
	output		exfifo_of_wr_export;
	input		exfifo_of_wrfull_export;
	output		exfifo_rst_export;
	output		i2c_opencores_0_interrupt_sender_irq;
	input		in_reset_reset_n;
	output	[7:0]	leds_external_connection_export;
	output	[3:0]	lms_ctr_gpio_external_connection_export;
	inout		scl_exp_export;
	inout		sda_exp_export;
	input		spi_1_dac_external_MISO;
	output		spi_1_dac_external_MOSI;
	output		spi_1_dac_external_SCLK;
	output	[1:0]	spi_1_dac_external_SS_n;
	output		spi_1_dac_irq_irq;
	input		spi_lms_external_MISO;
	output		spi_lms_external_MOSI;
	output		spi_lms_external_SCLK;
	output	[4:0]	spi_lms_external_SS_n;
	output		spi_lms_irq_irq;
	input	[7:0]	switch_external_connection_export;
	input	[0:0]	vectorblox_orca_0_global_interrupts_export;
endmodule
