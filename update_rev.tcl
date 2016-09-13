proc update_version_number { input_file output_file } {
	# If the input file can't be opened, return an error.
	if { [catch {open $input_file} input] } {
		 return -code error $input
	}

	# If the output file can't be opened, return an error
	if { [catch {open $output_file w} output] } {
		 return -code error $output
	}

	# Read through the input file a line at a time
	while {-1 != [gets $input line] } {
		if { [regexp {^\s*constant COMPILE_REV : INTEGER := ([[:digit:]]+);\s*$} \ $line match version_number] } {
			set decimal_value $version_number
			incr decimal_value		
			# Substitute the new version number in for the old one 
			regsub $version_number $line $decimal_value line
			post_message "File src/revision/revision.vhd updated with Current Compile Revision: $decimal_value"
		} elseif { [regexp {^\s*constant COMPILE_YEAR_STAMP : INTEGER := ([[:digit:]]+);\s*$} \ $line match version_number] } {
			set decimal_value [clock format [clock seconds] -format {%y}]
			regsub $version_number $line $decimal_value line
		} elseif { [regexp {^\s*constant COMPILE_MONTH_STAMP : INTEGER := ([[:digit:]]+);\s*$} \ $line match version_number] } {
			set decimal_value [clock format [clock seconds] -format {%m}]
			regsub $version_number $line $decimal_value line
		} elseif { [regexp {^\s*constant COMPILE_DAY_STAMP : INTEGER := ([[:digit:]]+);\s*$} \ $line match version_number] } {
			set decimal_value [clock format [clock seconds] -format {%d}]
			regsub $version_number $line $decimal_value line
		} elseif { [regexp {^\s*constant COMPILE_HOUR_STAMP : INTEGER := ([[:digit:]]+);\s*$} \ $line match version_number] } {
			set decimal_value [clock format [clock seconds] -format {%H}]
			regsub $version_number $line $decimal_value line
		} 
		
		# Write out the line to the new file 
		puts $output $line 
	}
	close $input 
	close $output 
}


set file_name "src/revision/revision.vhd"
set output_file_name ${file_name}.updated_version_number

if { [catch { update_version_number $file_name $output_file_name } res ] } {
    post_message -type critical_warning "Could not update version number: $res"
} else {
    if { [catch { file rename -force $output_file_name $file_name } res ] } {
        post_message -type critical_warning "Could not update version number: $res"
    }
}
