onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group p2d_sync_fsm /packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/clk
add wave -noupdate -expand -group p2d_sync_fsm /packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/reset_n
add wave -noupdate -expand -group p2d_sync_fsm -radix hexadecimal /packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/smpl_nr
add wave -noupdate -expand -group p2d_sync_fsm -radix hexadecimal /packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/pct_hdr_0
add wave -noupdate -expand -group p2d_sync_fsm /packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/pct_hdr_0_valid
add wave -noupdate -expand -group p2d_sync_fsm -radix hexadecimal /packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/pct_hdr_1
add wave -noupdate -expand -group p2d_sync_fsm /packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/pct_hdr_1_valid
add wave -noupdate -expand -group p2d_sync_fsm /packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/pct_data_clr_n
add wave -noupdate -expand -group p2d_sync_fsm /packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/pct_buff_rdy
add wave -noupdate -expand -group p2d_sync_fsm -expand /packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/pct_buff_rd_en
add wave -noupdate -expand -group p2d_sync_fsm /packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/current_state
add wave -noupdate -expand -group p2d_sync_fsm -childformat {{/packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/smpl_nr_array(0) -radix hexadecimal} {/packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/smpl_nr_array(1) -radix hexadecimal} {/packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/smpl_nr_array(2) -radix hexadecimal} {/packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/smpl_nr_array(3) -radix hexadecimal}} -subitemconfig {/packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/smpl_nr_array(0) {-height 15 -radix hexadecimal} /packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/smpl_nr_array(1) {-height 15 -radix hexadecimal} /packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/smpl_nr_array(2) {-height 15 -radix hexadecimal} /packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/smpl_nr_array(3) {-height 15 -radix hexadecimal}} /packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/smpl_nr_array
add wave -noupdate -expand -group p2d_sync_fsm /packets2data_tb/packets2data_dut0/p2d_sync_fsm_inst2/pct_smpl_nr_equal
add wave -noupdate -expand -group p2d_rd_fsm /packets2data_tb/packets2data_dut0/p2d_rd_fsm_inst3/clk
add wave -noupdate -expand -group p2d_rd_fsm /packets2data_tb/packets2data_dut0/p2d_rd_fsm_inst3/reset_n
add wave -noupdate -expand -group p2d_rd_fsm /packets2data_tb/packets2data_dut0/p2d_rd_fsm_inst3/pct_data_buff_full
add wave -noupdate -expand -group p2d_rd_fsm /packets2data_tb/packets2data_dut0/p2d_rd_fsm_inst3/pct_data_rdreq
add wave -noupdate -expand -group p2d_rd_fsm /packets2data_tb/packets2data_dut0/p2d_rd_fsm_inst3/pct_data_rdstate
add wave -noupdate -expand -group p2d_rd_fsm /packets2data_tb/packets2data_dut0/p2d_rd_fsm_inst3/pct_buff_rdy
add wave -noupdate -expand -group p2d_rd_fsm /packets2data_tb/packets2data_dut0/p2d_rd_fsm_inst3/rd_fsm_rdy
add wave -noupdate -expand -group p2d_rd_fsm /packets2data_tb/packets2data_dut0/p2d_rd_fsm_inst3/current_state
add wave -noupdate -expand -group p2d_clr_fsm /packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/clk
add wave -noupdate -expand -group p2d_clr_fsm /packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/reset_n
add wave -noupdate -expand -group p2d_clr_fsm -radix hexadecimal /packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/smpl_nr
add wave -noupdate -expand -group p2d_clr_fsm -radix hexadecimal /packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/pct_hdr_0
add wave -noupdate -expand -group p2d_clr_fsm /packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/pct_hdr_0_valid
add wave -noupdate -expand -group p2d_clr_fsm -radix hexadecimal /packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/pct_hdr_1
add wave -noupdate -expand -group p2d_clr_fsm /packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/pct_hdr_1_valid
add wave -noupdate -expand -group p2d_clr_fsm -expand /packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/pct_data_clr_n
add wave -noupdate -expand -group p2d_clr_fsm /packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/pct_data_clr_dis
add wave -noupdate -expand -group p2d_clr_fsm /packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/pct_buff_rdy
add wave -noupdate -expand -group p2d_clr_fsm /packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/pct_smpl_nr_less
add wave -noupdate -expand -group p2d_clr_fsm -childformat {{/packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/smpl_nr_array(0) -radix hexadecimal} {/packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/smpl_nr_array(1) -radix hexadecimal} {/packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/smpl_nr_array(2) -radix hexadecimal} {/packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/smpl_nr_array(3) -radix hexadecimal}} -expand -subitemconfig {/packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/smpl_nr_array(0) {-height 15 -radix hexadecimal} /packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/smpl_nr_array(1) {-height 15 -radix hexadecimal} /packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/smpl_nr_array(2) {-height 15 -radix hexadecimal} /packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/smpl_nr_array(3) {-height 15 -radix hexadecimal}} /packets2data_tb/packets2data_dut0/p2d_clr_fsm_inst1/smpl_nr_array
add wave -noupdate -radix hexadecimal /packets2data_tb/packets2data_dut0/pct_smpl_mux
add wave -noupdate /packets2data_tb/packets2data_dut0/gen_fifo(0)/fifo_inst_isntx/rdreq
add wave -noupdate -radix hexadecimal /packets2data_tb/packets2data_dut0/gen_fifo(0)/fifo_inst_isntx/q
add wave -noupdate -expand /packets2data_tb/packets2data_dut0/instx_q_valid
add wave -noupdate -radix hexadecimal /packets2data_tb/packets2data_dut0/smpl_buff_q
add wave -noupdate /packets2data_tb/packets2data_dut0/smpl_buff_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {717057 ps} 0}
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
WaveRestoreZoom {427728 ps} {2082752 ps}
