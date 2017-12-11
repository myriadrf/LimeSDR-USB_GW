onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /data2packets_tb/dut0/clk
add wave -noupdate /data2packets_tb/dut0/reset_n
add wave -noupdate -radix unsigned /data2packets_tb/dut0/pct_size
add wave -noupdate -radix hexadecimal /data2packets_tb/dut0/pct_hdr_0
add wave -noupdate -radix hexadecimal /data2packets_tb/dut0/pct_hdr_1
add wave -noupdate -radix hexadecimal /data2packets_tb/dut0/pct_data
add wave -noupdate /data2packets_tb/dut0/pct_data_wrreq
add wave -noupdate /data2packets_tb/dut0/pct_state
add wave -noupdate /data2packets_tb/dut0/pct_wrreq
add wave -noupdate -radix hexadecimal /data2packets_tb/dut0/pct_q
add wave -noupdate /data2packets_tb/dut0/current_state
add wave -noupdate -radix hexadecimal /data2packets_tb/dut0/reg_0
add wave -noupdate -radix hexadecimal /data2packets_tb/dut0/reg_1
add wave -noupdate -radix hexadecimal /data2packets_tb/dut0/reg_2
add wave -noupdate /data2packets_tb/dut0/reg_0_en
add wave -noupdate /data2packets_tb/dut0/reg_1_en
add wave -noupdate /data2packets_tb/dut0/reg_2_en
add wave -noupdate /data2packets_tb/dut0/reg_0_ld
add wave -noupdate /data2packets_tb/dut0/reg_1_ld
add wave -noupdate /data2packets_tb/dut0/reg_2_ld
add wave -noupdate -radix unsigned /data2packets_tb/dut0/pct_data_wr_cnt
add wave -noupdate /data2packets_tb/dut0/pct_data_wr_cnt_en
add wave -noupdate /data2packets_tb/dut0/pct_data_wr_cnt_clr
add wave -noupdate -radix unsigned /data2packets_tb/dut0/pct_end_cnt
add wave -noupdate -radix unsigned /data2packets_tb/dut0/pct_data_wr_cnt_max
add wave -noupdate -radix hexadecimal /data2packets_tb/dut0/pct_end_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {194355 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 142
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
WaveRestoreZoom {0 ps} {515484 ps}
