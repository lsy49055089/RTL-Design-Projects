#ifndef DRV_SPI_H
#define DRV_SPI_H

#include "xil_types.h"

#define DRV_SPI_CR_OFFSET     0x00U
#define DRV_SPI_TXDATA_OFFSET 0x04U
#define DRV_SPI_RXDATA_OFFSET 0x08U
#define DRV_SPI_SR_OFFSET     0x0CU

#define DRV_SPI_START         0x01U
#define DRV_SPI_CLR_STATUS    0x02U

#define DRV_SPI_DONE          0x02U

#define DRV_SPI_OK            0
#define DRV_SPI_TIMEOUT      -1

int drv_spi_transfer_byte(u32 base, u8 tx_value, u8 clk_div, u32 timeout, u8 *rx_value);

#endif
