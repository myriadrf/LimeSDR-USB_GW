cd system/simulation/mentor
do msim_setup.tcl
exec ln -sf ../../../test.hex test.hex
ld

add log -r *

add wave -noupdate /system/vectorblox_orca_0/core/clk
add wave -noupdate /system/vectorblox_orca_0/core/reset
add wave -noupdate -divider Decode
add wave -noupdate /system/vectorblox_orca_0/core/D/register_file_1/t3
add wave -noupdate -divider Execute
add wave -noupdate /system/vectorblox_orca_0/core/X/valid_instr
add wave -noupdate /system/vectorblox_orca_0/core/X/pc_current
add wave -noupdate /system/vectorblox_orca_0/core/X/instruction

proc rerun { t } {
				restart -f;
				run $t
		  }
radix -hexadecimal
config wave -signalnamewidth 2
