#include "drv_spi.h"
#include "../../common/hal/hal_mmio.h"
#include "sleep.h"

int drv_spi_transfer_byte(u32 base, u8 tx_value, u8 clk_div, u32 timeout, u8 *rx_value)
{
    u32 sr;

    hal_write32(base, DRV_SPI_CR_OFFSET, DRV_SPI_CLR_STATUS);
    usleep(1000);

    hal_write32(base, DRV_SPI_TXDATA_OFFSET, tx_value);
    hal_write32(base, DRV_SPI_CR_OFFSET, ((u32)clk_div << 8) | DRV_SPI_START);

    while (timeout > 0U) {
        sr = hal_read32(base, DRV_SPI_SR_OFFSET);

        if ((sr & DRV_SPI_DONE) != 0U) {
            *rx_value = (u8)(hal_read32(base, DRV_SPI_RXDATA_OFFSET) & 0xFFU);
            return DRV_SPI_OK;
        }

        timeout--;
    }

    *rx_value = 0xFFU;
    return DRV_SPI_TIMEOUT;
}
