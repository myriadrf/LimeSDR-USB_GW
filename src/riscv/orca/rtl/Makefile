#Makefile for quick testing for syntax errors and such
#Builds all the HDL and starts the simulation to ensure no assertions thrown

TOP_LEVEL=orca
VCOM=vcom
VCOMFLAGS= #-pedanticerrors #(I would like to build with pedanticerrors in the future, but not a priority)

VHDL_SOURCES=$(shell grep -v \\\# Filelist)

#_primary.dat seems like the file to test for in the library
COMPILED_SOURCES=$(patsubst %.vhd,work/%/_primary.dat,${VHDL_SOURCES})

#Always just clean and remake everything.
transcript: clean $(COMPILED_SOURCES)
	vsim -c work.$(TOP_LEVEL) -do "run 1ns; exit"

work/%/_primary.dat: %.vhd
	@if [ ! -e work ]; then vlib work; fi
	${VCOM} ${VCOMFLAGS} $<

clean:
	rm -f *~ vsim.wlf transcript
	rm -rf work
