onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {RX sample nr} /tx_path_top_tb/clk2
add wave -noupdate -expand -group {RX sample nr} /tx_path_top_tb/reset_n
add wave -noupdate -expand -group {RX sample nr} -radix hexadecimal /tx_path_top_tb/rx_sample_nr
add wave -noupdate -expand -group {Ext fifo buff wr side} /tx_path_top_tb/fifo_inst_isnt0/wrclk
add wave -noupdate -expand -group {Ext fifo buff wr side} /tx_path_top_tb/fifo_inst_isnt0/wrreq
add wave -noupdate -expand -group {Ext fifo buff wr side} -radix hexadecimal /tx_path_top_tb/fifo_inst_isnt0/data
add wave -noupdate -expand -group p2d_wr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/clk
add wave -noupdate -expand -group p2d_wr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/reset_n
add wave -noupdate -expand -group p2d_wr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/in_pct_wrreq
add wave -noupdate -expand -group p2d_wr_fsm -radix hexadecimal /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/in_pct_data
add wave -noupdate -expand -group p2d_wr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_hdr_0
add wave -noupdate -expand -group p2d_wr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_hdr_0_valid
add wave -noupdate -expand -group p2d_wr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_hdr_1
add wave -noupdate -expand -group p2d_wr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_hdr_1_valid
add wave -noupdate -expand -group p2d_wr_fsm -radix hexadecimal /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data
add wave -noupdate -expand -group p2d_wr_fsm -radix hexadecimal -childformat {{/tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq(3) -radix hexadecimal} {/tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq(2) -radix hexadecimal} {/tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq(1) -radix hexadecimal} {/tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq(0) -radix hexadecimal}} -subitemconfig {/tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq(3) {-radix hexadecimal} /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq(2) {-radix hexadecimal} /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq(1) {-radix hexadecimal} /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq(0) {-radix hexadecimal}} /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq
add wave -noupdate -expand -group p2d_wr_fsm -radix unsigned /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/wr_cnt
add wave -noupdate -expand -group p2d_wr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/wr_cnt_end
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {11161456 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {27145094 ps}
bookmark add wave bookmark0 {{0 ps} {120814 ps}} 0
