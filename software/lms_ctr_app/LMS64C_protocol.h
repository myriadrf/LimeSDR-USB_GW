/**
-- ----------------------------------------------------------------------------	
-- FILE:	LMS64C_protocol.h
-- DESCRIPTION:	LMS64C - fixed lenght (64 bytes) lenght control protocol incuding 8 bytes header
-- DATE:	2015.06.04
-- AUTHOR(s):	Lime Microsystems
-- REVISION: v0r20
-- ----------------------------------------------------------------------------	

*/

#ifndef _LMS64C_PROTOCOL_H_
#define _LMS64C_PROTOCOL_H_

enum eLMS_DEV {
	LMS_DEV_UNKNOWN, 
	LMS_DEV_EVB6,
	LMS_DEV_DIGIGREEN, 
	LMS_DEV_DIGIRED, //2x LMS6002, USB3
	LMS_DEV_EVB7, 
	LMS_DEV_ZIPPER, //MyRiad bridge to FMC, HSMC bridge
	LMS_DEV_SOCKETBOARD, 
	LMS_DEV_EVB7V2, 
	LMS_DEV_STREAM, //Altera Cyclone IV, USB3, 2x 128 MB RAM, RFDIO, FMC
	LMS_DEV_NOVENA, //Freescale iMX6 CPU
	LMS_DEV_DATASPARK, //Altera Cyclone V, 2x 256 MB RAM, 2x FMC (HPC, LPC), USB3
	LMS_DEV_RFSPARK, //LMS7002
	LMS_DEV_LMS6002USB, //LM6002-USB (USB stick: FX3, FPGA, LMS6002, RaspberryPi con)
	LMS_DEV_RFESPARK,
	LMS_DEV_SODERA,		//LMS7002M SoDeRa-USB board
	LMS_DEV_SODERAPCIE,	//LMS7002M SoDeRa-PCIe board

	};

enum eEXP_BOARD {
	EXP_BOARD_UNKNOWN, //undefined
	EXP_BOARD_UNSUPPORTED, //exp board not supported
	EXP_BOARD_NO, //device does not supoort any exp boards
	EXP_BOARD_MYRIAD1, //myriad1 LMS6002
	EXP_BOARD_MYRIAD2, //myriad2 LMS6002, longer board, with PA, MIPI
	EXP_BOARD_MYRIAD_NOVENA, //Novena myriad
	EXP_BOARD_HPM1000, //myriad with MCU, PA, MPI
	EXP_BOARD_MYRIAD7, //Myriad with LMS7002
	EXP_BOARD_HPM7, //Myriad long with LMS7002, 2x PA
	};

#define LMS_PROTOCOL_VER		1
#define LMS_CTRL_PACKET_SIZE	64

//commands
#define CMD_GET_INFO		0x00 //Returns some info about board and firmware

//i2c peripherals control
#define CMD_SI5356_WR	 	0x11
#define CMD_SI5356_RD		0x12
#define CMD_SI5351_WR	 	0x13 //Writes data to SI5351 (clock generator) via I2C
#define CMD_SI5351_RD		0x14 //Reads data from SI5351 (clock generator) via I2C
#define CMD_TFP410_WR		0x15 //PanelBus DVI (HDMI) Transmitter control
#define CMD_TFP410_RD		0x16 //PanelBus DVI (HDMI) Transmitter control

#define CMD_LMS_RST			0x20 //CMD_LMS_RST
#define CMD_LMS7002_WR		0x21 //Writes data to LMS7002 chip via SPI (16 bits word)
#define CMD_LMS7002_RD		0x22 //Reads data from LMS7002 chip via SPI (16 bits word)
#define CMD_LMS6002_WR		0x23 //Writes data to LMS6002 chip via SPI (8 bits word)
#define CMD_LMS6002_RD		0x24 //Reads data from LMS6002 chip via SPI (8 bits word)

#define CMD_LMS_LNA			0x2A
#define CMD_LMS_PA			0x2B
#define CMD_LMS_MCU_FW_WR	0x2C //LMS7 MCU FW write
#define CMD_WR_MCU			0x2D //testing
#define CMD_RD_MCU			0x2E //testing

//ADF4002
#define CMD_ADF4002_WR		0x31 //Writes data to ADF4002 (phase detector/frequency synthesizer) via SPI

#define CMD_FX2				0x40 //FX2 Configuration, resets endpoints (DigiGreen)

#define CMD_PE636040_WR		0x41 //Writes data to PE636040 tuner
#define CMD_PE636040_RD		0x42 //Reads data from PE636040 tuner

#define CMD_GPIO_WR			0x51 //Controls board’s GPIOs	
#define CMD_GPIO_RD			0x52 //Reads board’s GPIOs states 
#define CMD_ALTERA_FPGA_GW_WR		0x53
#define CMD_ALTERA_FPGA_GW_RD		0x54

//spi peripherals control
#define CMD_BRDSPI16_WR		0x55 //16 + 16 bit spi for stream, dataspark control
#define CMD_BRDSPI16_RD		0x56 //16 + 16 bit spi for stream, dataspark control
#define CMD_BRDSPI8_WR		0x57 //8 + 8 bit spi for stream, dataspark control
#define CMD_BRDSPI8_RD		0x58 //8 + 8 bit spi for stream, dataspark control

#define CMD_BRDCONF_WR		0x5D //write config data to board
#define CMD_BRDCONF_RD		0x5E //read config data from board

#define CMD_ANALOG_VAL_WR	0x61 //write analog value
#define CMD_ANALOG_VAL_RD	0x62 //read analog value
//read reference??? ofset? min? max?

//0x6x free?
//0x7x free?
/*
#define 8bit spi wr, rd
#define 16bit spi wr, rd
#define 8bit i2c
#*/

#define CMD_MYRIAD_RST		0x80
#define CMD_MYRIAD_WR		0x81
#define CMD_MYRIAD_RD		0x82
#define CMD_MYRIAD_FW_WR	0x8C //Writes FW to MyRiad board via SPI
#define CMD_MYRIAD_FW_RD	0x8D //Reads FW from MyRiad board via SPI

//status
#define STATUS_COMPLETED_CMD		1 //Command successfully executed
#define STATUS_UNKNOWN_CMD			2 //Unknown command
#define STATUS_BUSY_CMD				3 //Command execution not finished
#define STATUS_BLOCKS_ERROR_CMD		4 //Too many blocks
#define STATUS_ERROR_CMD			5 //Error occurred during command execution
#define STATUS_WRONG_ORDER_CMD		6 //Broken packets sequence
#define STATUS_RESOURCE_DENIED_CMD	7 //Board resource denied
#define STATUS_INVALID_PERIPH_ID_CMD	8 //

enum STATUS_BRD {STATUS_BRD_UNKNOWN, STATUS_BRD_READY, STATUS_BRD_BUSY, STATUS_BRD_ERROR};

//CMD_LMS_RST
#define LMS_RST_DEACTIVATE	0
#define LMS_RST_ACTIVATE	1
#define LMS_RST_PULSE		2

typedef struct{
    unsigned char Command;
    unsigned char Status;
	unsigned char Data_blocks;
	unsigned char Periph_ID;
	unsigned char reserved[4];
}tLMS_Ctrl_Header;

typedef struct{
    tLMS_Ctrl_Header Header;
	unsigned char Data_field[LMS_CTRL_PACKET_SIZE - sizeof(tLMS_Ctrl_Header)];
}tLMS_Ctrl_Packet;

#endif
