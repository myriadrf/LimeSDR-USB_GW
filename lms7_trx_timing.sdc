################################################################################
#Time settings
################################################################################
set_time_format -unit ns -decimal_places 3

################################################################################
#Timing parameters
################################################################################
#Propagation delay in stripline ps/inch
set tPD_stripline 		.1803	

#LMS7002
	#LMS_MCLK2 period
set MCLK2_period		6.25
set MCLK1_period  	6.25
	#Setup and hold times from datasheet
set LMS7_Tsu	1 
set LMS7_Th		.3
	#Board parameters			
#Trace lenght in inches
set max_diq2_length 		1.509 
set min_diq2_length 		1.484
set mclk2_length			1.509
#Propagation delays in DIQ2 data lines
set max_diq2_data_delay [expr $max_diq2_length * $tPD_stripline]
set min_diq2_data_delay [expr $min_diq2_length * $tPD_stripline]
#Propagation delay in mclk2 clock line
set max_mclk2_delay		[expr $mclk2_length * $tPD_stripline]
set min_mclk2_delay		[expr $mclk2_length * $tPD_stripline]
	#Calculated expresions
set LMS_DIQ2_max_dly [expr $max_diq2_data_delay + $LMS7_Tsu - $min_mclk2_delay]
set LMS_DIQ2_min_dly [expr $min_diq2_data_delay + $LMS7_Th  - $min_mclk2_delay]


set LMS7_UI 			[expr $MCLK1_period/2]
set LMS7_CLK_OFFSET	[expr $LMS7_UI/2]
set LMS7_DIQ1_SKEW	0.1

set LMS7_DIQ1_max_dly	[expr $LMS7_Tsu*2]
set LMS7_DIQ1_min_dly	[expr -$LMS7_Th*2]

#FX3
set FX3_period		10

set FX3_tDS 2 
set FX3_tDH 0

#FX3 tRDS tWRS tAS tPES combined to FX3_tSU
set FX3_tSU		2
#FX3 tRDH tWRH tAH tPEH combined to FX3_tH
set FX3_tH 		.5

#set FX3_tCO_max 	7
#set FX3_tCO_min 	0

set FX3_tCO_max 	7
set FX3_tCO_min 	2

#set FX3_tCFLG_max 	8
#set FX3_tCFLG_min 	0
set FX3_tCFLG_max 	8
set FX3_tCFLG_min 	0

set FX3_d_in_max_dly [expr $FX3_tCO_max]
set FX3_d_in_min_dly [expr $FX3_tCO_min]

set FX3_ctl_in_max_dly [expr $FX3_tCFLG_max]
set FX3_ctl_in_min_dly [expr $FX3_tCFLG_min]

set FX3_d_out_max_dly [expr $FX3_tDS]
set FX3_d_out_min_dly [expr -$FX3_tDH]

set FX3_ctl_out_max_dly [expr $FX3_tSU]
set FX3_ctl_out_min_dly [expr -$FX3_tH]
################################################################################
#Base clocks
################################################################################
#Si5351C clocks
create_clock -period "27MHz" 			-name SI_CLK0			[get_ports SI_CLK0]
create_clock -period "27MHz" 			-name SI_CLK1			[get_ports SI_CLK1]
create_clock -period "27MHz" 			-name SI_CLK2			[get_ports SI_CLK2]
create_clock -period "27MHz" 			-name SI_CLK3			[get_ports SI_CLK3]
create_clock -period "27MHz" 			-name SI_CLK5			[get_ports SI_CLK5]
create_clock -period "27MHz" 			-name SI_CLK6			[get_ports SI_CLK6]
create_clock -period "27MHz" 			-name SI_CLK7			[get_ports SI_CLK7]
#LMK clock buffer clock
create_clock -period "30.72MHz"		-name LMK_CLK			[get_ports LMK_CLK]
#TX pll
create_clock -period $MCLK1_period 	-name LMS_MCLK1		[get_ports LMS_MCLK1]
#RX pll
create_clock -period $MCLK2_period 	-name LMS_MCLK2		[get_ports LMS_MCLK2]
#FX3 spi clock
create_clock -period "1MHz" 			-name BRDG_SPI_SCLK	[get_ports BRDG_SPI_SCLK]
#FX3 GPIF clock
create_clock -period $FX3_period 	-name FX3_PCLK			[get_ports FX3_PCLK]

################################################################################
#Virtual clocks
################################################################################
create_clock -name LMS_DIQ2_LAUNCH_CLK		-period $MCLK2_period
create_clock -name FX3_PCLK_VIRT				-period $FX3_period 	  

################################################################################
#Generated clocks
################################################################################
#TX PLL
create_generated_clock 	-name  TX_PLLCLK_C0 \
								-source [get_pins inst33|inst35|altpll_component|auto_generated|pll1|inclk[0]] \
								-phase 0 [get_pins inst33|inst35|altpll_component|auto_generated|pll1|clk[0]]
								
create_generated_clock 	-name   TX_PLLCLK_C1 \
								-source [get_pins inst33|inst35|altpll_component|auto_generated|pll1|inclk[0]] \
								-phase 90 [get_pins inst33|inst35|altpll_component|auto_generated|pll1|clk[1]]

create_generated_clock 	-name LMS_DIQ1_LAUNCHCLK_PLL \
								-source [get_pins {inst33|inst35|altpll_component|auto_generated|pll1|clk[1]}] \
								[get_pins {inst33|inst16|combout}]
							
create_generated_clock -name LMS_DIQ1_LAUNCHCLK_DRCT \
								-source [get_ports {LMS_MCLK1}] [get_pins {inst33|inst16|combout}] -add
															
#RX PLL
create_generated_clock -name RX_PLLCLK_C0 \
								-source [get_pins inst32|inst35|altpll_component|auto_generated|pll1|inclk[0]] \
								-phase 0 [get_pins inst32|inst35|altpll_component|auto_generated|pll1|clk[0]]
create_generated_clock -name RX_PLLCLK_C1 \
								-source [get_pins inst32|inst35|altpll_component|auto_generated|pll1|inclk[0]] \
								-phase 90 [get_pins inst32|inst35|altpll_component|auto_generated|pll1|clk[1]]

#NIOS spi
create_generated_clock -name FPGA_SPI0_SCLK \
								-source [get_ports FX3_PCLK] \
								-divide_by 6 \
								[get_registers nios_cpu:inst42|lms_ctr:u0|lms_ctr_spi_lms:spi_lms|SCLK_reg]
								
create_generated_clock -name FPGA_SPI1_SCLK \
								-source [get_ports FX3_PCLK] \
								-divide_by 6 \
								[get_registers nios_cpu:inst42|lms_ctr:u0|lms_ctr_spi_1_ADF:spi_1_adf|SCLK_reg]								


################################################################################
#Clock outputs
################################################################################
#LMS_FCLK1 clock mux
create_generated_clock 	-name LMS_FCLK1_PLL \
								-master [get_clocks {TX_PLLCLK_C0}] \
								-source [get_pins {inst33|inst61|ALTDDIO_OUT_component|auto_generated|ddio_outa[0]|dataout}] \
								[get_ports {LMS_FCLK1}]
								
create_generated_clock 	-name LMS_FCLK1_DRCT \
								-master [get_clocks {LMS_MCLK1}] \
								-source [get_pins {inst33|inst61|ALTDDIO_OUT_component|auto_generated|ddio_outa[0]|dataout}] \
								[get_ports {LMS_FCLK1}]	-add								
								
#LMS_FCLK2 clock 							
create_generated_clock 	-name LMS_FCLK2 \
								-source [get_pins {inst32|inst61|ALTDDIO_OUT_component|auto_generated|ddio_outa[0]|dataout}] \
								[get_ports {LMS_FCLK2}]

								

################################################################################
#Other clock constraints
################################################################################								
derive_clock_uncertainty


################################################################################
#Input constraints
################################################################################
#LMS7
set_input_delay	-max $LMS_DIQ2_max_dly \
						-clock [get_clocks LMS_DIQ2_LAUNCH_CLK] [get_ports {LMS_DIQ2*}]
						
set_input_delay	-min $LMS_DIQ2_min_dly \
						-clock [get_clocks LMS_DIQ2_LAUNCH_CLK] [get_ports {LMS_DIQ2*}]						
						
set_input_delay	-max $LMS_DIQ2_max_dly \
						-clock [get_clocks LMS_DIQ2_LAUNCH_CLK] \
						-clock_fall [get_ports {LMS_DIQ2*}] -add_delay
											
set_input_delay	-min $LMS_DIQ2_min_dly \
						-clock [get_clocks LMS_DIQ2_LAUNCH_CLK] \
						-clock_fall [get_ports {LMS_DIQ2*}] -add_delay
						
#FX3
set_input_delay -clock [get_clocks FX3_PCLK_VIRT] -max $FX3_ctl_in_max_dly [get_ports {FX3_CTL4 FX3_CTL5 FX3_CTL8}]
set_input_delay -clock [get_clocks FX3_PCLK_VIRT] -min $FX3_ctl_in_min_dly [get_ports {FX3_CTL4 FX3_CTL5 FX3_CTL8}]

set_input_delay -clock [get_clocks FX3_PCLK_VIRT] -max $FX3_d_in_max_dly [get_ports {FX3_DQ*}]
set_input_delay -clock [get_clocks FX3_PCLK_VIRT] -min $FX3_d_in_min_dly [get_ports {FX3_DQ*}]						

################################################################################
#Output constraints
################################################################################						
#LMS7						
set_output_delay	-max $LMS7_DIQ1_max_dly \
						-clock [get_clocks LMS_FCLK1_PLL] [get_ports {LMS_DIQ1*}]
						
set_output_delay	-min $LMS7_DIQ1_min_dly \
						-clock [get_clocks LMS_FCLK1_PLL] [get_ports {LMS_DIQ1*}]						
						
set_output_delay	-max $LMS7_DIQ1_max_dly \
						-clock [get_clocks LMS_FCLK1_PLL] \
						-clock_fall [get_ports {LMS_DIQ1*}] -add_delay
											
set_output_delay	-min $LMS7_DIQ1_min_dly \
						-clock [get_clocks LMS_FCLK1_PLL] \
						-clock_fall [get_ports {LMS_DIQ1*}] -add_delay
						
set_output_delay	-max $LMS7_DIQ1_max_dly \
						-clock [get_clocks LMS_FCLK1_DRCT] [get_ports {LMS_DIQ1*}] -add_delay
						
set_output_delay	-min $LMS7_DIQ1_min_dly \
						-clock [get_clocks LMS_FCLK1_DRCT] [get_ports {LMS_DIQ1*}] -add_delay		
						
set_output_delay	-max $LMS7_DIQ1_max_dly \
						-clock [get_clocks LMS_FCLK1_DRCT] \
						-clock_fall [get_ports {LMS_DIQ1*}] -add_delay
											
set_output_delay	-min $LMS7_DIQ1_min_dly \
						-clock [get_clocks LMS_FCLK1_DRCT] \
						-clock_fall [get_ports {LMS_DIQ1*}] -add_delay				
						
#FX3
set_output_delay -clock [get_clocks FX3_PCLK_VIRT] -clock_fall -max $FX3_ctl_out_max_dly \
								[get_ports {FX3_CTL0 FX3_CTL1 FX3_CTL2 \
												FX3_CTL3 FX3_CTL7 FX3_CTL11 FX3_CTL12}]
set_output_delay -clock [get_clocks FX3_PCLK_VIRT] -clock_fall -min $FX3_ctl_out_min_dly \
								[get_ports {FX3_CTL0 FX3_CTL1 FX3_CTL2 \
								FX3_CTL3 FX3_CTL7 FX3_CTL11 FX3_CTL12}]
set_output_delay -clock [get_clocks FX3_PCLK_VIRT] -clock_fall -max $FX3_d_out_max_dly \
								[get_ports {FX3_DQ*}]
set_output_delay -clock [get_clocks FX3_PCLK_VIRT] -clock_fall -min $FX3_d_out_min_dly \
								[get_ports {FX3_DQ*}]	

#set_multicycle_path -setup -from [get_clocks FX3_PCLK_VIRT ] -to [get_clocks FX3_PCLK] 2
set_multicycle_path -hold -from [get_clocks FX3_PCLK_VIRT ] -to [get_clocks FX3_PCLK] 1
								
################################################################################
#Asyncronous clocks
################################################################################
# To clocks that are not related to each other
set_clock_groups -asynchronous 	-group {SI_CLK0} \
											-group {SI_CLK1} \
											-group {SI_CLK2} \
											-group {SI_CLK3} \
											-group {SI_CLK5} \
											-group {SI_CLK6} \
											-group {SI_CLK7} \
											-group {LMK_CLK} \
											-group {BRDG_SPI_SCLK} \
											-group {FX3_PCLK FX3_PCLK_VIRT} \
											-group {LMS_MCLK1 TX_PLLCLK_C0 TX_PLLCLK_C1 LMS_DIQ1_LAUNCHCLK_PLL LMS_FCLK1_PLL} \
											-group {LMS_MCLK2 LMS_FCLK2 RX_PLLCLK_C0 RX_PLLCLK_C1} \
											-group {FPGA_SPI0_SCLK} \
											-group {FPGA_SPI1_SCLK}
											
set_clock_groups	-exclusive 		-group {LMS_DIQ1_LAUNCHCLK_PLL LMS_FCLK1_PLL} \
											-group {LMS_DIQ1_LAUNCHCLK_DRCT LMS_FCLK1_DRCT}	

											
################################################################################
#NIOS constraints
################################################################################
# JTAG Signal Constraints constrain the TCK port											
create_clock -period 10MHz {altera_reserved_tck}
# Cut all paths to and from tck
set_clock_groups -asynchronous -group {altera_reserved_tck}											
# Constrain the TDI port
set_input_delay -clock altera_reserved_tck -clock_fall .1 [get_ports altera_reserved_tdi]
# Constrain the TMS port
set_input_delay -clock altera_reserved_tck -clock_fall .1 [get_ports altera_reserved_tms]
# Constrain the TDO port
set_output_delay -clock altera_reserved_tck -clock_fall .1 [get_ports altera_reserved_tdo]							
											

################################################################################
#Timing exceptions
################################################################################

#Between Center aligned same edge transfers in DIQ1 interface
set_false_path -setup 	-rise_from 	[get_clocks LMS_DIQ1_LAUNCHCLK_PLL] -rise_to \
												[get_clocks LMS_FCLK1_PLL]
set_false_path -setup 	-fall_from 	[get_clocks LMS_DIQ1_LAUNCHCLK_PLL] -fall_to \
												[get_clocks LMS_FCLK1_PLL]
set_false_path -hold 	-rise_from 	[get_clocks LMS_DIQ1_LAUNCHCLK_PLL] -fall_to \
												[get_clocks LMS_FCLK1_PLL]
set_false_path -hold 	-fall_from 	[get_clocks LMS_DIQ1_LAUNCHCLK_PLL] -rise_to \
												[get_clocks LMS_FCLK1_PLL]
												
#Between Center aligned same edge transfers in DIQ1 interface
set_false_path -setup 	-rise_from 	[get_clocks LMS_DIQ1_LAUNCHCLK_DRCT] -rise_to \
												[get_clocks LMS_FCLK1_DRCT]
set_false_path -setup 	-fall_from 	[get_clocks LMS_DIQ1_LAUNCHCLK_DRCT] -fall_to \
												[get_clocks LMS_FCLK1_DRCT]
set_false_path -hold 	-rise_from 	[get_clocks LMS_DIQ1_LAUNCHCLK_DRCT] -fall_to \
												[get_clocks LMS_FCLK1_DRCT]
set_false_path -hold 	-fall_from 	[get_clocks LMS_DIQ1_LAUNCHCLK_DRCT] -rise_to \
												[get_clocks LMS_FCLK1_DRCT]	
	

#Between Center aligned different edge transfers in DIQ2 interface
set_false_path -setup 	-rise_from 	[get_clocks LMS_DIQ2_LAUNCH_CLK] -fall_to \
												[get_clocks RX_PLLCLK_C1]
set_false_path -setup 	-fall_from 	[get_clocks LMS_DIQ2_LAUNCH_CLK] -rise_to \
												[get_clocks RX_PLLCLK_C1]
set_false_path -hold 	-rise_from 	[get_clocks LMS_DIQ2_LAUNCH_CLK] -rise_to \
												[get_clocks RX_PLLCLK_C1]
set_false_path -hold 	-fall_from 	[get_clocks LMS_DIQ2_LAUNCH_CLK] -fall_to \
												[get_clocks RX_PLLCLK_C1]											
	
#set false paths between low speed signals
set_false_path -from * -to [get_ports FPGA_LED*]
set_false_path -from * -to [get_ports FX3_LED*]
set_false_path -from * -to [get_ports FPGA_GPIO*]
set_false_path -from * -to [get_ports TX2_2_LB*]
set_false_path -from * -to [get_ports TX1_2_LB*]
set_false_path -from * -to [get_ports LMS_CORE_LDO_EN]
set_false_path -from * -to [get_ports LMS_RXEN]
set_false_path -from * -to [get_ports LMS_TXEN]
set_false_path -from * -to [get_ports LMS_TXNRX1]
set_false_path -from * -to [get_ports LMS_TXNRX2]
set_false_path -from * -to [get_ports FPGA_I2C_SCL]
set_false_path -from * -to [get_ports FPGA_I2C_SDA]

set_false_path -from [get_ports EXT_GND*] 		-to *
set_false_path -from [get_ports HW_VER*] 			-to *
set_false_path -from [get_ports BOM_VER*] 		-to *
set_false_path -from [get_ports ADF_MUXOUT*] 	-to *
set_false_path -from [get_ports BRDG_SPI*] 		-to *
set_false_path -from [get_ports FPGA_SPI0*] 		-to *
set_false_path -from [get_ports PWR_SRC] 			-to *
set_false_path -from [get_ports FPGA_I2C_SCL] 	-to *
set_false_path -from [get_ports FPGA_I2C_SDA] 	-to *

set_false_path -to [get_ports LMS_RESET*]
set_false_path -to [get_ports FPGA_SPI0*]
set_false_path -to [get_ports BRDG_SPI*]
set_false_path -to [get_ports FPGA_SPI1*]
#set false paths to output clocks 
#it removes the path from the Unconstrained Paths report, but
#allows it to be used as a clock for output delay analysis
set_false_path -to [get_ports LMS_FCLK1]
set_false_path -to [get_ports LMS_FCLK2]
set_false_path -to [get_ports FPGA_SPI0_SCLK]
set_false_path -to [get_ports FPGA_SPI1_SCLK]


