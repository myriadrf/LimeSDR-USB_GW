
ELF=$1
TOOLDIR=$(dirname $0)

BIN_FILE=$(basename $ELF).bin
QEX_FILE=$(basename $ELF).qex
MEM_FILE=$(basename $ELF).mem
MIF_FILE=$(basename $ELF).mif
riscv32-unknown-elf-objcopy  -O binary $ELF $BIN_FILE
python $TOOLDIR/bin2mif.py $BIN_FILE 0x100 > $MIF_FILE || exit -1
mif2hex $MIF_FILE $QEX_FILE >/dev/null 2>&1 || exit -1
rm -f $BIN_FILE $MIF_FILE $SPLIT_FILE
