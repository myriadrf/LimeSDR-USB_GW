# ----------------------------------------------------------------------------	
# FILE: 	compile.tcl
# DESCRIPTION:	General compile script for ModelSim - Altera
# DATE:	Jan 19, 2017
# AUTHOR(s):	Lime Microsystems
# REVISIONS: 1.0
# ----------------------------------------------------------------------------

#This line is useful when Notepad++ text editor is used instead of default 
#ModelSim text editor
#Set in ModelSim console (Needs to be done once)
#set PrefSource(altEditor) external_editor
#To go back to default Modelsim text editor Set in ModelSim console:
#unset PrefSource(altEditor)
proc external_editor {filename linenumber} { exec Notepad++.exe -n$linenumber $filename & }



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
                           source_library { ../../general/sync_reg.vhd
                                            ../../general/bus_sync_reg.vhd
                                            ../../general/general_pkg.vhd
                                            ../../packages/synth/FIFO_PACK.vhd
                                            synth/sync_fifo_rw.vhd
                                            ../../altera_inst/fifo_inst.vhd
                                            ../../altera_inst/lms7002_ddout.vhd
                                            ../bit_unpack/synth/unpack_64_to_48.vhd
                                            ../bit_unpack/synth/unpack_64_to_56.vhd
                                            ../bit_unpack/synth/unpack_64_to_64.vhd
                                            ../bit_unpack/synth/bit_unpack_64.vhd
                                            ../fifo2diq/synth/txiq_ctrl.vhd
                                            ../fifo2diq/synth/txiq.vhd
                                            ../fifo2diq/synth/fifo2diq.vhd
                                            ../handshake_sync/synth/handshake_sync.vhd
                                            ../packets2data/synth/p2d_wr_fsm.vhd
                                            ../packets2data/synth/p2d_rd_fsm.vhd
                                            ../packets2data/synth/p2d_rd.vhd
                                            ../packets2data/synth/p2d_clr_fsm.vhd
                                            ../packets2data/synth/p2d_sync_fsm.vhd
                                            ../packets2data/synth/packets2data.vhd
                                            ../packets2data/synth/packets2data_top.vhd
                                            ../pulse_gen/synth/pulse_gen.vhd
                                            synth/tx_path_top.vhd
                                            sim/tx_path_top_tb.vhd
                                            
                                            
                                            
                                            
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




