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
