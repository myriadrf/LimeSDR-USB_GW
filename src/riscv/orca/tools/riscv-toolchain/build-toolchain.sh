#!/bin/bash
#exit from script when command fails
set -e

#check to make sure RISCV is defined
if [ -z "$RISCV" ]
then
	 echo "RISCV not defined, please define it to path for installing toolchain ... exiting" >&2
	 exit 1
fi

#download all riscv repositories from github
git submodule update --init --recursive

#sanity check to make sure directories are where they are supposed to be
BINUTILS_OPCODES_DIR=riscv-tools/riscv-gnu-toolchain/riscv-binutils-gdb/opcodes/
OPCODES_REPO_DIR=riscv-tools/riscv-opcodes/

function assert_dir_exist() {
	 DIRECTORY=$1
	 if [ ! -d $DIRECTORY ]
	 then
		  echo No Such Directory $DIRECTORY >&2
		  exit 1
	 fi
}

assert_dir_exist $BINUTILS_OPCODES_DIR
assert_dir_exist $OPCODES_REPO_DIR

set -o verbose
cp riscv-opc.c $BINUTILS_OPCODES_DIR
cp opcodes-Makefile $OPCODES_REPO_DIR/Makefile
cp opcodes-mxp.py   $OPCODES_REPO_DIR/

#update the opcodes generated files
make -C $OPCODES_REPO_DIR/

#start the build process
pushd riscv-tools
./build-rv32im.sh
popd
