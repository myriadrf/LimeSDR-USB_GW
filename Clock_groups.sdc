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
											-group {*|wfm_player_top_inst2|DDR2_ctrl_top_inst|ddr2_inst|ddr2_controller_phy_inst|ddr2_phy_inst|ddr2_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[1]} \
											-group {*|ddr2_tester_inst2|ddr2_inst|ddr2_controller_phy_inst|ddr2_phy_inst|ddr2_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[1]} 
											