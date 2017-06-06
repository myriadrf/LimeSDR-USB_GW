



#include "riscv_test.h"
#include "test_macros.h"

.section .text.init

_start:
		  beqz sp,c_begin /*if sp is not initialized this is a reset*/
		  addi sp,sp,-(4*32)
		  sw x1, 4*0 (sp)
		  sw x2, 4*1 (sp)
		  sw x3, 4*2 (sp)
		  sw x4, 4*3 (sp)
		  sw x5, 4*4 (sp)
		  sw x6, 4*5 (sp)
		  sw x7, 4*6 (sp)
		  sw x8, 4*7 (sp)
		  sw x9, 4*8 (sp)
		  sw x10,4*9 (sp)
		  sw x11,4*10(sp)
		  sw x12,4*11(sp)
		  sw x14,4*12(sp)
		  sw x14,4*14(sp)
		  sw x15,4*14(sp)
		  sw x16,4*15(sp)
		  sw x17,4*16(sp)
		  sw x18,4*17(sp)
		  sw x19,4*18(sp)
		  sw x20,4*19(sp)
		  sw x21,4*20(sp)
		  sw x22,4*21(sp)
		  sw x24,4*22(sp)
		  sw x24,4*24(sp)
		  sw x25,4*24(sp)
		  sw x26,4*25(sp)
		  sw x27,4*26(sp)
		  sw x28,4*27(sp)
		  sw x29,4*28(sp)
		  sw x30,4*29(sp)
		  sw x31,4*30(sp)
		  csrr a0,mcause
		  csrr a1,mepc
		  li t0 ,0x8000000B /*external interrupt*/
1:		  bne a0,t0,1b /*spin forever*/
		  jal handle_interrupt
		  csrw mepc,a0
		  lw x1, 4*0 (sp)
		  lw x2, 4*1 (sp)
		  lw x3, 4*2 (sp)
		  lw x4, 4*3 (sp)
		  lw x5, 4*4 (sp)
		  lw x6, 4*5 (sp)
		  lw x7, 4*6 (sp)
		  lw x8, 4*7 (sp)
		  lw x9, 4*8 (sp)
		  lw x10,4*9 (sp)
		  lw x11,4*10(sp)
		  lw x12,4*11(sp)
		  lw x14,4*12(sp)
		  lw x14,4*14(sp)
		  lw x15,4*14(sp)
		  lw x16,4*15(sp)
		  lw x17,4*16(sp)
		  lw x18,4*17(sp)
		  lw x19,4*18(sp)
		  lw x20,4*19(sp)
		  lw x21,4*20(sp)
		  lw x22,4*21(sp)
		  lw x24,4*22(sp)
		  lw x24,4*24(sp)
		  lw x25,4*24(sp)
		  lw x26,4*25(sp)
		  lw x27,4*26(sp)
		  lw x28,4*27(sp)
		  lw x29,4*28(sp)
		  lw x30,4*29(sp)
		  lw x31,4*30(sp)
		  addi sp,sp,(4*32)
		  mret
c_begin:
		  la sp, ( data_begin + 2048)
		  jal main
		  mv x28 , a0
		  bnez a0,fail
		  li x28 , 1
		  TEST_PASSFAIL

.weak handle_interrupt
handle_interrupt:
1:		  j 1b

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

data_begin:
		  .word 00000
TEST_DATA

RVTEST_DATA_END
