################################################################################
#Time settings
################################################################################
set_time_format -unit ns -decimal_places 3

################################################################################
#Read periphery constraints files
################################################################################
read_sdc LMS7002_timing.sdc


################################################################################
#Timing parameters
################################################################################

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
#FX3 spi clock
create_clock -period "1MHz" 			-name BRDG_SPI_SCLK	[get_ports BRDG_SPI_SCLK]


################################################################################
#Virtual clocks
################################################################################
  

################################################################################
#Generated clocks
################################################################################

#NIOS spi
create_generated_clock 	-name FPGA_SPI0_SCLK_reg \
								-source [get_ports {FX3_PCLK}] \
								-divide_by 6 \
								[get_registers {nios_cpu:inst42|lms_ctr:u0|lms_ctr_spi_lms:spi_lms|SCLK_reg}]
								
create_generated_clock 	-name FPGA_SPI0_SCLK_out \
								-source [get_registers {nios_cpu:inst42|lms_ctr:u0|lms_ctr_spi_lms:spi_lms|SCLK_reg}] \
								[get_ports FPGA_SPI0_SCLK]
								
set_false_path				-to [get_ports FPGA_SPI0_SCLK]
								
create_generated_clock -name FPGA_SPI1_SCLK \
								-source [get_ports FX3_PCLK] \
								-divide_by 6 \
								[get_registers nios_cpu:inst42|lms_ctr:u0|lms_ctr_spi_1_ADF:spi_1_adf|SCLK_reg]								


################################################################################
#Clock outputs
################################################################################


################################################################################
#Other clock constraints
################################################################################								
derive_clock_uncertainty


################################################################################
#Input constraints
################################################################################


#NIOS SPI0
#To overcontrain inputs setup time only for fitter by 10%
if {$::quartus(nameofexecutable) ne "quartus_sta"} {
	set_input_delay -clock [get_clocks FPGA_SPI0_SCLK_out] -max 20.9 [get_ports {FPGA_SPI0_MISO}] -clock_fall
	set_input_delay -clock [get_clocks FPGA_SPI0_SCLK_out] -min 16.2 [get_ports {FPGA_SPI0_MISO}] -clock_fall
} else {
	set_input_delay -clock [get_clocks FPGA_SPI0_SCLK_out] -max 19.0 [get_ports {FPGA_SPI0_MISO}] -clock_fall
	set_input_delay -clock [get_clocks FPGA_SPI0_SCLK_out] -min 16.2 [get_ports {FPGA_SPI0_MISO}] -clock_fall
}


################################################################################
#Output constraints
################################################################################						
							
						
#NIOS SPI				
set_output_delay -clock [get_clocks FPGA_SPI0_SCLK_out] -max 15 [get_ports {FPGA_SPI0_MOSI}] 
set_output_delay -clock [get_clocks FPGA_SPI0_SCLK_out] -min -15 [get_ports {FPGA_SPI0_MOSI}]	

#set_multicycle_path -setup -from [get_clocks FX3_PCLK_VIRT ] -to [get_clocks FX3_PCLK] 2
#set_multicycle_path -hold -from [get_clocks FX3_PCLK_VIRT ] -to [get_clocks FX3_PCLK] 1
								
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
											-group {LMS_MCLK1} \
                                 -group {LMS_MCLK1_5MHZ} \
											-group {TX_PLLCLK_C0 } \
											-group {TX_PLLCLK_C1 LMS_FCLK1_PLL} \
                                 -group {LMS_FCLK1_DRCT } \
                                 -group {LMS_MCLK2} \
											-group {LMS_MCLK2_5MHZ} \
											-group {RX_PLLCLK_C0} \
											-group {RX_PLLCLK_C1 } \
                                 -group {LMS_FCLK2_PLL} \
                                 -group {LMS_FCLK2_DRCT } \
											-group {FX3_PCLK FPGA_SPI0_SCLK_reg FPGA_SPI0_SCLK_out} \
											-group {inst27|DDR2_ctrl_top_inst|ddr2_inst|ddr2_controller_phy_inst|ddr2_phy_inst|ddr2_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[1]} \
											-group {inst46|ddr2_inst|ddr2_controller_phy_inst|ddr2_phy_inst|ddr2_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[1]} 
											

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
	
#Multicycle paths for NIOS SPI
set_multicycle_path -setup -end -from [get_clocks {FPGA_SPI0_SCLK_out}] -to [get_clocks {FX3_PCLK}] [expr 3]
set_multicycle_path -hold -end -from [get_clocks {FPGA_SPI0_SCLK_out}] -to [get_clocks {FX3_PCLK}] [expr 5]

set_multicycle_path -setup -start -from [get_clocks FX3_PCLK] -to [get_clocks FPGA_SPI0_SCLK_out] 3
set_multicycle_path -hold -start -from [get_clocks FX3_PCLK] -to [get_clocks FPGA_SPI0_SCLK_out] 5		
	
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
set_false_path -from [get_ports PWR_SRC] 			-to *
set_false_path -from [get_ports FPGA_I2C_SCL] 	-to *
set_false_path -from [get_ports FPGA_I2C_SDA] 	-to *
set_false_path -from [get_ports FPGA_GPIO*] 
set_false_path -from [get_ports LM75_OS*]        

set_false_path -to [get_ports LMS_RESET*]
set_false_path -to [get_ports BRDG_SPI*]
set_false_path -to [get_ports FPGA_SPI1*]
set_false_path -to [get_ports FAN_CTRL*]

#To be fixed
set_false_path -to [get_ports FPGA_SPI0_LMS_SS*]


set_multicycle_path 	-from [get_registers {rx_path_top:inst28|smpl_cnt:smpl_cnt_inst3|lpm_cnt_inst:lpm_cnt_inst_inst0|lpm_counter:LPM_COUNTER_component|cntr_f5l:auto_generated|counter_reg_bit[*]}] \
							-to [get_registers {rx_path_top:inst28|smpl_cnt:smpl_cnt_inst3|lpm_cnt_inst:lpm_cnt_inst_inst0|lpm_counter:LPM_COUNTER_component|cntr_f5l:auto_generated|counter_reg_bit[*]}] \
							-setup -end 2
							
set_multicycle_path 	-from [get_registers {rx_path_top:inst28|smpl_cnt:smpl_cnt_inst3|lpm_cnt_inst:lpm_cnt_inst_inst0|lpm_counter:LPM_COUNTER_component|cntr_f5l:auto_generated|counter_reg_bit[*]}] \
							-to [get_registers {rx_path_top:inst28|smpl_cnt:smpl_cnt_inst3|lpm_cnt_inst:lpm_cnt_inst_inst0|lpm_counter:LPM_COUNTER_component|cntr_f5l:auto_generated|counter_reg_bit[*]}] \
							-hold -end 1
							
							
set_multicycle_path 	-from [get_registers {rx_path_top:inst28|smpl_cnt:smpl_cnt_inst4|lpm_cnt_inst:lpm_cnt_inst_inst0|lpm_counter:LPM_COUNTER_component|cntr_f5l:auto_generated|counter_reg_bit[*]}] \
							-to [get_registers {rx_path_top:inst28|smpl_cnt:smpl_cnt_inst4|lpm_cnt_inst:lpm_cnt_inst_inst0|lpm_counter:LPM_COUNTER_component|cntr_f5l:auto_generated|counter_reg_bit[*]}] \
							-setup -end 2
							
set_multicycle_path 	-from [get_registers {rx_path_top:inst28|smpl_cnt:smpl_cnt_inst4|lpm_cnt_inst:lpm_cnt_inst_inst0|lpm_counter:LPM_COUNTER_component|cntr_f5l:auto_generated|counter_reg_bit[*]}] \
							-to [get_registers {rx_path_top:inst28|smpl_cnt:smpl_cnt_inst4|lpm_cnt_inst:lpm_cnt_inst_inst0|lpm_counter:LPM_COUNTER_component|cntr_f5l:auto_generated|counter_reg_bit[*]}] \
							-hold -end 1



#set false paths to output clocks 
#it removes the path from the Unconstrained Paths report, but
#allows it to be used as a clock for output delay analysis
set_false_path -to [get_ports LMS_FCLK1]
set_false_path -to [get_ports LMS_FCLK2]
set_false_path -to [get_ports FPGA_SPI1_SCLK]

set_false_path -to [get_registers tstcfg:inst39|dout_reg[*]]

set_false_path -from [get_registers {tstcfg:inst39|mem[3][5]}]
set_false_path -from [get_registers {fpgacfg:inst24|mem[13][2]}]
set_false_path -from [get_registers {ddr2_tester:inst46|ddr2_traffic_gen:traffic_gen_inst|ddr2_traffic_gen_mm_traffic_generator_0:mm_traffic_generator_0|driver_avl_use_be_avl_use_burstbegin:traffic_generator_0|pnf_per_bit_persist[*]}]
set_false_path -from [get_registers {wfm_player_top:inst27|DDR2_ctrl_top:DDR2_ctrl_top_inst|ddr2_traffic_gen:traffic_gen_inst|ddr2_traffic_gen_mm_traffic_generator_0:mm_traffic_generator_0|driver_avl_use_be_avl_use_burstbegin:traffic_generator_0|pnf_per_bit_persist[*]}]
set_false_path -from [get_registers {ddr2_tester:inst46|ddr2_traffic_gen:traffic_gen_inst|ddr2_traffic_gen_mm_traffic_generator_0:mm_traffic_generator_0|driver_avl_use_be_avl_use_burstbegin:traffic_generator_0|driver_fsm_avl_use_be_avl_use_burstbegin:real_driver.driver_fsm_inst|stage.TIMEOUT}]
set_false_path -from [get_registers {ddr2_tester:inst46|ddr2_traffic_gen:traffic_gen_inst|ddr2_traffic_gen_mm_traffic_generator_0:mm_traffic_generator_0|driver_avl_use_be_avl_use_burstbegin:traffic_generator_0|driver_fsm_avl_use_be_avl_use_burstbegin:real_driver.driver_fsm_inst|stage.TEST_COMPLETE}]
set_false_path -from [get_registers *sync_reg0\[*\]]




