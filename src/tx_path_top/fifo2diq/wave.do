onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fifo2diq_tb/inst0_diq2fifo/inst1_txiq/inst1_txiq_mimo/txiq_mimo_ddr_inst0/clk
add wave -noupdate /fifo2diq_tb/inst0_diq2fifo/inst1_txiq/inst1_txiq_mimo/txiq_mimo_ddr_inst0/reset_n
add wave -noupdate /fifo2diq_tb/inst0_diq2fifo/inst1_txiq/inst1_txiq_mimo/txiq_mimo_ddr_inst0/ch_en
add wave -noupdate /fifo2diq_tb/inst0_diq2fifo/inst1_txiq/inst1_txiq_mimo/txiq_mimo_ddr_inst0/fidm
add wave -noupdate /fifo2diq_tb/inst0_diq2fifo/inst1_txiq/inst1_txiq_mimo/txiq_mimo_ddr_inst0/DIQ_h
add wave -noupdate /fifo2diq_tb/inst0_diq2fifo/inst1_txiq/inst1_txiq_mimo/txiq_mimo_ddr_inst0/DIQ_l
add wave -noupdate /fifo2diq_tb/inst0_diq2fifo/inst1_txiq/inst1_txiq_mimo/txiq_mimo_ddr_inst0/fifo_rdempty
add wave -noupdate /fifo2diq_tb/inst0_diq2fifo/inst1_txiq/inst1_txiq_mimo/txiq_mimo_ddr_inst0/fifo_rdreq
add wave -noupdate /fifo2diq_tb/inst0_diq2fifo/inst1_txiq/inst1_txiq_mimo/txiq_mimo_ddr_inst0/fifo_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {44479 ps} 0}
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
WaveRestoreZoom {0 ps} {194384 ps}
