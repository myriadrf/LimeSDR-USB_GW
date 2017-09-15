onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {RX sample nr} /tx_path_top_tb/clk2
add wave -noupdate -expand -group {RX sample nr} /tx_path_top_tb/reset_n
add wave -noupdate -expand -group {RX sample nr} -radix hexadecimal /tx_path_top_tb/rx_sample_nr
add wave -noupdate -expand -group {Ext fifo buff wr side} /tx_path_top_tb/fifo_inst_isnt0/wrclk
add wave -noupdate -expand -group {Ext fifo buff wr side} /tx_path_top_tb/fifo_inst_isnt0/wrreq
add wave -noupdate -expand -group {Ext fifo buff wr side} -radix hexadecimal /tx_path_top_tb/fifo_inst_isnt0/data
add wave -noupdate -group p2d_wr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/clk
add wave -noupdate -group p2d_wr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/reset_n
add wave -noupdate -group p2d_wr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/in_pct_wrreq
add wave -noupdate -group p2d_wr_fsm -radix hexadecimal /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/in_pct_data
add wave -noupdate -group p2d_wr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_hdr_0
add wave -noupdate -group p2d_wr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_hdr_0_valid
add wave -noupdate -group p2d_wr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_hdr_1
add wave -noupdate -group p2d_wr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_hdr_1_valid
add wave -noupdate -group p2d_wr_fsm -radix hexadecimal /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data
add wave -noupdate -group p2d_wr_fsm -radix hexadecimal -childformat {{/tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq(3) -radix hexadecimal} {/tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq(2) -radix hexadecimal} {/tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq(1) -radix hexadecimal} {/tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq(0) -radix hexadecimal}} -subitemconfig {/tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq(3) {-height 15 -radix hexadecimal} /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq(2) {-height 15 -radix hexadecimal} /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq(1) {-height 15 -radix hexadecimal} /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq(0) {-height 15 -radix hexadecimal}} /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/pct_data_wrreq
add wave -noupdate -group p2d_wr_fsm -radix unsigned /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/wr_cnt
add wave -noupdate -group p2d_wr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_wr_fsm_inst0/wr_cnt_end
add wave -noupdate -group p2d_clr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/clk
add wave -noupdate -group p2d_clr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/reset_n
add wave -noupdate -group p2d_clr_fsm -radix unsigned /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/pct_size
add wave -noupdate -group p2d_clr_fsm -radix hexadecimal /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/smpl_nr
add wave -noupdate -group p2d_clr_fsm -radix hexadecimal /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/pct_hdr_0
add wave -noupdate -group p2d_clr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/pct_hdr_0_valid
add wave -noupdate -group p2d_clr_fsm -radix hexadecimal /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/pct_hdr_1
add wave -noupdate -group p2d_clr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/pct_hdr_1_valid
add wave -noupdate -group p2d_clr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/pct_data_clr_n
add wave -noupdate -group p2d_clr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/pct_data_clr_dis
add wave -noupdate -group p2d_clr_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/pct_buff_rdy
add wave -noupdate -group p2d_clr_fsm -childformat {{/tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/smpl_nr_array(0) -radix hexadecimal} {/tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/smpl_nr_array(1) -radix hexadecimal} {/tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/smpl_nr_array(2) -radix hexadecimal} {/tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/smpl_nr_array(3) -radix hexadecimal}} -expand -subitemconfig {/tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/smpl_nr_array(0) {-height 15 -radix hexadecimal} /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/smpl_nr_array(1) {-height 15 -radix hexadecimal} /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/smpl_nr_array(2) {-height 15 -radix hexadecimal} /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/smpl_nr_array(3) {-height 15 -radix hexadecimal}} /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_clr_fsm_inst1/smpl_nr_array
add wave -noupdate -expand -group p2d_rd_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_rd_fsm_inst3/clk
add wave -noupdate -expand -group p2d_rd_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_rd_fsm_inst3/reset_n
add wave -noupdate -expand -group p2d_rd_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_rd_fsm_inst3/pct_size
add wave -noupdate -expand -group p2d_rd_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_rd_fsm_inst3/pct_data_rdreq
add wave -noupdate -expand -group p2d_rd_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_rd_fsm_inst3/pct_data_rdstate
add wave -noupdate -expand -group p2d_rd_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_rd_fsm_inst3/pct_buff_rdy
add wave -noupdate -expand -group p2d_rd_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_rd_fsm_inst3/rd_fsm_rdy
add wave -noupdate -expand -group p2d_rd_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_rd_fsm_inst3/current_state
add wave -noupdate -expand -group p2d_rd_fsm -radix unsigned /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_rd_fsm_inst3/rd_cnt
add wave -noupdate -expand -group p2d_rd_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_rd_fsm_inst3/rd_end
add wave -noupdate /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_rd_fsm_inst3/pct_data_buff_full
add wave -noupdate -expand -group diq2fifo /tx_path_top_tb/tx_path_top_inst0/diq2fifo_inst1/clk
add wave -noupdate -expand -group diq2fifo -radix unsigned /tx_path_top_tb/tx_path_top_inst0/diq2fifo_inst1/DIQ
add wave -noupdate -expand -group diq2fifo /tx_path_top_tb/tx_path_top_inst0/diq2fifo_inst1/fsync
add wave -noupdate -expand -group p2d_sync_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_sync_fsm_inst2/clk
add wave -noupdate -expand -group p2d_sync_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_sync_fsm_inst2/reset_n
add wave -noupdate -expand -group p2d_sync_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_sync_fsm_inst2/pct_smpl_nr_equal
add wave -noupdate -expand -group p2d_sync_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_sync_fsm_inst2/pct_buff_rdy
add wave -noupdate -expand -group p2d_sync_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_sync_fsm_inst2/mode
add wave -noupdate -expand -group p2d_sync_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_sync_fsm_inst2/trxiqpulse
add wave -noupdate -expand -group p2d_sync_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_sync_fsm_inst2/ddr_en
add wave -noupdate -expand -group p2d_sync_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_sync_fsm_inst2/mimo_en
add wave -noupdate -expand -group p2d_sync_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_sync_fsm_inst2/ch_en
add wave -noupdate -expand -group p2d_sync_fsm /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_sync_fsm_inst2/sample_width
add wave -noupdate -radix unsigned /tx_path_top_tb/tx_path_top_inst0/packets2data_top_inst0/packets2data_inst0/p2d_sync_fsm_inst2/sync_cnt_max
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15168000 ps} 0}
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
WaveRestoreZoom {14843736 ps} {15983198 ps}
bookmark add wave bookmark0 {{0 ps} {120814 ps}} 0
