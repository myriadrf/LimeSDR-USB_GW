################################################################################
#Time settings
################################################################################
set_time_format -unit ns -decimal_places 3

################################################################################
#Timing parameters
################################################################################

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

#FX3 spi clock
create_clock -period "1MHz" 			-name BRDG_SPI_SCLK	[get_ports BRDG_SPI_SCLK]
#FX3 GPIF clock
create_clock -period $FX3_period 	-name FX3_PCLK			[get_ports FX3_PCLK]

################################################################################
#Virtual clocks
################################################################################
create_clock -name FX3_PCLK_VIRT				-period $FX3_period	

################################################################################
#Input constraints
################################################################################
#FX3
set_input_delay -clock [get_clocks FX3_PCLK_VIRT] \
-max $FX3_ctl_in_max_dly [get_ports {FX3_CTL4 FX3_CTL5 FX3_CTL8}] \
-clock_fall
set_input_delay -clock [get_clocks FX3_PCLK_VIRT] \
-min $FX3_ctl_in_min_dly [get_ports {FX3_CTL4 FX3_CTL5 FX3_CTL8}] \
-clock_fall

set_input_delay -clock [get_clocks FX3_PCLK_VIRT] \
-max $FX3_d_in_max_dly [get_ports {FX3_DQ*}] \
-clock_fall
set_input_delay -clock [get_clocks FX3_PCLK_VIRT] \
-min $FX3_d_in_min_dly [get_ports {FX3_DQ*}] \
-clock_fall

################################################################################
#Output constraints
################################################################################		
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