#include "drv_custom_uart.h"
#include "../hal/hal_mmio.h"

u32 drv_custom_uart_status(u32 base)
{
    return hal_read32(base, DRV_UART_SR_OFFSET);
}

int drv_custom_uart_send_byte(u32 base, u8 value, u32 timeout)
{
    while (timeout > 0U) {
        if ((drv_custom_uart_status(base) & DRV_UART_TX_READY) != 0U) {
            hal_write32(base, DRV_UART_TDR_OFFSET, value);
            return DRV_UART_OK;
        }

        timeout--;
    }

    return DRV_UART_TIMEOUT;
}

int drv_custom_uart_try_read(u32 base, u8 *value)
{
    if ((drv_custom_uart_status(base) & DRV_UART_RX_VALID) == 0U) {
        return DRV_UART_NO_DATA;
    }

    *value = (u8)(hal_read32(base, DRV_UART_RDR_OFFSET) & 0xFFU);
    return DRV_UART_OK;
}
