#ifndef DRV_CUSTOM_UART_H
#define DRV_CUSTOM_UART_H

#include "xil_types.h"

#define DRV_UART_SR_OFFSET  0x00U
#define DRV_UART_TDR_OFFSET 0x04U
#define DRV_UART_RDR_OFFSET 0x08U

#define DRV_UART_TX_READY   0x01U
#define DRV_UART_RX_VALID   0x02U

#define DRV_UART_OK          0
#define DRV_UART_TIMEOUT    -1
#define DRV_UART_NO_DATA    -2

u32 drv_custom_uart_status(u32 base);
int drv_custom_uart_send_byte(u32 base, u8 value, u32 timeout);
int drv_custom_uart_try_read(u32 base, u8 *value);

#endif
