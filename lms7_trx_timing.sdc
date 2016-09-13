#=======================Time setting============================================
set_time_format -unit ns -decimal_places 3 
#=======================Timing parameters===================================
#Propagation delay in stripline ps/inch
set tPD_stripline 		.1803	

#LMS7002
	#LMS_MCLK2 period
set MCLK2_period	6.25
set MCLK1_period  6.25
	#Setup and hold times from datasheet
set LMS7_Tsu	1
set LMS7_Th		.2
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
set LMS7_diq2_max_dly [expr $max_diq2_data_delay + $MCLK2_period/2 - $LMS7_Tsu - $min_mclk2_delay]
set LMS7_diq2_min_dly [expr $min_diq2_data_delay + $LMS7_Th - $min_mclk2_delay]



#FX3
set FX3_period		10

set FX3_tDS 2 
set FX3_tDH 0

#FX3 tRDS tWRS tAS tPES combined to FX3_tSU
set FX3_tSU		2
#FX3 tRDH tWRH tAH tPEH combined to FX3_tH
set FX3_tH 		.5

set FX3_tCO_max 	7
set FX3_tCO_min 	0

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

#=======================Base clocks=============================================
#FPGA pll
create_clock -period "27MHz" 			-name SI_CLK0 					[get_ports SI_CLK0]
create_clock -period "27MHz" 			-name SI_CLK1 					[get_ports SI_CLK1]
create_clock -period "27MHz" 			-name SI_CLK2 					[get_ports SI_CLK2]
create_clock -period "27MHz" 			-name SI_CLK3 					[get_ports SI_CLK3]
create_clock -period "27MHz" 			-name SI_CLK5 					[get_ports SI_CLK5]
create_clock -period "27MHz" 			-name SI_CLK6 					[get_ports SI_CLK6]
create_clock -period "27MHz" 			-name SI_CLK7 					[get_ports SI_CLK7]
create_clock -period "30.72MHz"		-name LMK_CLK					[get_ports LMK_CLK]
#TX pll
create_clock -period $MCLK1_period 	-name LMS_MCLK1 				[get_ports LMS_MCLK1]
#RX pll
create_clock -period $MCLK2_period 	-name LMS_MCLK2				[get_ports LMS_MCLK2]
#FX3 spi clock
create_clock -period "1MHz" 			-name BRDG_SPI_SCLK			[get_ports BRDG_SPI_SCLK]

create_clock -period $FX3_period 	-name FX3_PCLK					[get_ports FX3_PCLK] -waveform {5 10}

#======================Virtual clocks============================================
create_clock -name LMS_LAUNCH_CLK	-period $MCLK2_period
create_clock -name FX3_PCLK_VIRT		-period $FX3_period 	  

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
set_input_delay	-max $LMS7_diq2_max_dly \
						-clock [get_clocks LMS_LAUNCH_CLK] [get_ports {LMS_DIQ2*}]
						
set_input_delay	-min $LMS7_diq2_min_dly \
						-clock [get_clocks LMS_LAUNCH_CLK] [get_ports {LMS_DIQ2*}]						
						
set_input_delay	-max $LMS7_diq2_max_dly \
						-clock [get_clocks LMS_LAUNCH_CLK] \
						-clock_fall [get_ports {LMS_DIQ2*}] -add_delay
											
set_input_delay	-min $LMS7_diq2_min_dly \
						-clock [get_clocks LMS_LAUNCH_CLK] \
						-clock_fall [get_ports {LMS_DIQ2*}] -add_delay
						




#FX3
set_input_delay -clock [get_clocks FX3_PCLK_VIRT] -max $FX3_ctl_in_max_dly [get_ports {FX3_CTL4 FX3_CTL5 FX3_CTL6 FX3_CTL8}]
set_input_delay -clock [get_clocks FX3_PCLK_VIRT] -min $FX3_ctl_in_min_dly [get_ports {FX3_CTL4 FX3_CTL5 FX3_CTL6 FX3_CTL8}]

set_input_delay -clock [get_clocks FX3_PCLK_VIRT] -max $FX3_d_in_max_dly [get_ports {FX3_DQ*}]
set_input_delay -clock [get_clocks FX3_PCLK_VIRT] -min $FX3_d_in_min_dly [get_ports {FX3_DQ*}]


#====================Set Output Delay=============================================
#FX3
set_output_delay -clock [get_clocks FX3_PCLK_VIRT] -max $FX3_ctl_out_max_dly \
								[get_ports {FX3_CTL0 FX3_CTL1 FX3_CTL2 \
												FX3_CTL3 FX3_CTL7 FX3_CTL11 FX3_CTL12}]
set_output_delay -clock [get_clocks FX3_PCLK_VIRT] -min $FX3_ctl_out_min_dly \
								[get_ports {FX3_CTL0 FX3_CTL1 FX3_CTL2 \
								FX3_CTL3 FX3_CTL7 FX3_CTL11 FX3_CTL12}]
								
set_output_delay -clock [get_clocks FX3_PCLK_VIRT] -max $FX3_d_out_max_dly \
								[get_ports {FX3_DQ*}]
set_output_delay -clock [get_clocks FX3_PCLK_VIRT] -min $FX3_d_out_min_dly \
								[get_ports {FX3_DQ*}]						


#====================Asyncronous clocks==========================================

# Set to be mutually exclusive clocks.
set_clock_groups -asynchronous 	-group {SI_CLK0 inst27|DDR2_ctrl_top_inst|ddr2_inst|ddr2_controller_phy_inst|ddr2_phy_inst|ddr2_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[1]} \
											-group {SI_CLK1} \
											-group {SI_CLK2} \
											-group {SI_CLK3} \
											-group {SI_CLK5} \
											-group {SI_CLK6} \
											-group {SI_CLK7} \
											-group {LMK_CLK} \
											-group {BRDG_SPI_SCLK} \
											-group {FX3_PCLK} \
											-group {LMS_MCLK1 inst33|inst35|altpll_component|auto_generated|pll1|clk[0] \
														inst33|inst35|altpll_component|auto_generated|pll1|clk[1]} \
											-group {LMS_MCLK2 LMS_FCLK2 LMS_LATCH_CLK LMS_LAUNCH_CLK}

#============================false paths========================================

#between edege aligned same edge transfers 
#None

#====================Asyncronous clocks==========================================

		
#set false paths between low speed signals
# LED's
set_false_path -from * -to [get_ports FPGA_LED* ]
set_false_path -from * -to [get_ports FX3_LED* ]
set_false_path -from * -to [get_ports FPGA_GPIO*]
set_false_path -from * -to [get_ports TX2_2_LB*]
set_false_path -from * -to [get_ports TX1_2_LB*]
set_false_path -from [get_ports EXT_GND*] -to *
set_false_path -from [get_ports HW_VER*] -to *
set_false_path -from [get_ports BOM_VER*] -to *
set_false_path -from [get_ports ADF_MUXOUT*] -to *
set_false_path -to [get_ports LMS_RESET*]
set_false_path -from [get_ports BRDG_SPI*] -to *
set_false_path -from [get_ports FPGA_SPI0*] -to *
set_false_path -to [get_ports FPGA_SPI0*]
set_false_path -to [get_ports BRDG_SPI*]
set_false_path -to [get_ports FPGA_SPI1*]
#set false paths to output clocks 
#it removes the path from the Unconstrained Paths report, but
#allows it to be used as a clock for output delay analysis
set_false_path -to [get_ports LMS_FCLK1]
set_false_path -to [get_ports LMS_FCLK2]
set_false_path -to [get_ports FPGA_SPI1_SCLK]

