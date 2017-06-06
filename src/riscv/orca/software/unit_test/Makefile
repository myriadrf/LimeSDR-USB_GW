all:

RISCV_TOOLS_DIR=$(abspath ../../tools/riscv-toolchain/riscv-tools)
RISCV_TESTS_DIR=$(RISCV_TOOLS_DIR)/riscv-tests
RISCV_ENV_DIR=$(RISCV_TESTS_DIR)/env/p

$(RISCV_ENV_DIR):
	cd $(RISCV_TOOLS_DIR); git submodule update --init .
	cd $(RISCV_TESTS_DIR); git submodule update --init --recursive .
	sed -i 's/. = 0x80000000/. = 0x00000200/' $@/link.ld
	sed -i 's/.tohost.*$//' $@/link.ld
	sed -i 's/ ecall/fence.i;ecall/' $@/riscv_test.h


ARCH=RV32IMXmxp
PREFIX=riscv32-unknown-elf-
CC=$(PREFIX)gcc
OBJDUMP=$(PREFIX)objdump
TEST_ASM=consecutive_instr.S
TEST_C=simple_c_test.c interrupt_test.c

TEST_ASM_ELF=$(addsuffix .elf,$(basename $(TEST_ASM)))
TEST_C_ELF=$(addsuffix .elf,$(basename $(TEST_C)))

C_FLAGS=-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -march=$(ARCH) -Wall
INCLUDE_DIRS:=$(RISCV_ENV_DIR) $(RISCV_TESTS_DIR)/isa/macros/scalar ../

INCLUDE_DIRS:=$(addprefix -I,$(INCLUDE_DIRS))
LINK_FILE=$(RISCV_ENV_DIR)/link.ld

$(TEST_ASM_ELF): %.elf : %.S | $(RISCV_ENV_DIR)
	$(CC) $(C_FLAGS)  $(INCLUDE_DIRS) -T$(LINK_FILE) $^ -o $@
	$(OBJDUMP) -D $@ > $*.dump

$(TEST_C_ELF): %.elf : %.c c_test.S | $(RISCV_ENV_DIR)
	$(CC) $(C_FLAGS) -O2 $(INCLUDE_DIRS) -T$(LINK_FILE) $^ -o $@
	$(OBJDUMP) -D $@ > $*.dump

all:$(TEST_ASM_ELF) $(TEST_C_ELF)


clean:
		rm -rf $(TEST_ASM_ELF) $(TEST_C_ELF) *.dump
