



#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN


test_2: /*consecutive shifts*/
		  li      x1,0xFFFF
		  slli    x3,x1,16
		  sra     x3,x3,16
		  addi    x29,x0,-1
		  addi    x28,x0,2
		  bne     x3,x29,fail

test_3: /*consecutive loads*/
		  la      x1, data_3_0
		  la      x2, data_3_1
        lw      x3, 0(x1)
		  lw      x4, 0(x2)
		  addi    x28,x0,3
		  li      x29,0xAAAAAAAA
		  bne     x3,x29,fail
		  li      x29,0xBBBBBBBB
		  bne     x4,x29,fail

test_4: /*consecutive stores*/
		  la      x1, data_4_0
		  la      x2, data_4_1
		  li      x3,0xAAAAAAAA
		  li      x4,0xBBBBBBBB
        sw      x3, 0(x1)
		  sw      x4, 0(x2)
		  addi    x28,x0,4
		  lw      x5, 0(x1)
		  li      x29,0xAAAAAAAA
		  bne     x5,x29,fail
		  lw      x5, 0(x2)
		  li      x29,0xBBBBBBBB
		  bne     x5,x29,fail

test_5: /*csrr after load*/
		  la      x1, data_5_0
		  li      x3,0xAAAAAAAA
		  li      x4,0x80
		  csrw    mstatus,x4
		  lw      x5, 0(x1)
		  csrr    x6, mstatus
		  li      x28, 5
		  bne     x5,x3,fail
		  bne     x6,x4,fail

		  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

data_3_0:
		  .word 0xAAAAAAAA
data_3_1:
		  .word 0xBBBBBBBB

data_4_0:
		  .word 0x0
data_4_1:
		  .word 0x0
data_5_0:
		  .word 0xAAAAAAAA


  TEST_DATA

RVTEST_DATA_END
