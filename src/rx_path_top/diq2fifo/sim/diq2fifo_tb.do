onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /diq2fifo_tb/inst1_diq2fifo/clk
add wave -noupdate /diq2fifo_tb/inst1_diq2fifo/reset_n
add wave -noupdate -group {Mode settings} /diq2fifo_tb/inst1_diq2fifo/mode
add wave -noupdate -group {Mode settings} /diq2fifo_tb/inst1_diq2fifo/trxiqpulse
add wave -noupdate -group {Mode settings} /diq2fifo_tb/inst1_diq2fifo/ddr_en
add wave -noupdate -group {Mode settings} /diq2fifo_tb/inst1_diq2fifo/mimo_en
add wave -noupdate -group {Mode settings} /diq2fifo_tb/inst1_diq2fifo/ch_en
add wave -noupdate -group {Mode settings} /diq2fifo_tb/inst1_diq2fifo/fidm
add wave -noupdate -radix hexadecimal /diq2fifo_tb/inst1_diq2fifo/DIQ
add wave -noupdate /diq2fifo_tb/inst1_diq2fifo/fsync
add wave -noupdate /diq2fifo_tb/inst1_diq2fifo/fifo_wfull
add wave -noupdate /diq2fifo_tb/inst1_diq2fifo/fifo_wrreq
add wave -noupdate -radix hexadecimal /diq2fifo_tb/inst1_diq2fifo/fifo_wdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {235968 ps} 0}
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
WaveRestoreZoom {20948 ps} {180298 ps}
