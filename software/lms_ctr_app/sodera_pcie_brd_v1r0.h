/**
-- ----------------------------------------------------------------------------	
-- FILE:	sodera_pcie_brd.h
-- DESCRIPTION:	Stream v2r2
-- DATE:	2015.06.29
-- AUTHOR(s):	Lime Microsystems
-- REVISION: v0r2
-- ----------------------------------------------------------------------------	

*/
#ifndef _SODERA_PCIE_BRD_V1R0_H_
#define _SODERA_PCIE_BRD_V1R0_H_

#include "LMS64C_protocol.h"

#pragma message ("**** sodera_pcie_brd_v1r0 ****")

//LMS control pins
#define FX3_GPIO42			42 //LMS reset through FPGA
#define FX3_GPIO43			43 //FMC adf4002 SNN
#define FX3_GPIO44			44 //rfdio exp brd ssn

#define FX3_FLASH1_SNN		54
#define FX3_FLASH2_SNN		45

#define FX3_SPI_CS			46 //LMS CS
#define FX3_FPGA_SNN		47
#define FX3_ADF_SNN			57 //onboard ADF SS

#define FX3_LED0			39
#define FX3_LED1			40
#define FX3_LED2			41

#define FX3_GPIO0			33
#define FX3_GPIO1			34
#define FX3_GPIO2			35
#define FX3_GPIO3			36
#define FX3_GPIO5			37
#define FX3_GPIO4			38

//FPGA Passive serial interface configuration
#define FPGA_PS_METHOD_SPI //select PS programming method - FPGA PS over SPI

#define FPGA_PS_NCONFIG		51
#define FPGA_PS_NSTATUS		49
#define FPGA_PS_CONFDONE	48
#define FPGA_PS_OE			50

//I2C devices
#define SI5351_I2C_ADDR		0x60 //0xC0
#define   LM75_I2C_ADDR		0x48 //0x90

//get info
#define DEV_TYPE			LMS_DEV_SODERAPCIE
#define HW_VER				1
#define EXP_BOARD			EXP_BOARD_UNKNOWN

//FPGA Cyclone IV GX (EP4GX30F23C7N) bitstream (RBF) size in bytes
#define FPGA_SIZE 			2751361 //1191788

//FLash memory (M25P16, 16M-bit))
//FLash memory (S25FL164K, 64M-bit)
#define FLASH_PAGE_SIZE 	0x100 //256 bytes, SPI Page size to be used for transfers
#define FLASH_SECTOR_SIZE 	0x10000 //256 pages * 256 page size = 65536 bytes
//#define FLASH_BLOCK_SIZE	(FLASH_SECTOR_SIZE/FLASH_PAGE_SIZE) //in pages

//FLASH memory layout
#define FLASH_LAYOUT_FPGA_METADATA	64//FPGA autoload metadata (start sector)
#define FLASH_LAYOUT_FPGA_BITSTREAM	0//FPGA bitstream (start sector) till end

#define FLASH_CMD_SECTOR_ERASE 0x1B //Depends on flash, reversed: 0xD8 or 0x20
#define FLASH_CMD_PAGE_WRITE   0x40 //Reversed 0x02
#define FLASH_CMD_PAGE_WRITEEN 0x60 //Reversed 0x06
#define FLASH_CMD_PAGE_READ    0xC0 //Reversed 0x03
#define FLASH_CMD_PAGE_READST  0xA0 //Reversed 0x05
#define FLASH_CMD_READJEDECID  0xF9 //Reversed 0x9F

typedef struct{
	uint32_t Bitream_size;
	uint8_t Autoload;
}tBoard_Config_FPGA; //tBoard_Config_FPGA or tBoard_cfg_FPGA

#endif
