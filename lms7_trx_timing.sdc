#=======================Time setting============================================
set_time_format -unit ns -decimal_places 3 

#=======================Base clocks=============================================
#FPGA pll
create_clock -period "27MHz" 		-name SI_CLK0 					[get_ports SI_CLK0]
#TX pll
create_clock -period "160MHz" 	-name MCLK1TX_20 				[get_ports LMS_MCLK1]
#RX pll
create_clock -period "160MHz" 	-name MCLK2RX20				[get_ports LMS_MCLK2]
#FX3 spi clock
create_clock -period "1MHz" 		-name BRDG_SPI_SCLK			[get_ports BRDG_SPI_SCLK]

create_clock -period "99.98 MHz" -waveform {5.227 10.454} 	[get_ports FX3_PCLK] 

#======================Virtual clocks============================================

create_clock -period "99.98 MHz" 	-name fx3_clk_virt

#======================Generated clocks==========================================

#None

#====================Other clock constraints=====================================

derive_pll_clocks
derive_clock_uncertainty

#====================Set Input Delay=============================================

set_input_delay -clock [get_clocks fx3_clk_virt] -max 8.225 [get_ports {FX3_DQ*}]
set_input_delay -clock [get_clocks fx3_clk_virt] -min 0.225 [get_ports {FX3_DQ*}] -add_delay

set_output_delay -clock [get_clocks fx3_clk_virt] -max 2.5 [get_ports {FX3_DQ* FX3_CTL1 FX3_CTL7}]
set_output_delay -clock [get_clocks fx3_clk_virt] -min 0.75 [get_ports {FX3_DQ* FX3_CTL1 FX3_CTL7}] -add_delay

#====================Asyncronous clocks==========================================

# Set to be mutually exclusive clocks.
set_clock_groups -asynchronous 	-group {SI_CLK0} \
											-group {BRDG_SPI_SCLK} \
											-group {MCLK1TX_20} \
											-group {MCLK2RX20}

#============================false paths========================================
set_false_path -from [get_clocks BRDG_SPI_SCLK] -to *

#between edege aligned same edge transfers 
#None

#set false paths between low speed signals
# LED's
set_false_path -from * -to [get_ports FPGA_LED* ]
set_false_path -from * -to [get_ports FPGA_GPIO*]
set_false_path -from [get_ports EXT_GND*] -to *