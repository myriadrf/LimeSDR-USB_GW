# ----------------------------------------------------------------------------	
# FILE: 	compile.tcl
# DESCRIPTION:	General compile script for ModelSim - Altera
# DATE:	Jan 19, 2017
# AUTHOR(s):	Lime Microsystems
# REVISIONS: 1.0
# ----------------------------------------------------------------------------

puts {
 ----------------------------------------------------------------------------	
 FILE: 	compile.tcl
 DESCRIPTION:	General compile script for ModelSim - Altera
 DATE:	Jan 19, 2017
 AUTHOR(s):	Lime Microsystems
 REVISIONS: 1.0
 ----------------------------------------------------------------------------
}

# Simply change the project settings in this section
# for each new project. There should be no need to
# modify the rest of the script.

#Add files to compile, follow compilation order(last file - top module)
set library_file_list {
                           source_library { ../general/sync_reg.vhd
                                            ../general/bus_sync_reg.vhd
                                            
                                            synth/lms7002_ddin.vhd
                                            synth/test_data_dd.vhd
                                            synth/rxiq_siso_sdr.vhd
                                            synth/rxiq_siso_ddr.vhd
                                            synth/rxiq_pulse_ddr.vhd
                                            synth/rxiq_mimo_ddr.vhd
                                            synth/rxiq_mimo.vhd
                                            synth/rxiq_siso.vhd
                                            synth/rxiq.vhd
                                            synth/diq2fifo.vhd                                           
                                            sim/adc_data_sim.vhd
                                            sim/LMS7002_DIQ2_sim.vhd
                                            sim/diq2fifo_tb.vhd
                           }
}



# After sourcing the script from ModelSim for the
# first time use these commands to recompile.

proc r  {} {uplevel #0 source compile.tcl}
proc rr {} {global last_compile_time
            set last_compile_time 0
            r                            }
proc q  {} {quit -force                  }

#Does this installation support Tk?
set tk_ok 1
if [catch {package require Tk}] {set tk_ok 0}

# Prefer a fixed point font for the transcript
set PrefMain(font) {Courier 10 roman normal}

# Compile out of date files
set time_now [clock seconds]
if [catch {set last_compile_time}] {
  set last_compile_time 0
}
foreach {library file_list} $library_file_list {
  vlib $library
  vmap work $library
  foreach file $file_list {
    if { $last_compile_time < [file mtime $file] } {
      if [regexp {.vhdl?$} $file] {
        vcom -quiet -93 $file
      } else {
        vlog $file
      }
      set last_compile_time 0
    }
  }
}
set last_compile_time $time_now

puts {
  Script commands are:

  r = Recompile changed and dependent files
 rr = Recompile everything
  q = Quit without confirmation
}


