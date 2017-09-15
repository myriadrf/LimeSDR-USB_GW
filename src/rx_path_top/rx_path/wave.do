onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /rx_path_top_tb/inst1_rx_path_top/clk
add wave -noupdate /rx_path_top_tb/inst1_rx_path_top/reset_n
add wave -noupdate /rx_path_top_tb/inst1_rx_path_top/pct_fifo_wrreq
add wave -noupdate -radix hexadecimal /rx_path_top_tb/inst1_rx_path_top/pct_fifo_wdata
add wave -noupdate -radix unsigned /rx_path_top_tb/wrreq_cnt
add wave -noupdate /rx_path_top_tb/wrreq_cnt_max
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20165000 ps} 0}
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
WaveRestoreZoom {0 ps} {252 us}
