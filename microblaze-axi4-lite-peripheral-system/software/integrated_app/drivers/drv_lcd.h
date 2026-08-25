#ifndef DRV_LCD_H
#define DRV_LCD_H

#include "xil_types.h"

#define DRV_LCD_CR_OFFSET   0x00U
#define DRV_LCD_DATA_OFFSET 0x04U
#define DRV_LCD_SR_OFFSET   0x08U

#define DRV_LCD_START       0x01U
#define DRV_LCD_CLR_STATUS  0x02U

#define DRV_LCD_DONE        0x02U
#define DRV_LCD_ACK_ERROR   0x04U

#define DRV_LCD_MODE_SWITCH 0x00U
#define DRV_LCD_MODE_UART   0x01U
#define DRV_LCD_MODE_SPI    0x02U
#define DRV_LCD_MODE_TIMER  0x03U

#define DRV_LCD_OK          0
#define DRV_LCD_ACK_FAIL   -1
#define DRV_LCD_TIMEOUT    -2

int drv_lcd_show(u32 base, u8 mode, u8 value, u32 timeout);

#endif
