all:
AS_SRCS=crt.S

TARGETS=de2-test
TARGET_C_SRCS=$(addsuffix .c,$(TARGETS))
TARGET_C_OBJS=$(addprefix obj/,$(addsuffix .c.o,$(TARGETS)))
C_OBJ_FILES=$(addprefix obj/,$(addsuffix .c.o, $(C_SRCS)))
S_OBJ_FILES=$(addprefix obj/,$(addsuffix .o, $(AS_SRCS)))

CROSS_COMPILE=riscv32-unknown-elf-
CC=$(CROSS_COMPILE)gcc
OBJCOPY=$(CROSS_COMPILE)objcopy
OBJDUMP=$(CROSS_COMPILE)objdump
ARCH=RV32IMXmxp
CFLAGS= -m32 -O2 -fno-delete-null-pointer-checks -g -march=$(ARCH) -MD -Wall -std=gnu99 -msoft-float -mmuldiv
LD_FLAGS= -m32 -march=$(ARCH) -static -nostartfiles

obj/:
	mkdir -p obj/

$(TARGET_C_OBJS) $(C_OBJ_FILES): obj/%.c.o : %.c | obj/
	$(CC) $(CFLAGS) -c $< -o $@

$(S_OBJ_FILES): obj/%.S.o : %.S | obj/
	$(CC) $(CFLAGS) -c $< -o $@

LD_SCRIPT=link.ld
LIBC=
TARGET_ELFS=$(addsuffix .elf,$(TARGETS))

$(TARGET_ELFS):%.elf:obj/%.c.o $(C_OBJ_FILES) $(S_OBJ_FILES) $(LD_SCRIPT)
	$(CC) -T $(LD_SCRIPT) obj/$*.c.o $(S_OBJ_FILES) $(C_OBJ_FILES) -o $@ $(LD_FLAGS)
	$(OBJDUMP) -D $@ > $*.dump

.phony:all clean
ifndef FORMAT
FORMAT=elf
endif
all: $(TARGET_ELFS)

TARGET_OBJ_DUMPS=$(addsuffix .dump, $(TARGETS))
TARGET_BINS=$(addsuffix .bin, $(TARGETS))
TARGET_HEXS=$(addsuffix .hex, $(TARGETS))
TARGET_MIFS=$(addsuffix .mif, $(TARGETS))
TARGET_MEMS=$(addsuffix .mem, $(TARGETS))
clean:
	rm -rf obj $(TARGET_ELFS) $(TARGET_OBJ_DUMPS) $(TARGET_BINS) $(TARGET_HEXS) $(TARGET_HEXS) $(TARGET_MEMS)

-include $(wildcard obj/*.d)
