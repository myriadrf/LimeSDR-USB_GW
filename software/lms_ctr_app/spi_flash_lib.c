/*
 * spi_flash_lib.c
 *
 *  Created on: Feb 3, 2016
 *      Author: zydrunas
 */

#include "spi_flash_lib.h"
#include <altera_avalon_spi.h>
#include "sodera_pcie_brd_v1r0.h"


/**
 * Reverses bit order
 */
uint8_t ReverseBitOrder (uint8_t data)
{
	uint8_t rev = data;
	rev = ((rev >> 1) & 0x55) | ((rev << 1) & 0xaa);
	rev = ((rev >> 2) & 0x33) | ((rev << 2) & 0xcc);
	rev = ((rev >> 4) & 0x0f) | ((rev << 4) & 0xf0);
	return rev;
}

char spiFastRead = 0;
void FlashSpiFastRead(CyBool_t v) {
    spiFastRead = v;
}

/* SPI read / write for programmer application. */
uint8_t FlashSpiTransfer(alt_u32 SPIBase, alt_u32 SPISlave, uint32_t pageAddress, uint16_t byteCount, uint8_t *buffer, CyBool_t isRead)
{
    uint8_t location[4];
    uint32_t byteAddress = 0;
    uint16_t pageCount = (byteCount / FLASH_PAGE_SIZE);
    //CyU3PReturnStatus_t status = CY_U3P_SUCCESS;
    uint8_t status = 0;

    spiFastRead = 1;// force fast read

    if (byteCount == 0)
    {
        return 0; // CY_U3P_SUCCESS;
    }

    if ((byteCount % FLASH_PAGE_SIZE) != 0) {
        return 1;//CY_U3P_ERROR_NOT_SUPPORTED;
    }

    byteAddress = pageAddress * FLASH_PAGE_SIZE;

    while (pageCount != 0) {
        location[1] = ReverseBitOrder((byteAddress >> 16) & 0xFF);       /* MS byte */
        location[2] = ReverseBitOrder((byteAddress >> 8) & 0xFF);
        location[3] = ReverseBitOrder(byteAddress & 0xFF);               /* LS byte */

        if (isRead) {
            location[0] = FLASH_CMD_PAGE_READ;// 0x03; /* Read command. */

            if (!spiFastRead) {
                //status = CyFxSpiWaitForStatus();
                //if (status != CY_U3P_SUCCESS)
                //    return status;
            	status = CyFxSpiWaitForStatus(SPIBase, SPISlave);
            	if (!status)
            	{
            		return status;
            	}
            }

            //CyU3PGpioSetValue (FX3_FLASH2_SNN, CyFalse);//CyU3PSpiSetSsnLine(CyFalse);
            //status = CyU3PSpiTransmitWords(location, 4);

            //if (status != CY_U3P_SUCCESS) {
            //    CyU3PDebugPrint (2, "SPI READ command failed\r\n");
            //    CyU3PGpioSetValue (FX3_FLASH2_SNN, CyTrue);//CyU3PSpiSetSsnLine (CyTrue);
            //    return status;
            //}

            //status = CyU3PSpiReceiveWords(buffer, FLASH_PAGE_SIZE);
            //if (status != CY_U3P_SUCCESS) {
            //	CyU3PGpioSetValue (FX3_FLASH2_SNN, CyTrue);//CyU3PSpiSetSsnLine(CyTrue);
            //    return status;
            //}

            //CyU3PGpioSetValue (FX3_FLASH2_SNN, CyTrue);//CyU3PSpiSetSsnLine(CyTrue);

            alt_avalon_spi_command(SPIBase, SPISlave, 4, location, FLASH_PAGE_SIZE, buffer, 0);

        } else { /* Write */
            location[0] = FLASH_CMD_PAGE_WRITE; //0x02; /* Write command */

            //status = CyFxSpiWaitForStatus();
            //if (status != CY_U3P_SUCCESS)
            //    return status;
            status = CyFxSpiWaitForStatus(SPIBase, SPISlave);
        	if (status)
        	{
        		return status;
        	}

            //CyU3PGpioSetValue (FX3_FLASH2_SNN, CyFalse);//CyU3PSpiSetSsnLine(CyFalse);
            //status = CyU3PSpiTransmitWords(location, 4);
            //if (status != CY_U3P_SUCCESS) {
            //    CyU3PDebugPrint(2, "SPI WRITE command failed\r\n");
            //    CyU3PGpioSetValue (FX3_FLASH2_SNN, CyTrue);//CyU3PSpiSetSsnLine(CyTrue);
            //    return status;
            //}

            //status = CyU3PSpiTransmitWords(buffer, FLASH_PAGE_SIZE);
            //if (status != CY_U3P_SUCCESS) {
            //	CyU3PGpioSetValue (FX3_FLASH2_SNN, CyTrue);//CyU3PSpiSetSsnLine(CyTrue);
            //    return status;
            //}

            //CyU3PGpioSetValue (FX3_FLASH2_SNN, CyTrue);//CyU3PSpiSetSsnLine(CyTrue);

            alt_avalon_spi_command(SPIBase, SPISlave, 4, location, 0, NULL, ALT_AVALON_SPI_COMMAND_MERGE);
            alt_avalon_spi_command(SPIBase, SPISlave, FLASH_PAGE_SIZE, buffer, 0, NULL, 0);
        }

        byteAddress += FLASH_PAGE_SIZE;
        buffer += FLASH_PAGE_SIZE;
        pageCount--;

        //if (!spiFastRead)
        //    CyU3PThreadSleep(15);
    }

    return status; //CY_U3P_SUCCESS;
}

/* Wait for the status response from the SPI flash. */
uint8_t CyFxSpiWaitForStatus(alt_u32 SPIBase, alt_u32 SPISlave)
{
    uint8_t buf[2], rd_buf[2];
    uint32_t retries = 0;
    //CyU3PReturnStatus_t status = CY_U3P_SUCCESS;

    /* Wait for status response from SPI flash device. */
    do {
        buf[0] = FLASH_CMD_PAGE_WRITEEN;  /* Write enable command. */

        //CyU3PGpioSetValue (FX3_FLASH2_SNN, CyFalse);//CyU3PSpiSetSsnLine(CyFalse);
        //status = CyU3PSpiTransmitWords (buf, 1);
        //CyU3PGpioSetValue (FX3_FLASH2_SNN, CyTrue);//CyU3PSpiSetSsnLine(CyTrue);
        alt_avalon_spi_command(SPIBase, SPISlave, 1, buf, 0, NULL, 0);
        //if (status != CY_U3P_SUCCESS) {
        //    CyU3PDebugPrint (2, "SPI WR_ENABLE command failed\n\r");
        //    return status;
        //}

        buf[0] = FLASH_CMD_PAGE_READST;  /* Read status command */

        //CyU3PGpioSetValue (FX3_FLASH2_SNN, CyFalse);//CyU3PSpiSetSsnLine(CyFalse);
        //status = CyU3PSpiTransmitWords(buf, 1);
        //if (status != CY_U3P_SUCCESS) {
        //    CyU3PDebugPrint(2, "SPI READ_STATUS command failed\n\r");
        //    CyU3PGpioSetValue (FX3_FLASH2_SNN, CyTrue);//CyU3PSpiSetSsnLine(CyTrue);
        //    return status;
        //}

        //status = CyU3PSpiReceiveWords(rd_buf, 2);
        //CyU3PGpioSetValue (FX3_FLASH2_SNN, CyTrue);//CyU3PSpiSetSsnLine(CyTrue);
        //if(status != CY_U3P_SUCCESS) {
        //    CyU3PDebugPrint(2, "SPI status read failed\n\r");
        //    return status;
        //}
        alt_avalon_spi_command(SPIBase, SPISlave, 1, buf, 2, rd_buf, 0);

        if (retries >= STATUS_RETRIES)
        {
        	return 1;
        }
        retries++;

    } while ((rd_buf[0] & 0x80) || (!(rd_buf[0] & 0x40))); //while ((rd_buf[0] & 1) || (!(rd_buf[0] & 0x2)));

    return 0; //CY_U3P_SUCCESS;
}


/* Function to erase SPI flash sectors. */
uint8_t FlashSpiEraseSector(alt_u32 SPIBase, alt_u32 SPISlave, uint8_t isErase, uint8_t sector)
{
    uint32_t temp = 0;
    uint8_t  location[4], rdBuf[2];
    //CyU3PReturnStatus_t status = CY_U3P_SUCCESS;
    int rdsz;
    uint32_t retries = 0;

    location[0] = FLASH_CMD_PAGE_WRITEEN;  /* Write enable. */

    //CyU3PGpioSetValue (FX3_FLASH2_SNN, CyFalse);//CyU3PSpiSetSsnLine (CyFalse);
    //status = CyU3PSpiTransmitWords (location, 1);
    //CyU3PGpioSetValue (FX3_FLASH2_SNN, CyTrue);//CyU3PSpiSetSsnLine (CyTrue);
    rdsz = alt_avalon_spi_command(SPIBase, SPISlave, 1, location, 0, NULL, 0);

//    if (status != CY_U3P_SUCCESS)
//        return status;

    if (isErase)
    {
        location[0] = FLASH_CMD_SECTOR_ERASE; // Sector erase.
        temp        = sector * FLASH_SECTOR_SIZE;
        location[1] = ReverseBitOrder((temp >> 16) & 0xFF);
        location[2] = ReverseBitOrder((temp >> 8) & 0xFF);
        location[3] = ReverseBitOrder(temp & 0xFF);

        //CyU3PGpioSetValue (FX3_FLASH2_SNN, CyFalse);//CyU3PSpiSetSsnLine (CyFalse);
        //status = CyU3PSpiTransmitWords (location, 4);
        //CyU3PGpioSetValue (FX3_FLASH2_SNN, CyTrue);//CyU3PSpiSetSsnLine (CyTrue);
        rdsz = alt_avalon_spi_command(SPIBase, SPISlave, 4, location, 0, NULL, 0);
    }

    location[0] = FLASH_CMD_PAGE_READST; // RDSTATUS
    do {
    	//CyU3PGpioSetValue (FX3_FLASH2_SNN, CyFalse);//CyU3PSpiSetSsnLine (CyFalse);
        //status = CyU3PSpiTransmitWords (location, 1);
        //status = CyU3PSpiReceiveWords(rdBuf, 1);
        //CyU3PGpioSetValue (FX3_FLASH2_SNN, CyTrue);//CyU3PSpiSetSsnLine (CyTrue);
    	rdsz = alt_avalon_spi_command(SPIBase, SPISlave, 1, location,1, rdBuf, 0);

    	//In case of something goes wrong, break the loop
        if (retries >= STATUS_RETRIES_ERASE)
        {
        	return 1;
        }
        retries++;

    } while(rdBuf[0] & 0x80);	//Reversed, in reality is: } while(rdBuf[0] & 1);

    return 0;
}
