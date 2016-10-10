/*
 * main.c
 *
 *  Created on: Jan 22, 2016
 *      Author: zydrunas
 */


#include "io.h"
#include "system.h"
//#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <altera_avalon_spi.h>
#include "alt_types.h"

#include "LMS64C_protocol.h"
#include "sodera_pcie_brd_v1r0.h"
#include "spi_flash_lib.h"
#include "i2c_opencores.h"

#define sbi(p,n) ((p) |= (1UL << (n)))
#define cbi(p,n) ((p) &= ~(1 << (n)))

//get info
//#define FW_VER				1 //Initial version
//#define FW_VER				2 //FLASH programming added
//#define FW_VER				3 //Temperature and Si5351C control added
//#define FW_VER				4 //LM75 configured to control fan; I2C speed increased up to 400kHz; ADF/DAC control implementation.
#define FW_VER				5 //LMS7 MCU programming feature added

#define SPI_NR_LMS7002M 0
#define SPI_NR_FPGA     1
#define SPI_NR_DAC      0
#define SPI_NR_ADF4002  0
#define SPI_NR_FLASH    0

//CMD_PROG_MCU
#define PROG_EEPROM 1
#define PROG_SRAM	2
#define BOOT_MCU	3

///CMD_PROG_MCU
#define MCU_CONTROL_REG	0x02
#define MCU_STATUS_REG	0x03
#define MCU_FIFO_WR_REG	0x04

#define MAX_MCU_RETRIES	30
uint8_t MCU_retries;

uint8_t test, block, cmd_errors, glEp0Buffer_Rx[64], glEp0Buffer_Tx[64];
tLMS_Ctrl_Packet *LMS_Ctrl_Packet_Tx = (tLMS_Ctrl_Packet*)glEp0Buffer_Tx;
tLMS_Ctrl_Packet *LMS_Ctrl_Packet_Rx = (tLMS_Ctrl_Packet*)glEp0Buffer_Rx;

unsigned char dac_val = 134;
unsigned char dac_data[2];

signed short int converted_val = 300;

int flash_page = 0, flash_page_data_cnt = 0, flash_data_cnt_free = 0, flash_data_counter_to_copy = 0;
//FPGA conf
unsigned long int last_portion, current_portion, fpga_data;
unsigned char data_cnt;
unsigned char sc_brdg_data[4];
unsigned char flash_page_data[FLASH_PAGE_SIZE];
tBoard_Config_FPGA *Board_Config_FPGA = (tBoard_Config_FPGA*) flash_page_data;
unsigned long int fpga_byte;


/**	This function checks if all blocks could fit in data field.
*	If blocks will not fit, function returns TRUE. */
unsigned char Check_many_blocks (unsigned char block_size)
{
	if (LMS_Ctrl_Packet_Rx->Header.Data_blocks > (sizeof(LMS_Ctrl_Packet_Tx->Data_field)/block_size))
	{
		LMS_Ctrl_Packet_Tx->Header.Status = STATUS_BLOCKS_ERROR_CMD;
		return 1;
	}
	else return 0;
	return 1;
}

/**
 * Gets 64 bytes packet from FIFO.
 */
void getFifoData(uint8_t *buf, uint8_t k)
{
	uint8_t cnt = 0;

	for(cnt=0; cnt<k; cnt++)
	{
		buf[cnt] = IORD(AV_FIFO_INT_0_BASE, 1);	// Read Data from FIFO
	};
}


/**
 * Gets led_pattern as parameter in order to write to the register.
 */
void set_led(unsigned char led_pattern)
{
    IOWR(LEDS_BASE, 0, led_pattern);               // writes register
}


/**
 * Configures LM75
 */
void Configure_LM75(void)
{
	int spirez;

	// OS polarity configuration
	spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 0);
	spirez = I2C_write(I2C_OPENCORES_0_BASE, 0x01, 0);				// Pointer = configuration register
	//spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 1);
	spirez = I2C_write(I2C_OPENCORES_0_BASE, 0x04, 1);				//Configuration value: OS polarity = 1, Comparator/int = 0, Shutdown = 0

	// THYST configuration
	spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 0);
	spirez = I2C_write(I2C_OPENCORES_0_BASE, 0x02, 0);				// Pointer = THYST register
	//spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 1);
	spirez = I2C_write(I2C_OPENCORES_0_BASE, 45, 0);				// Set THYST H
	spirez = I2C_write(I2C_OPENCORES_0_BASE,  0, 1);				// Set THYST L

	// TOS configuration
	spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 0);
	spirez = I2C_write(I2C_OPENCORES_0_BASE, 0x03, 0);				// Pointer = TOS register
	//spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 1);
	spirez = I2C_write(I2C_OPENCORES_0_BASE, 55, 0);				// Set TOS H
	spirez = I2C_write(I2C_OPENCORES_0_BASE,  0, 1);				// Set TOS L

}

/*
void testFlash(void)
{
	uint16_t cnt = 0, page = 0;
	uint8_t spirez;


	spirez = FlashSpiEraseSector(SPI_FPGA_AS_BASE, SPI_NR_FLASH, CyTrue, 0);

	for(page = 0; page < 10; page++)
	{
		for(cnt = 0; cnt < 256; cnt++)
		{
			flash_page_data[cnt] = cnt+page;
		}
		spirez = FlashSpiTransfer(SPI_FPGA_AS_BASE, SPI_NR_FLASH, page, FLASH_PAGE_SIZE, flash_page_data, 0);
	}

	for(page = 0; page < 10; page++)
	{
		spirez = FlashSpiTransfer(SPI_FPGA_AS_BASE, SPI_NR_FLASH, page, FLASH_PAGE_SIZE, flash_page_data, 1);
	}

}
*/

/**
 * Main, what else?
 * Gets LEDs pattern from switchers.
 * Sets LEDs register according to the pattern.
 **/
int main()
{
    unsigned char led_pattern = 0x00;
    //volatile uint32_t *uart = (volatile uint32_t*) UART_BASE;
    //char *str = "Hello from NIOS II\r\n";

    volatile int spirez;
    char cnt = 0;

    uint8_t status = 0;

    //Reset LMS7
    IOWR(LMS_CTR_GPIO_BASE, 0, 0x06);
    IOWR(LMS_CTR_GPIO_BASE, 0, 0x07);

    //
    uint8_t spi_wrbuf1[2] = {0x00, 0x20};
    uint8_t spi_wrbuf2[6] = {0x80, 0x20, 0xFF, 0xFD, 0x00, 0x20};
    //uint8_t spi_rdbuf[2] = {0x01, 0x00};

    // Write initial data to the DAC
	dac_data[0] = (dac_val) >>2; //POWER-DOWN MODE = NORMAL OPERATION (MSB bits =00) + MSB data
	dac_data[1] = (dac_val) <<6; //LSB data
	spirez = alt_avalon_spi_command(SPI_LMS_BASE, SPI_NR_DAC, 2, dac_data, 0, NULL, 0);

    //FLASH MEMORY
    spi_wrbuf1[0] = FLASH_CMD_READJEDECID;	//
    spirez = alt_avalon_spi_command(SPI_FPGA_AS_BASE, SPI_NR_FLASH, 1, spi_wrbuf1, 3, spi_wrbuf2, 0);

	//flash_page_data[FLASH_PAGE_SIZE];
    //testFlash();
    /*
	spirez = FlashSpiTransfer(SPI_FPGA_AS_BASE, SPI_NR_FLASH, 0x0000, FLASH_PAGE_SIZE, flash_page_data, 1);
	spirez = FlashSpiTransfer(SPI_FPGA_AS_BASE, SPI_NR_FLASH, 0x0001, FLASH_PAGE_SIZE, flash_page_data, 1);
	spirez = FlashSpiTransfer(SPI_FPGA_AS_BASE, SPI_NR_FLASH, 0x0002, FLASH_PAGE_SIZE, flash_page_data, 1);
	spirez = FlashSpiTransfer(SPI_FPGA_AS_BASE, SPI_NR_FLASH, 0x0003, FLASH_PAGE_SIZE, flash_page_data, 1);
	spirez = FlashSpiTransfer(SPI_FPGA_AS_BASE, SPI_NR_FLASH, 0x0004, FLASH_PAGE_SIZE, flash_page_data, 1);
	spirez = FlashSpiTransfer(SPI_FPGA_AS_BASE, SPI_NR_FLASH, 0x0005, FLASH_PAGE_SIZE, flash_page_data, 1);
	spirez = FlashSpiTransfer(SPI_FPGA_AS_BASE, SPI_NR_FLASH, 0x0006, FLASH_PAGE_SIZE, flash_page_data, 1);
	spirez = FlashSpiTransfer(SPI_FPGA_AS_BASE, SPI_NR_FLASH, 0x0007, FLASH_PAGE_SIZE, flash_page_data, 1);
	spirez = FlashSpiTransfer(SPI_FPGA_AS_BASE, SPI_NR_FLASH, 0x0008, FLASH_PAGE_SIZE, flash_page_data, 1);
	spirez = FlashSpiTransfer(SPI_FPGA_AS_BASE, SPI_NR_FLASH, 0x0009, FLASH_PAGE_SIZE, flash_page_data, 1);
	spirez = FlashSpiTransfer(SPI_FPGA_AS_BASE, SPI_NR_FLASH, 0x000A, FLASH_PAGE_SIZE, flash_page_data, 1);
	//spirez = FlashSpiTransfer(SPI_FPGA_AS_BASE, SPI_NR_FLASH, 0x0010, 10, flash_page_data, 1);
	*/

    // I2C initialiazation
    I2C_init(I2C_OPENCORES_0_BASE, ALT_CPU_FREQ, 400000);

    // Configure LM75
    Configure_LM75();
/*
 	//Si5351C
    spirez = I2C_start(I2C_OPENCORES_0_BASE, SI5351_I2C_ADDR, 0);
    spirez = I2C_write(I2C_OPENCORES_0_BASE, 0x09, 0);
    spirez = I2C_write(I2C_OPENCORES_0_BASE, 0x0F, 1);


    spirez = I2C_start(I2C_OPENCORES_0_BASE, SI5351_I2C_ADDR, 0);
    spirez = I2C_write(I2C_OPENCORES_0_BASE, 0x09, 1);
    spirez = I2C_start(I2C_OPENCORES_0_BASE, SI5351_I2C_ADDR, 1);
    spirez = I2C_read(I2C_OPENCORES_0_BASE, 1);
*/

 /*
    // LM75
	spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 0);
	spirez = I2C_write(I2C_OPENCORES_0_BASE, 0x00, 1);				// Pointer = temperature register
	spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 1);

	converted_val = (signed short int)I2C_read(I2C_OPENCORES_0_BASE, 0);
	//converted_val = 0xE7 << 8;	// Test -25 deg
	converted_val = 10 * (converted_val >> 8);
	spirez = I2C_read(I2C_OPENCORES_0_BASE, 1);

	if(spirez & 0x80) converted_val = converted_val + 5;
*/

    while (1)	// infinite loop
    {
        led_pattern = IORD(SWITCH_BASE, 0);     // gets LEDs
        set_led(led_pattern<<3);                     // sets LEDs


        // SPI
        //spirez = alt_avalon_spi_command(SPI_LMS_BASE, 0, 2, spi_wrbuf1, 2, spi_rdbuf, 0);
        //spirez = alt_avalon_spi_command(SPI_LMS_BASE, 0, 6, spi_wrbuf2, 2, spi_rdbuf, 0);
        //spirez = alt_avalon_spi_command(SPI_LMS_BASE, 0, 2, spi_wrbuf1, 2, spi_rdbuf, 0);

        //FLASH MEMORY
        //spi_wrbuf1[0] = ReverseBitOrder(0x9F);	//
        //spirez = alt_avalon_spi_command(SPI_FPGA_AS_BASE, SPI_NR_FLASH, 1, spi_wrbuf1, 3, spi_wrbuf2, 0);
        //spi_wrbuf2[0] = ReverseBitOrder(spi_wrbuf2[0]);
        //spi_wrbuf2[1] = ReverseBitOrder(spi_wrbuf2[1]);
        //spi_wrbuf2[2] = ReverseBitOrder(spi_wrbuf2[2]);




        // FIFO
        //IOWR(AV_FIFO_INT_0_BASE, 0, cnt);		// Write Data to FIFO
        //cnt++;
        spirez = IORD(AV_FIFO_INT_0_BASE, 2);	// Read FIFO Status
        if(!(spirez & 0x01))
        {
        	//Read packet from the FIFO
        	getFifoData(glEp0Buffer_Rx, 64);

         	memset (glEp0Buffer_Tx, 0, sizeof(glEp0Buffer_Tx)); //fill whole tx buffer with zeros
         	cmd_errors = 0;

     		LMS_Ctrl_Packet_Tx->Header.Command = LMS_Ctrl_Packet_Rx->Header.Command;
     		LMS_Ctrl_Packet_Tx->Header.Data_blocks = LMS_Ctrl_Packet_Rx->Header.Data_blocks;
     		LMS_Ctrl_Packet_Tx->Header.Periph_ID = LMS_Ctrl_Packet_Rx->Header.Periph_ID;
     		LMS_Ctrl_Packet_Tx->Header.Status = STATUS_BUSY_CMD;

     		switch(LMS_Ctrl_Packet_Rx->Header.Command)
     		{

 				case CMD_GET_INFO:

 					LMS_Ctrl_Packet_Tx->Data_field[0] = FW_VER;
 					LMS_Ctrl_Packet_Tx->Data_field[1] = DEV_TYPE;
 					LMS_Ctrl_Packet_Tx->Data_field[2] = LMS_PROTOCOL_VER;
 					LMS_Ctrl_Packet_Tx->Data_field[3] = HW_VER;
 					LMS_Ctrl_Packet_Tx->Data_field[4] = EXP_BOARD;

 					LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
 				break;

 				case CMD_LMS_RST:

 					switch (LMS_Ctrl_Packet_Rx->Data_field[0])
 					{
 						case LMS_RST_DEACTIVATE:
 							IOWR(LMS_CTR_GPIO_BASE, 0, 0x07);
 						break;

 						case LMS_RST_ACTIVATE:
 							IOWR(LMS_CTR_GPIO_BASE, 0, 0x06);
 						break;

 						case LMS_RST_PULSE:
 							IOWR(LMS_CTR_GPIO_BASE, 0, 0x06);
 							asm("nop"); asm("nop"); asm("nop"); asm("nop"); asm("nop");
 							asm("nop"); asm("nop"); asm("nop"); asm("nop"); asm("nop");
 							IOWR(LMS_CTR_GPIO_BASE, 0, 0x07);
 						break;

 						default:
 							cmd_errors++;
 						break;
 					}

 					LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
 				break;

 	 			case CMD_LMS7002_WR:
 	 				if(Check_many_blocks (4)) break;

 	 				//CyU3PGpioSetValue (FX3_SPI_CS, CyFalse); //Enable LMS's SPI

 	 				for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
 	 				{
 	 					//write reg addr
 	 					sbi(LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 4)], 7); //set write bit
 	 					/*
 	 					CyU3PSpiTransmitWords (&LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 4)], 1); //reg addr MSB with write bit
 	 					CyU3PSpiTransmitWords (&LMS_Ctrl_Packet_Rx->Data_field[1 + (block * 4)], 1); //reg addr LSB

 	 					//write reg data
 	 					CyU3PSpiTransmitWords (&LMS_Ctrl_Packet_Rx->Data_field[2 + (block * 4)], 1); //reg data MSB
 	 					CyU3PSpiTransmitWords (&LMS_Ctrl_Packet_Rx->Data_field[3 + (block * 4)], 1); //reg data LSB
 	 					*/
 	 					spirez = alt_avalon_spi_command(SPI_LMS_BASE, SPI_NR_LMS7002M, 4, &LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 4)], 0, NULL, 0);
 	 				}

 	 				//CyU3PGpioSetValue (FX3_SPI_CS, CyTrue); //Disable LMS's SPI

 	 				LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
 	 			break;

 				case CMD_LMS7002_RD:
 					if(Check_many_blocks (4)) break;

 					//CyU3PGpioSetValue (FX3_SPI_CS, CyFalse); //Enable LMS's SPI

 					for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
 					{

 						//write reg addr
 						cbi(LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 2)], 7);  //clear write bit
 						/*
 						CyU3PSpiTransmitWords (&LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 2)], 1); //reg addr MSB
 						CyU3PSpiTransmitWords (&LMS_Ctrl_Packet_Rx->Data_field[1 + (block * 2)], 1); //reg addr LSB

 						LMS_Ctrl_Packet_Tx->Data_field[0 + (block * 4)] = LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 2)];
 						LMS_Ctrl_Packet_Tx->Data_field[1 + (block * 4)] = LMS_Ctrl_Packet_Rx->Data_field[1 + (block * 2)];

 						//read reg data
 						CyU3PSpiReceiveWords (&LMS_Ctrl_Packet_Tx->Data_field[2 + (block * 4)], 1); //reg data MSB
 						CyU3PSpiReceiveWords (&LMS_Ctrl_Packet_Tx->Data_field[3 + (block * 4)], 1); //reg data LSB
 						*/
 						spirez = alt_avalon_spi_command(SPI_LMS_BASE, SPI_NR_LMS7002M, 2, &LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 2)], 2, &LMS_Ctrl_Packet_Tx->Data_field[2 + (block * 4)], 0);
 					}

 					//CyU3PGpioSetValue (FX3_SPI_CS, CyTrue); //Disable LMS's SPI

 					LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
 				break;


 	 			case CMD_BRDSPI16_WR:
 	 				if(Check_many_blocks (4)) break;

 	 				//CyU3PGpioSetValue (FX3_SPI_CS, CyFalse); //Enable LMS's SPI

 	 				for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
 	 				{
 	 					//write reg addr
 	 					sbi(LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 4)], 7); //set write bit
 	 					/*
 	 					CyU3PSpiTransmitWords (&LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 4)], 1); //reg addr MSB with write bit
 	 					CyU3PSpiTransmitWords (&LMS_Ctrl_Packet_Rx->Data_field[1 + (block * 4)], 1); //reg addr LSB

 	 					//write reg data
 	 					CyU3PSpiTransmitWords (&LMS_Ctrl_Packet_Rx->Data_field[2 + (block * 4)], 1); //reg data MSB
 	 					CyU3PSpiTransmitWords (&LMS_Ctrl_Packet_Rx->Data_field[3 + (block * 4)], 1); //reg data LSB
 	 					*/
 	 					spirez = alt_avalon_spi_command(SPI_LMS_BASE, SPI_NR_FPGA, 4, &LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 4)], 0, NULL, 0);
 	 				}

 	 				//CyU3PGpioSetValue (FX3_SPI_CS, CyTrue); //Disable LMS's SPI

 	 				LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
 	 			break;

 				case CMD_BRDSPI16_RD:
 					if(Check_many_blocks (4)) break;

 					//CyU3PGpioSetValue (FX3_SPI_CS, CyFalse); //Enable LMS's SPI

 					for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
 					{

 						//write reg addr
 						cbi(LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 2)], 7);  //clear write bit
 						/*
 						CyU3PSpiTransmitWords (&LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 2)], 1); //reg addr MSB
 						CyU3PSpiTransmitWords (&LMS_Ctrl_Packet_Rx->Data_field[1 + (block * 2)], 1); //reg addr LSB

 						LMS_Ctrl_Packet_Tx->Data_field[0 + (block * 4)] = LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 2)];
 						LMS_Ctrl_Packet_Tx->Data_field[1 + (block * 4)] = LMS_Ctrl_Packet_Rx->Data_field[1 + (block * 2)];

 						//read reg data
 						CyU3PSpiReceiveWords (&LMS_Ctrl_Packet_Tx->Data_field[2 + (block * 4)], 1); //reg data MSB
 						CyU3PSpiReceiveWords (&LMS_Ctrl_Packet_Tx->Data_field[3 + (block * 4)], 1); //reg data LSB
 						*/
 						spirez = alt_avalon_spi_command(SPI_LMS_BASE, SPI_NR_FPGA, 2, &LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 2)], 2, &LMS_Ctrl_Packet_Tx->Data_field[2 + (block * 4)], 0);
 					}

 					//CyU3PGpioSetValue (FX3_SPI_CS, CyTrue); //Disable LMS's SPI

 					LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
 				break;

 				case CMD_ADF4002_WR:
 					if(Check_many_blocks (3)) break;

 					for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
 					{
 						switch(LMS_Ctrl_Packet_Rx->Header.Periph_ID)
 						{
 							case 0: //onboard
 								//CyU3PGpioSetValue (FX3_ADF_SNN, CyFalse); //Enable onboard ADF's SPI
 								break;
 							case 1: //fmc
 								//Modify_BRDSPI16_Reg_bits (0x14, BRD_SPI_ADF_SS, BRD_SPI_ADF_SS, 0); //Enable ADF's SPI
 								break;
 							default:
 								cmd_errors++;
 								break;
 						}

 						//CyU3PSpiTransmitWords (&LMS_Ctrl_Packet_Rx->Data_field[0 + (block*3)], 1);
 						//CyU3PSpiTransmitWords (&LMS_Ctrl_Packet_Rx->Data_field[1 + (block*3)], 1);
 						//CyU3PSpiTransmitWords (&LMS_Ctrl_Packet_Rx->Data_field[2 + (block*3)], 1);
 						spirez = alt_avalon_spi_command(SPI_1_ADF4002_BASE, SPI_NR_ADF4002, 3, &LMS_Ctrl_Packet_Rx->Data_field[0 + (block*3)], 0, NULL, 0);

 						switch(LMS_Ctrl_Packet_Rx->Header.Periph_ID)
 						{
 							case 0: //onboard
 								//CyU3PGpioSetValue (FX3_ADF_SNN, CyTrue); //Disable ADF's SPI
 							break;
 							case 1: //fmc
 								//Modify_BRDSPI16_Reg_bits (0x14, BRD_SPI_ADF_SS, BRD_SPI_ADF_SS, 1); //Disable ADF's SPI
 							break;
 							default:
 								cmd_errors++;
 							break;
 						}
 					}

 					if(cmd_errors) LMS_Ctrl_Packet_Tx->Header.Status = STATUS_INVALID_PERIPH_ID_CMD;
 					else LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
 				break;


				case CMD_ANALOG_VAL_RD:

					for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
					{


						//signed short int converted_val = 300;

						switch (LMS_Ctrl_Packet_Rx->Data_field[0 + (block)])//ch
						{
							case 0://dac val

								LMS_Ctrl_Packet_Tx->Data_field[0 + (block * 4)] = LMS_Ctrl_Packet_Rx->Data_field[block]; //ch
								LMS_Ctrl_Packet_Tx->Data_field[1 + (block * 4)] = 0x00; //RAW //unit, power

								LMS_Ctrl_Packet_Tx->Data_field[2 + (block * 4)] = 0; //signed val, MSB byte
								LMS_Ctrl_Packet_Tx->Data_field[3 + (block * 4)] = dac_val; //signed val, LSB byte
								break;

							case 1: //temperature
/*
								I2C_Addr = 0x90; //LM75 I2C_ADDR

								//read byte
								preamble.length = 3;

								I2C_Addr &= ~(1 << 0);//write addr
								preamble.buffer[0] = I2C_Addr;

								preamble.buffer[1] = 0x00; //temperature

								I2C_Addr |= 1 << 0;	//read addr

								preamble.buffer[2] = I2C_Addr;
								preamble.ctrlMask  = 0x0002;

								if( CyU3PI2cReceiveBytes (&preamble, &sc_brdg_data[0], 2, 0)  != CY_U3P_SUCCESS)  cmd_errors++;

								//converted_val = 0x1234; //35,678C
*/

								spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 0);
								spirez = I2C_write(I2C_OPENCORES_0_BASE, 0x00, 1);				// Pointer = temperature register
								spirez = I2C_start(I2C_OPENCORES_0_BASE, LM75_I2C_ADDR, 1);

								// Read temperature and recalculate
								converted_val = (signed short int)I2C_read(I2C_OPENCORES_0_BASE, 0);
								converted_val = converted_val << 8;
								converted_val = 10 * (converted_val >> 8);
								spirez = I2C_read(I2C_OPENCORES_0_BASE, 1);
								if(spirez & 0x80) converted_val = converted_val + 5;



/*
								converted_val = (((signed short int)sc_brdg_data[0]) << 8) + 0;//sc_brdg_data[1];
								converted_val = (converted_val/256)*10;

								if(sc_brdg_data[1]&0x80) converted_val = converted_val + 5;
*/
								LMS_Ctrl_Packet_Tx->Data_field[0 + (block * 4)] = LMS_Ctrl_Packet_Rx->Data_field[block]; //ch
								LMS_Ctrl_Packet_Tx->Data_field[1 + (block * 4)] = 0x50; //mC //unit, power

								LMS_Ctrl_Packet_Tx->Data_field[2 + (block * 4)] = (converted_val >> 8); //signed val, MSB byte
								LMS_Ctrl_Packet_Tx->Data_field[3 + (block * 4)] = converted_val; //signed val, LSB byte

							break;

							default:
								cmd_errors++;
							break;
						}
					}

					LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;

				break;


				case CMD_ANALOG_VAL_WR:
					if(Check_many_blocks (4)) break;

					for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
					{
						switch (LMS_Ctrl_Packet_Rx->Data_field[0 + (block * 4)]) //do something according to channel
						{
							case 0:
								if (LMS_Ctrl_Packet_Rx->Data_field[1 + (block * 4)] == 0) //RAW units?
								{
									if(LMS_Ctrl_Packet_Rx->Data_field[2 + (block * 4)] == 0) //MSB byte empty?
									{
										dac_val = LMS_Ctrl_Packet_Rx->Data_field[3 + (block * 4)];

										dac_data[0] = (dac_val >> 2) & 0x3F; //POWER-DOWN MODE = NORMAL OPERATION (MSB bits =00) + MSB data
										dac_data[1] = (dac_val << 6) & 0xC0; //LSB data

										//if( CyU3PI2cTransmitBytes (&preamble, &sc_brdg_data[0], 2, 0) != CY_U3P_SUCCESS)  cmd_errors++;
										spirez = alt_avalon_spi_command(SPI_1_BASE, SPI_NR_DAC, 2, dac_data, 0, NULL, 0);
									}
									else cmd_errors++;
								}
								else cmd_errors++;

							break;

							default:
								cmd_errors++;
							break;
						}
					}


					if(cmd_errors) LMS_Ctrl_Packet_Tx->Header.Status = STATUS_ERROR_CMD;
					else LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;

				break;







				case CMD_ALTERA_FPGA_GW_WR: //FPGA passive serial

					current_portion = (LMS_Ctrl_Packet_Rx->Data_field[1] << 24) | (LMS_Ctrl_Packet_Rx->Data_field[2] << 16) | (LMS_Ctrl_Packet_Rx->Data_field[3] << 8) | (LMS_Ctrl_Packet_Rx->Data_field[4]);
					data_cnt = LMS_Ctrl_Packet_Rx->Data_field[5];

					switch(LMS_Ctrl_Packet_Rx->Data_field[0])//prog_mode
					{
						/*
						Programming mode:

						0 - Bitstream to FPGA
						1 - Bitstream to Flash
						2 - Bitstream from Flash
						*/

						case 0://Bitstream to FPGA from PC
							/*
							if ( Configure_FPGA (&LMS_Ctrl_Packet_Rx->Data_field[24], current_portion, data_cnt) ) LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
							else LMS_Ctrl_Packet_Tx->Header.Status = STATUS_ERROR_CMD;
							*/
							LMS_Ctrl_Packet_Tx->Header.Status = STATUS_ERROR_CMD;

						break;

						case 1: //write data to Flash from PC
							//Flash_ID();
							//Reconfigure_SPI_for_Flash ();

							if(current_portion == 0)//beginning
							{
								flash_page = 0;
								flash_page_data_cnt = 0;
								flash_data_counter_to_copy = 0;
								fpga_byte = 0;

								//**status = FlashSpiEraseSector(CyTrue, FLASH_LAYOUT_FPGA_METADATA); //erase sector for FPGA autoload metadata
							}

							flash_data_cnt_free = FLASH_PAGE_SIZE - flash_page_data_cnt;

							if (flash_data_cnt_free > 0)
							{
								if (flash_data_cnt_free > data_cnt)
									flash_data_counter_to_copy = data_cnt; //copy all data if fits to free page space
								else
									flash_data_counter_to_copy = flash_data_cnt_free; //copy only amount of data that fits in to free page size

								memcpy(&flash_page_data[flash_page_data_cnt], &LMS_Ctrl_Packet_Rx->Data_field[24], flash_data_counter_to_copy);

								flash_page_data_cnt = flash_page_data_cnt + flash_data_counter_to_copy;
								flash_data_cnt_free = FLASH_PAGE_SIZE - flash_page_data_cnt;

								if (data_cnt == 0)//all bytes transmitted, end of programming
								{
									if (flash_page_data_cnt > 0)
										flash_page_data_cnt = FLASH_PAGE_SIZE; //finish page
								}

								flash_data_cnt_free = FLASH_PAGE_SIZE - flash_page_data_cnt;

							}

							//Write data
							if (flash_page_data_cnt >= FLASH_PAGE_SIZE)
							{
								status = 0;
								if ((flash_page % (FLASH_SECTOR_SIZE/FLASH_PAGE_SIZE)) == 0) //need to erase sector? reached number of pages in block?
									status = FlashSpiEraseSector(SPI_FPGA_AS_BASE, SPI_NR_FLASH, CyTrue, FLASH_LAYOUT_FPGA_BITSTREAM + flash_page/(FLASH_SECTOR_SIZE/FLASH_PAGE_SIZE));

								status += FlashSpiTransfer(SPI_FPGA_AS_BASE, SPI_NR_FLASH, (FLASH_LAYOUT_FPGA_BITSTREAM * FLASH_SECTOR_SIZE/FLASH_PAGE_SIZE) + flash_page, FLASH_PAGE_SIZE, flash_page_data, CyFalse);//write to flash

								//Break the loop and issue an error if something went wrong in FLASH sector erase or programming commands
								if(status)
								{
									LMS_Ctrl_Packet_Tx->Header.Status = STATUS_ERROR_CMD;
									break;
								}

								flash_page++;

								flash_page_data_cnt = 0;
								flash_data_cnt_free = FLASH_PAGE_SIZE; // - flash_page_data_cnt;
							}

							//if not all bytes written to flash page
							if (data_cnt > flash_data_counter_to_copy)
							{
								flash_data_counter_to_copy = data_cnt - flash_data_counter_to_copy;

								memcpy(&flash_page_data[flash_page_data_cnt], &LMS_Ctrl_Packet_Rx->Data_field[24], data_cnt);

								flash_page_data_cnt = flash_page_data_cnt + flash_data_counter_to_copy;
								flash_data_cnt_free = FLASH_PAGE_SIZE - flash_page_data_cnt;
							}

							fpga_byte = fpga_byte + data_cnt;

							if (fpga_byte <= FPGA_SIZE) //correct bitream size?
							{
								if (data_cnt == 0)//end of programming
								{
									Board_Config_FPGA->Bitream_size = fpga_byte; //bitsream ok
									Board_Config_FPGA->Autoload = 1; //autoload
									//**status = FlashSpiEraseSector(CyTrue, FLASH_LAYOUT_FPGA_METADATA); //erase sector for FPGA autoload metadata
									//**FlashSpiTransfer((FLASH_LAYOUT_FPGA_METADATA * FLASH_SECTOR_SIZE/FLASH_PAGE_SIZE), FLASH_PAGE_SIZE, flash_page_data, CyFalse);//write to flash
								}

								LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
							}
							else //not correct bitsream size
								LMS_Ctrl_Packet_Tx->Header.Status = STATUS_ERROR_CMD;

						break;

						case 2: //configure FPGA from flash
							/*
							if (FPGA_config_thread_runnning == 0)
							{
								Reconfigure_SPI_for_Flash ();
								FlashSpiTransfer((FLASH_LAYOUT_FPGA_METADATA * FLASH_SECTOR_SIZE/FLASH_PAGE_SIZE), FLASH_PAGE_SIZE, flash_page_data, CyTrue); //read from flash

								if(Board_Config_FPGA->Bitream_size <= FPGA_SIZE) //bitsream size ok?
								{
									fpga_bitstream_size = Board_Config_FPGA->Bitream_size;
									FPGA_config_thread_start ();
									LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
									break;
								}
							}
							*/
							LMS_Ctrl_Packet_Tx->Header.Status = STATUS_ERROR_CMD;

						break;

						default:
							LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;
						break;

					}

				break;


	 			case CMD_SI5351_WR:
	 				if(Check_many_blocks(2)) break;

	        		//I2C_Addr = SI5351_I2C_ADDR;

	 				for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
	 				{
	 					/*
	            		//write byte
	 					preamble.length    = 2;
	 					preamble.buffer[0] = I2C_Addr; //write h70;
	 					preamble.buffer[1] = LMS_Ctrl_Packet_Rx->Data_field[block * 2]; //reg to write
	 					preamble.ctrlMask  = 0x0000;

	 					if( CyU3PI2cTransmitBytes (&preamble, &LMS_Ctrl_Packet_Rx->Data_field[1 + (block * 2)], 1, 0) != CY_U3P_SUCCESS)  cmd_errors++;
	 					*/

	 					cmd_errors += I2C_start(I2C_OPENCORES_0_BASE, SI5351_I2C_ADDR, 0);
	 					cmd_errors += I2C_write(I2C_OPENCORES_0_BASE, LMS_Ctrl_Packet_Rx->Data_field[block * 2    ], 0);
	 					cmd_errors += I2C_write(I2C_OPENCORES_0_BASE, LMS_Ctrl_Packet_Rx->Data_field[block * 2 + 1], 1);
	 				}

	 				if(cmd_errors) LMS_Ctrl_Packet_Tx->Header.Status = STATUS_ERROR_CMD;
	 				else LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;

	 			break;


 				case CMD_SI5351_RD:
 					if(Check_many_blocks (2)) break;
/*
 					I2C_Addr = SI5351_I2C_ADDR;

 					for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
 					{
        		        //read byte
        		        preamble.length = 3;

        		        I2C_Addr &= ~(1 << 0);//write addr
        		        preamble.buffer[0] = I2C_Addr;//0xE0; //write h70;

        		        preamble.buffer[1] = LMS_Ctrl_Packet_Rx->Data_field[block]; //reg to read

        		        I2C_Addr |= 1 << 0;	//read addr

        		        preamble.buffer[2] = I2C_Addr;//0xE1; //read h70
        		        preamble.ctrlMask  = 0x0002;

        		        if( CyU3PI2cReceiveBytes (&preamble, &LMS_Ctrl_Packet_Tx->Data_field[1 + block * 2], 1, 0)  != CY_U3P_SUCCESS)  cmd_errors++;

 						LMS_Ctrl_Packet_Tx->Data_field[block * 2] = LMS_Ctrl_Packet_Rx->Data_field[block];
 					}
*/
 					for(block = 0; block < LMS_Ctrl_Packet_Rx->Header.Data_blocks; block++)
 					{
 						cmd_errors += I2C_start(I2C_OPENCORES_0_BASE, SI5351_I2C_ADDR, 0);
 						cmd_errors += I2C_write(I2C_OPENCORES_0_BASE, LMS_Ctrl_Packet_Rx->Data_field[block], 1);
 						cmd_errors += I2C_start(I2C_OPENCORES_0_BASE, SI5351_I2C_ADDR, 1);

 						LMS_Ctrl_Packet_Tx->Data_field[block * 2    ] = LMS_Ctrl_Packet_Rx->Data_field[block];
 						LMS_Ctrl_Packet_Tx->Data_field[block * 2 + 1] = I2C_read(I2C_OPENCORES_0_BASE, 1);
 					}

 					if(cmd_errors) LMS_Ctrl_Packet_Tx->Header.Status = STATUS_ERROR_CMD;
 					else LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;

 				break;


				case CMD_LMS_MCU_FW_WR:

					current_portion = LMS_Ctrl_Packet_Rx->Data_field[1];

					//check if portions are send in correct order
					if(current_portion != 0) //not first portion?
					{
						if(last_portion != (current_portion - 1)) //portion number increments?
						{
							LMS_Ctrl_Packet_Tx->Header.Status = STATUS_WRONG_ORDER_CMD;
							break;
						}
					}

					if (current_portion == 0) //PORTION_NR = first fifo
					{
						//reset mcu
						//write reg addr - mSPI_REG2 (Controls MCU input pins)
						sc_brdg_data[0] = (0x80); //reg addr MSB with write bit
						sc_brdg_data[1] = (MCU_CONTROL_REG); //reg addr LSB

						sc_brdg_data[2] = (0x00); //reg data MSB
						sc_brdg_data[3] = (0x00); //reg data LSB //8

						spirez = alt_avalon_spi_command(SPI_LMS_BASE, SPI_NR_LMS7002M, 4, &sc_brdg_data[0], 0, NULL, 0);

						//set mode
						//write reg addr - mSPI_REG2 (Controls MCU input pins)
						sc_brdg_data[0] = (0x80); //reg addr MSB with write bit
						sc_brdg_data[1] = (MCU_CONTROL_REG); //reg addr LSB

						sc_brdg_data[2] = (0x00); //reg data MSB

						//reg data LSB
						switch (LMS_Ctrl_Packet_Rx->Data_field[0]) //PROG_MODE
						{
							case PROG_EEPROM:
								sc_brdg_data[3] = (0x01); //Programming both EEPROM and SRAM  //8
								spirez = alt_avalon_spi_command(SPI_LMS_BASE, SPI_NR_LMS7002M, 4, &sc_brdg_data[0], 0, NULL, 0);
								break;

							case PROG_SRAM:
								sc_brdg_data[3] =(0x02); //Programming only SRAM  //8
								spirez = alt_avalon_spi_command(SPI_LMS_BASE, SPI_NR_LMS7002M, 4, &sc_brdg_data[0], 0, NULL, 0);
								break;


							case BOOT_MCU:
								sc_brdg_data[3] = (0x03); //Programming both EEPROM and SRAM  //8
								spirez = alt_avalon_spi_command(SPI_LMS_BASE, SPI_NR_LMS7002M, 4, &sc_brdg_data[0], 0, NULL, 0);

								//spi read
								//write reg addr
								sc_brdg_data[0] = (0x00); //reg addr MSB
								sc_brdg_data[1] = (MCU_STATUS_REG); //reg addr LSB

								spirez = alt_avalon_spi_command(SPI_LMS_BASE, SPI_NR_LMS7002M, 2, &sc_brdg_data[0], 2, &sc_brdg_data[0], 0);

								goto BOOTING;

								break;
						}
					}

					MCU_retries = 0;

					//wait till EMPTY_WRITE_BUFF = 1
					while (MCU_retries < MAX_MCU_RETRIES)
					{
						//read status reg

						//spi read
						//write reg addr
						sc_brdg_data[0] = (0x00); //reg addr MSB
						sc_brdg_data[1] = (MCU_STATUS_REG); //reg addr LSB

						spirez = alt_avalon_spi_command(SPI_LMS_BASE, SPI_NR_LMS7002M, 2, &sc_brdg_data[0], 2, &sc_brdg_data[0], 0);

						if (sc_brdg_data[1] &0x01) break; //EMPTY_WRITE_BUFF = 1

						MCU_retries++;
						usleep (30);
					}

					//write 32 bytes to FIFO
					for(block = 0; block < 32; block++)
					{
						/*
						//wait till EMPTY_WRITE_BUFF = 1
						while (MCU_retries < MAX_MCU_RETRIES)
						{
							//read status reg

							//spi read
							//write reg addr
							SPI_SendByte(0x00); //reg addr MSB
							SPI_SendByte(MCU_STATUS_REG); //reg addr LSB

							//read reg data
							SPI_TransferByte(0x00); //reg data MSB
							temp_status = SPI_TransferByte(0x00); //reg data LSB

							if (temp_status &0x01) break;

							MCU_retries++;
							Delay_us (30);
						}*/

						//write reg addr - mSPI_REG4 (Writes one byte of data to MCU  )
						sc_brdg_data[0] = (0x80); //reg addr MSB with write bit
						sc_brdg_data[1] = (MCU_FIFO_WR_REG); //reg addr LSB

						sc_brdg_data[2] = (0x00); //reg data MSB
						sc_brdg_data[3] = (LMS_Ctrl_Packet_Rx->Data_field[2 + block]); //reg data LSB //8

						spirez = alt_avalon_spi_command(SPI_LMS_BASE, SPI_NR_LMS7002M, 4, &sc_brdg_data[0], 0, NULL, 0);

						MCU_retries = 0;
					}

					/*sbi (PORTB, SAEN); //Enable LMS's SPI
					cbi (PORTB, SAEN); //Enable LMS's SPI*/


					MCU_retries = 0;

					//wait till EMPTY_WRITE_BUFF = 1
					while (MCU_retries < 500)
					{
						//read status reg

						//spi read
						//write reg addr
						sc_brdg_data[0] = (0x00); //reg addr MSB
						sc_brdg_data[1] = (MCU_STATUS_REG); //reg addr LSB

						spirez = alt_avalon_spi_command(SPI_LMS_BASE, SPI_NR_LMS7002M, 2, &sc_brdg_data[0], 2, &sc_brdg_data[0], 0);

						if (sc_brdg_data[1] &0x01) break; //EMPTY_WRITE_BUFF = 1

						MCU_retries++;
						usleep (30);
					}


					if (current_portion  == 255) //PORTION_NR = last fifo
					{
						//chek programmed bit

						MCU_retries = 0;

						//wait till PROGRAMMED = 1
						while (MCU_retries < MAX_MCU_RETRIES)
						{
							//read status reg

							//spi read
							//write reg addr
							sc_brdg_data[0] = (0x00); //reg addr MSB
							sc_brdg_data[1] = (MCU_STATUS_REG); //reg addr LSB

							spirez = alt_avalon_spi_command(SPI_LMS_BASE, SPI_NR_LMS7002M, 2, &sc_brdg_data[0], 2, &sc_brdg_data[0], 0);

							if (sc_brdg_data[1] &0x40) break; //PROGRAMMED = 1

							MCU_retries++;
							usleep (30);
						}

						if (MCU_retries == MAX_MCU_RETRIES) cmd_errors++;
					}

					last_portion = current_portion; //save last portion number

					BOOTING:

					if(cmd_errors) LMS_Ctrl_Packet_Tx->Header.Status = STATUS_ERROR_CMD;
					else LMS_Ctrl_Packet_Tx->Header.Status = STATUS_COMPLETED_CMD;

				break;


 				default:
 					/* This is unknown request. */
 					//isHandled = CyFalse;
 					LMS_Ctrl_Packet_Tx->Header.Status = STATUS_UNKNOWN_CMD;
 				break;
     		}

     		//Send response to the command
        	for(cnt=0; cnt<64; cnt++)
        	{
        		IOWR(AV_FIFO_INT_0_BASE, 0, glEp0Buffer_Tx[cnt]);
        	};


        };

        //IOWR(AV_FIFO_INT_0_BASE, 0, cnt);		// Write Data to FIFO


        //IOWR(AV_FIFO_INT_0_BASE, 3, 1);		// Toggle FIFO reset
        //IOWR(AV_FIFO_INT_0_BASE, 3, 0);		// Toggle FIFO reset



/*
        // UART
        char *ptr = str;
        while (*ptr != '\0')
        {
           while ((uart[2] & (1<<6)) == 0);
           uart[1] = *ptr;
           ptr++;
        }
*/

    }

    return 0;	//Just make compiler happy!
}
