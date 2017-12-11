onerror {resume}
quietly virtual signal -install /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0 { /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/data32_in_reg(11 downto 0)} 00
quietly virtual signal -install /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0 { /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/data32_in_reg(23 downto 12)} 01
quietly virtual signal -install /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0 { (context /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0 )( data32_in(3 downto 0) & data32_in_reg(31 downto 24) )} 02
quietly virtual signal -install /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0 { /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/data32_in(15 downto 4)} 04
quietly WaveActivateNextPane {} 0
add wave -noupdate /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/clk
add wave -noupdate /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/reset_n
add wave -noupdate /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/data_in_wrreq
add wave -noupdate /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/data32_in
add wave -noupdate /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/data64_out
add wave -noupdate /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/data_out_valid
add wave -noupdate /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/word64_0
add wave -noupdate /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/word64_1
add wave -noupdate /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/word64_0_valid
add wave -noupdate /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/word64_1_valid
add wave -noupdate /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/00
add wave -noupdate /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/01
add wave -noupdate /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/02
add wave -noupdate /bit_unpack_tb/bit_unpack_dut3/unpack_32_to_48_inst0/04
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {220 ps} 0}
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
WaveRestoreZoom {0 ps} {1 ns}
