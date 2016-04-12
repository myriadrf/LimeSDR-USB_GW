#=======================Time setting============================================
set_time_format -unit ns -decimal_places 3 
#=======================Timing parameters===================================
#LMS7002
	#LMS_MCLK2 period
set MCLK2_period	6.25
set MCLK1_period	6.25
	#Setup and hold times from datasheet
set LMS7_Tsu	1
set LMS7_Th		.2
	#Calculated expresions
set LMS7_max_dly [expr $MCLK2_period/4 - $LMS7_Tsu]
set LMS7_min_dly [expr $LMS7_Th - $MCLK2_period/4]
#=======================Base clocks=============================================
#FPGA pll
create_clock -period "27MHz" 			-name SI_CLK0 					[get_ports SI_CLK0]
#TX pll
create_clock -period $MCLK1_period 	-name LMS_MCLK1 				[get_ports LMS_MCLK1]
#RX pll
create_clock -period $MCLK2_period 	-name LMS_MCLK2				[get_ports LMS_MCLK2]
#FX3 spi clock
create_clock -period "1MHz" 			-name BRDG_SPI_SCLK			[get_ports BRDG_SPI_SCLK]

create_clock -period "99.98 MHz" 	-waveform {5.227 10.454} 	[get_ports FX3_PCLK] 

#======================Virtual clocks============================================
create_clock -name LMS_LAUNCH_CLK	-period $MCLK2_period
create_clock -period "99.98 MHz" 	-name fx3_clk_virt

#======================Generated clocks==========================================
create_generated_clock -name LMS_FCLK2 \
								-source [get_pins inst32|inst35|altpll_component|auto_generated|pll1|inclk[0]] \
								-phase 0 [get_pins inst32|inst35|altpll_component|auto_generated|pll1|clk[0]]
create_generated_clock -name LMS_LATCH_CLK \
								-source [get_pins inst32|inst35|altpll_component|auto_generated|pll1|inclk[0]] \
								-phase 90 [get_pins inst32|inst35|altpll_component|auto_generated|pll1|clk[1]]

#====================Other clock constraints=====================================
derive_pll_clocks
derive_clock_uncertainty

#====================Set Input Delay=============================================
#LMS7
set_input_delay	-max $LMS7_max_dly \
						-clock [get_clocks LMS_LAUNCH_CLK] [get_ports {LMS_DIQ2*}]
						
set_input_delay	-max $LMS7_max_dly \
						-clock [get_clocks LMS_LAUNCH_CLK] \
						-clock_fall [get_ports {LMS_DIQ2*}] -add_delay
						
set_input_delay	-min $LMS7_min_dly \
						-clock [get_clocks LMS_LAUNCH_CLK] [get_ports {LMS_DIQ2*}] -add_delay
						
set_input_delay	-min $LMS7_min_dly \
						-clock [get_clocks LMS_LAUNCH_CLK] \
						-clock_fall [get_ports {LMS_DIQ2*}] -add_delay

#FX3
set_input_delay -clock [get_clocks fx3_clk_virt] -max 8.225 [get_ports {FX3_DQ*}]
set_input_delay -clock [get_clocks fx3_clk_virt] -min 0.225 [get_ports {FX3_DQ*}] -add_delay

#====================Set Output Delay=============================================
#FX3
set_output_delay -clock [get_clocks fx3_clk_virt] -max 2.5 [get_ports {FX3_DQ* FX3_CTL1 FX3_CTL7}]
set_output_delay -clock [get_clocks fx3_clk_virt] -min 0.75 [get_ports {FX3_DQ* FX3_CTL1 FX3_CTL7}] -add_delay

#====================Asyncronous clocks==========================================

# Set to be mutually exclusive clocks.
set_clock_groups -asynchronous 	-group {SI_CLK0} \
											-group {BRDG_SPI_SCLK} \
											-group {LMS_MCLK1} \
											-group {LMS_MCLK2}

#============================false paths========================================
set_false_path -from [get_clocks BRDG_SPI_SCLK] -to *

#between edege aligned same edge transfers 
#None

#set false paths between low speed signals
# LED's
set_false_path -from * -to [get_ports FPGA_LED* ]
set_false_path -from * -to [get_ports FPGA_GPIO*]
set_false_path -from [get_ports EXT_GND*] -to *