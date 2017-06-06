

ifndef BUS_TYPE
$(info INFO: BUS_TYPE not defined, defaulting to avalon )
BUS_TYPE=avalon
endif

all:
SYSTEM=system_$(BUS_TYPE)
QSYS_FILE=$(SYSTEM).qsys
SIM_FILE=simulate_$(BUS_TYPE).tcl
TESTALL_FILE=testall_$(BUS_TYPE).tcl


$(SYSTEM)/simulation/mentor/msim_setup.tcl: $(QSYS_FILE)
	qsys-generate --simulation=vhdl $^
	(cd $(SYSTEM)/simulation/submodules/vblox_orca; for i in *.vhd; do if [ -f ../../../../rtl/$$i ] ; then ln -sf ../../../../rtl/$$i $$i; fi; done; )

test/rv32ui-p-add.qex:
	../tools/generate_hex_files.sh

$(SIM_FILE):simulate.tcl
	sed 's/system/system_$(BUS_TYPE)/g' $^ > $@
$(TESTALL_FILE):testall_sim.tcl
	sed 's/system/system_$(BUS_TYPE)/g' $^ > $@


testall: test/rv32ui-p-add.qex $(SYSTEM)/simulation/mentor/msim_setup.tcl $(TESTALL_FILE)
	vsim -c -do $(TESTALL_FILE) | egrep '(^[^#]|Error:)'

all: $(SYSTEM)/simulation/mentor/msim_setup.tcl
	(cd $(SYSTEM)/simulation/mentor/; ln -sf ../../../test.hex .)

sim: all $(SIM_FILE)
	vsim -do $(SIM_FILE)
clean:
	rm -rf system_avalon system_csmith system_axi test test.hex
	rm -rf *_axi.tcl *_avalon.tcl transcript *.sopcinfo platform.info
	rm -rf .qsys_edit
