if [ $# -ne 1 ]
then
	 echo "Usage: $0 [ELF_FILE] " >&2
	 exit -1
fi

ELF_FILE=$1
BIN_FILE=$(basename ${ELF_FILE}).bin
MEM_FILE=$(basename ${ELF_FILE}).mem
riscv64-unknown-elf-objcopy -O binary ${ELF_FILE} ${BIN_FILE}
head -c $((0x100)) /dev/zero | cat - ${BIN_FILE} | xxd -g1 -c4 | awk '{print $5$4$3$2}' > ${MEM_FILE}
rm $BIN_FILE
