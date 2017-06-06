cd system/simulation/mentor
do msim_setup.tcl
ld

add wave /system/vectorblox_orca_0/core/D/register_file_1/t3
set files [lsort [glob ../../../test/*.qex]]

set max_length  0
foreach f $files {
	 set len [string length $f ]
	 if { $len > $max_length } {
		  set max_length $len
	 }
}
foreach f $files {
	 file copy -force $f test.hex
	 restart -f
	 onbreak {resume}
	 when {system/vectorblox_orca_0/core/X/instruction == x"00000073" && system/vectorblox_orca_0/core/X/valid_input == "1" } {stop}

	 if { [string match "*.elf*" $f ] } {
		  #some of the unit tests may have to run for a much longer time
		  run 60 us
	 } else {
		  run 15 us
	 }
	 set v [examine -radix decimal /system/vectorblox_orca_0/core/D/register_file_1/t3]
	 set passfail  ""
	 if { $v != 1 } {
		  set passfail "FAIL"
	 }
	 puts [format "%-${max_length}s = %-6d %s" $f $v $passfail ]
}

exit -f;
