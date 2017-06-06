#!/bin/sh
SCRIPTDIR=$(dirname $0)

if which mif2hex >/dev/null
then
	 :
else
	 echo "ERROR: Cant find command mif2hex, have you loaded nios2 tools? Exiting." >&2
	 exit -1;
fi


echo "initializing git submodules containing tests, and building them"
(cd $SCRIPTDIR ;git submodule update --init $SCRIPTDIR/riscv-toolchain/riscv-tools/)

pushd $SCRIPTDIR/riscv-toolchain/riscv-tools/riscv-tests/
  git submodule update --init --recursive .
  sed -i 's/. = 0x80000000/. = 0x00000200/' env/p/link.ld
  sed -i 's/.tohost.*$//' env/p/link.ld
  sed -i 's/ ecall/fence.i;ecall/' env/p/riscv_test.h
  ./configure --with-xlen=32 2>&1
  make clean 2 >/dev/null 2>&1
  make -k isa -j10 >/dev/null 2>&1
popd

TEST_DIR=$SCRIPTDIR/riscv-toolchain/riscv-tools/riscv-tests/isa

#build vectorblox unit tests
make -C $SCRIPTDIR/../software/unit_test





SOFTWARE_DIR=../software
#all files that aren't dump or hex (the hex files are not correctly formatted)
FILES=$(ls ${TEST_DIR}/rv32u?-p-* | grep -v dump | grep -v hex)
ORCA_FILES=$(find  ${SOFTWARE_DIR}/unit_test -iname "*.elf" )


PREFIX=riscv32-unknown-elf
OBJDUMP=$PREFIX-objdump
OBJCOPY=$PREFIX-objcopy

mkdir -p test


#MEM files are for lattice boards, the hex files are for altera boards
for f in $FILES $ORCA_FILES
do

	 BIN_FILE=test/$(basename $f).bin
	 QEX_FILE=test/$(basename $f).qex
	 MEM_FILE=test/$(basename $f).mem
	 MIF_FILE=test/$(basename $f).mif
	 SPLIT_FILE=test/$(basename $f).split2
	 echo "$f > $QEX_FILE"
	 (
		  cp $f test/
		  $OBJCOPY  -O binary $f $BIN_FILE
		  $OBJDUMP --disassemble-all -Mnumeric,no-aliases $f > test/$(basename $f).dump

		  python ../tools/bin2mif.py $BIN_FILE 0x200 > $MIF_FILE || exit -1
		  mif2hex $MIF_FILE $QEX_FILE >/dev/null 2>&1 || exit -1
		  sed -e 's/://' -e 's/\(..\)/\1 /g'  $QEX_FILE >$SPLIT_FILE
		  awk '{if (NF == 9) print $5$6$7$8}' $SPLIT_FILE > $MEM_FILE
		 # rm -f $MIF_FILE $SPLIT_FILE
	 ) &
done
wait
