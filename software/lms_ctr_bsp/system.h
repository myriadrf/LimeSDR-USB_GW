/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'nios2_cpu' in SOPC Builder design 'lms_ctr'
 * SOPC Builder design path: ../../lms_ctr.sopcinfo
 *
 * Generated: Fri Nov 04 15:30:09 EET 2016
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * Av_FIFO_Int_0 configuration
 *
 */

#define ALT_MODULE_CLASS_Av_FIFO_Int_0 Av_FIFO_Int
#define AV_FIFO_INT_0_BASE 0x110c0
#define AV_FIFO_INT_0_IRQ -1
#define AV_FIFO_INT_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define AV_FIFO_INT_0_NAME "/dev/Av_FIFO_Int_0"
#define AV_FIFO_INT_0_SPAN 16
#define AV_FIFO_INT_0_TYPE "Av_FIFO_Int"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2_gen2"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x00010820
#define ALT_CPU_CPU_ARCH_NIOS2_R1
#define ALT_CPU_CPU_FREQ 100000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "tiny"
#define ALT_CPU_DATA_ADDR_WIDTH 0x11
#define ALT_CPU_DCACHE_LINE_SIZE 0
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_DCACHE_SIZE 0
#define ALT_CPU_EXCEPTION_ADDR 0x00008020
#define ALT_CPU_FLASH_ACCELERATOR_LINES 0
#define ALT_CPU_FLASH_ACCELERATOR_LINE_SIZE 0
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 100000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 0
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 0
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_ICACHE_SIZE 0
#define ALT_CPU_INST_ADDR_WIDTH 0x11
#define ALT_CPU_NAME "nios2_cpu"
#define ALT_CPU_OCI_VERSION 1
#define ALT_CPU_RESET_ADDR 0x00008000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x00010820
#define NIOS2_CPU_ARCH_NIOS2_R1
#define NIOS2_CPU_FREQ 100000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "tiny"
#define NIOS2_DATA_ADDR_WIDTH 0x11
#define NIOS2_DCACHE_LINE_SIZE 0
#define NIOS2_DCACHE_LINE_SIZE_LOG2 0
#define NIOS2_DCACHE_SIZE 0
#define NIOS2_EXCEPTION_ADDR 0x00008020
#define NIOS2_FLASH_ACCELERATOR_LINES 0
#define NIOS2_FLASH_ACCELERATOR_LINE_SIZE 0
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 0
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 0
#define NIOS2_ICACHE_LINE_SIZE_LOG2 0
#define NIOS2_ICACHE_SIZE 0
#define NIOS2_INST_ADDR_WIDTH 0x11
#define NIOS2_OCI_VERSION 1
#define NIOS2_RESET_ADDR 0x00008000


/*
 * Custom instruction macros
 *
 */

#define ALT_CI_NIOS_CUSTOM_INSTR_BITSWAP_0(A) __builtin_custom_ini(ALT_CI_NIOS_CUSTOM_INSTR_BITSWAP_0_N,(A))
#define ALT_CI_NIOS_CUSTOM_INSTR_BITSWAP_0_N 0x0


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_ONCHIP_MEMORY2
#define __ALTERA_AVALON_PIO
#define __ALTERA_AVALON_SPI
#define __ALTERA_AVALON_SYSID_QSYS
#define __ALTERA_NIOS2_GEN2
#define __ALTERA_NIOS_CUSTOM_INSTR_BITSWAP
#define __AV_FIFO_INT
#define __I2C_OPENCORES


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "Cyclone IV E"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/null"
#define ALT_STDERR_BASE 0x0
#define ALT_STDERR_DEV null
#define ALT_STDERR_TYPE ""
#define ALT_STDIN "/dev/null"
#define ALT_STDIN_BASE 0x0
#define ALT_STDIN_DEV null
#define ALT_STDIN_TYPE ""
#define ALT_STDOUT "/dev/null"
#define ALT_STDOUT_BASE 0x0
#define ALT_STDOUT_DEV null
#define ALT_STDOUT_TYPE ""
#define ALT_SYSTEM_NAME "lms_ctr"


/*
 * hal configuration
 *
 */

#define ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
#define ALT_MAX_FD 32
#define ALT_SYS_CLK none
#define ALT_TIMESTAMP_CLK none


/*
 * i2c_opencores_0 configuration
 *
 */

#define ALT_MODULE_CLASS_i2c_opencores_0 i2c_opencores
#define I2C_OPENCORES_0_BASE 0x11080
#define I2C_OPENCORES_0_IRQ 0
#define I2C_OPENCORES_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define I2C_OPENCORES_0_NAME "/dev/i2c_opencores_0"
#define I2C_OPENCORES_0_SPAN 32
#define I2C_OPENCORES_0_TYPE "i2c_opencores"


/*
 * leds configuration
 *
 */

#define ALT_MODULE_CLASS_leds altera_avalon_pio
#define LEDS_BASE 0x110a0
#define LEDS_BIT_CLEARING_EDGE_REGISTER 0
#define LEDS_BIT_MODIFYING_OUTPUT_REGISTER 0
#define LEDS_CAPTURE 0
#define LEDS_DATA_WIDTH 8
#define LEDS_DO_TEST_BENCH_WIRING 0
#define LEDS_DRIVEN_SIM_VALUE 0
#define LEDS_EDGE_TYPE "NONE"
#define LEDS_FREQ 100000000
#define LEDS_HAS_IN 0
#define LEDS_HAS_OUT 1
#define LEDS_HAS_TRI 0
#define LEDS_IRQ -1
#define LEDS_IRQ_INTERRUPT_CONTROLLER_ID -1
#define LEDS_IRQ_TYPE "NONE"
#define LEDS_NAME "/dev/leds"
#define LEDS_RESET_VALUE 0
#define LEDS_SPAN 16
#define LEDS_TYPE "altera_avalon_pio"


/*
 * lms_ctr_gpio configuration
 *
 */

#define ALT_MODULE_CLASS_lms_ctr_gpio altera_avalon_pio
#define LMS_CTR_GPIO_BASE 0x11060
#define LMS_CTR_GPIO_BIT_CLEARING_EDGE_REGISTER 0
#define LMS_CTR_GPIO_BIT_MODIFYING_OUTPUT_REGISTER 1
#define LMS_CTR_GPIO_CAPTURE 0
#define LMS_CTR_GPIO_DATA_WIDTH 4
#define LMS_CTR_GPIO_DO_TEST_BENCH_WIRING 0
#define LMS_CTR_GPIO_DRIVEN_SIM_VALUE 0
#define LMS_CTR_GPIO_EDGE_TYPE "NONE"
#define LMS_CTR_GPIO_FREQ 100000000
#define LMS_CTR_GPIO_HAS_IN 0
#define LMS_CTR_GPIO_HAS_OUT 1
#define LMS_CTR_GPIO_HAS_TRI 0
#define LMS_CTR_GPIO_IRQ -1
#define LMS_CTR_GPIO_IRQ_INTERRUPT_CONTROLLER_ID -1
#define LMS_CTR_GPIO_IRQ_TYPE "NONE"
#define LMS_CTR_GPIO_NAME "/dev/lms_ctr_gpio"
#define LMS_CTR_GPIO_RESET_VALUE 3
#define LMS_CTR_GPIO_SPAN 32
#define LMS_CTR_GPIO_TYPE "altera_avalon_pio"


/*
 * oc_mem configuration
 *
 */

#define ALT_MODULE_CLASS_oc_mem altera_avalon_onchip_memory2
#define OC_MEM_ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR 0
#define OC_MEM_ALLOW_MRAM_SIM_CONTENTS_ONLY_FILE 0
#define OC_MEM_BASE 0x8000
#define OC_MEM_CONTENTS_INFO ""
#define OC_MEM_DUAL_PORT 0
#define OC_MEM_GUI_RAM_BLOCK_TYPE "AUTO"
#define OC_MEM_INIT_CONTENTS_FILE "lms_ctr_oc_mem"
#define OC_MEM_INIT_MEM_CONTENT 1
#define OC_MEM_INSTANCE_ID "NONE"
#define OC_MEM_IRQ -1
#define OC_MEM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define OC_MEM_NAME "/dev/oc_mem"
#define OC_MEM_NON_DEFAULT_INIT_FILE_ENABLED 0
#define OC_MEM_RAM_BLOCK_TYPE "AUTO"
#define OC_MEM_READ_DURING_WRITE_MODE "DONT_CARE"
#define OC_MEM_SINGLE_CLOCK_OP 0
#define OC_MEM_SIZE_MULTIPLE 1
#define OC_MEM_SIZE_VALUE 32768
#define OC_MEM_SPAN 32768
#define OC_MEM_TYPE "altera_avalon_onchip_memory2"
#define OC_MEM_WRITABLE 1


/*
 * spi_1_ADF configuration
 *
 */

#define ALT_MODULE_CLASS_spi_1_ADF altera_avalon_spi
#define SPI_1_ADF_BASE 0x11000
#define SPI_1_ADF_CLOCKMULT 1
#define SPI_1_ADF_CLOCKPHASE 0
#define SPI_1_ADF_CLOCKPOLARITY 0
#define SPI_1_ADF_CLOCKUNITS "Hz"
#define SPI_1_ADF_DATABITS 8
#define SPI_1_ADF_DATAWIDTH 16
#define SPI_1_ADF_DELAYMULT "1.0E-9"
#define SPI_1_ADF_DELAYUNITS "ns"
#define SPI_1_ADF_EXTRADELAY 1
#define SPI_1_ADF_INSERT_SYNC 0
#define SPI_1_ADF_IRQ 3
#define SPI_1_ADF_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SPI_1_ADF_ISMASTER 1
#define SPI_1_ADF_LSBFIRST 0
#define SPI_1_ADF_NAME "/dev/spi_1_ADF"
#define SPI_1_ADF_NUMSLAVES 1
#define SPI_1_ADF_PREFIX "spi_"
#define SPI_1_ADF_SPAN 32
#define SPI_1_ADF_SYNC_REG_DEPTH 2
#define SPI_1_ADF_TARGETCLOCK 20000000u
#define SPI_1_ADF_TARGETSSDELAY "200.0"
#define SPI_1_ADF_TYPE "altera_avalon_spi"


/*
 * spi_1_DAC configuration
 *
 */

#define ALT_MODULE_CLASS_spi_1_DAC altera_avalon_spi
#define SPI_1_DAC_BASE 0x11020
#define SPI_1_DAC_CLOCKMULT 1
#define SPI_1_DAC_CLOCKPHASE 1
#define SPI_1_DAC_CLOCKPOLARITY 0
#define SPI_1_DAC_CLOCKUNITS "Hz"
#define SPI_1_DAC_DATABITS 8
#define SPI_1_DAC_DATAWIDTH 16
#define SPI_1_DAC_DELAYMULT "1.0E-9"
#define SPI_1_DAC_DELAYUNITS "ns"
#define SPI_1_DAC_EXTRADELAY 1
#define SPI_1_DAC_INSERT_SYNC 0
#define SPI_1_DAC_IRQ 2
#define SPI_1_DAC_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SPI_1_DAC_ISMASTER 1
#define SPI_1_DAC_LSBFIRST 0
#define SPI_1_DAC_NAME "/dev/spi_1_DAC"
#define SPI_1_DAC_NUMSLAVES 1
#define SPI_1_DAC_PREFIX "spi_"
#define SPI_1_DAC_SPAN 32
#define SPI_1_DAC_SYNC_REG_DEPTH 2
#define SPI_1_DAC_TARGETCLOCK 20000000u
#define SPI_1_DAC_TARGETSSDELAY "200.0"
#define SPI_1_DAC_TYPE "altera_avalon_spi"


/*
 * spi_lms configuration
 *
 */

#define ALT_MODULE_CLASS_spi_lms altera_avalon_spi
#define SPI_LMS_BASE 0x11040
#define SPI_LMS_CLOCKMULT 1
#define SPI_LMS_CLOCKPHASE 0
#define SPI_LMS_CLOCKPOLARITY 0
#define SPI_LMS_CLOCKUNITS "Hz"
#define SPI_LMS_DATABITS 8
#define SPI_LMS_DATAWIDTH 16
#define SPI_LMS_DELAYMULT "1.0E-9"
#define SPI_LMS_DELAYUNITS "ns"
#define SPI_LMS_EXTRADELAY 1
#define SPI_LMS_INSERT_SYNC 0
#define SPI_LMS_IRQ 1
#define SPI_LMS_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SPI_LMS_ISMASTER 1
#define SPI_LMS_LSBFIRST 0
#define SPI_LMS_NAME "/dev/spi_lms"
#define SPI_LMS_NUMSLAVES 5
#define SPI_LMS_PREFIX "spi_"
#define SPI_LMS_SPAN 32
#define SPI_LMS_SYNC_REG_DEPTH 2
#define SPI_LMS_TARGETCLOCK 20000000u
#define SPI_LMS_TARGETSSDELAY "200.0"
#define SPI_LMS_TYPE "altera_avalon_spi"


/*
 * switch configuration
 *
 */

#define ALT_MODULE_CLASS_switch altera_avalon_pio
#define SWITCH_BASE 0x110b0
#define SWITCH_BIT_CLEARING_EDGE_REGISTER 0
#define SWITCH_BIT_MODIFYING_OUTPUT_REGISTER 0
#define SWITCH_CAPTURE 0
#define SWITCH_DATA_WIDTH 8
#define SWITCH_DO_TEST_BENCH_WIRING 0
#define SWITCH_DRIVEN_SIM_VALUE 0
#define SWITCH_EDGE_TYPE "NONE"
#define SWITCH_FREQ 100000000
#define SWITCH_HAS_IN 1
#define SWITCH_HAS_OUT 0
#define SWITCH_HAS_TRI 0
#define SWITCH_IRQ -1
#define SWITCH_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SWITCH_IRQ_TYPE "NONE"
#define SWITCH_NAME "/dev/switch"
#define SWITCH_RESET_VALUE 0
#define SWITCH_SPAN 16
#define SWITCH_TYPE "altera_avalon_pio"


/*
 * sysid_qsys_0 configuration
 *
 */

#define ALT_MODULE_CLASS_sysid_qsys_0 altera_avalon_sysid_qsys
#define SYSID_QSYS_0_BASE 0x110d0
#define SYSID_QSYS_0_ID 4920
#define SYSID_QSYS_0_IRQ -1
#define SYSID_QSYS_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SYSID_QSYS_0_NAME "/dev/sysid_qsys_0"
#define SYSID_QSYS_0_SPAN 8
#define SYSID_QSYS_0_TIMESTAMP 1476792439
#define SYSID_QSYS_0_TYPE "altera_avalon_sysid_qsys"

#endif /* __SYSTEM_H_ */
