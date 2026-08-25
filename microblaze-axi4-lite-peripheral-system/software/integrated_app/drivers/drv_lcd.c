#include "drv_lcd.h"
#include "../../common/hal/hal_mmio.h"
#include "sleep.h"

int drv_lcd_show(u32 base, u8 mode, u8 value, u32 timeout)
{
    u32 lcd_data;
    u32 sr;

    lcd_data = (((u32)(mode & 0x03U)) << 8) | (u32)value;

    hal_write32(base, DRV_LCD_CR_OFFSET, DRV_LCD_CLR_STATUS);
    usleep(1000);

    hal_write32(base, DRV_LCD_DATA_OFFSET, lcd_data);
    hal_write32(base, DRV_LCD_CR_OFFSET, DRV_LCD_START);

    while (timeout > 0U) {
        sr = hal_read32(base, DRV_LCD_SR_OFFSET);

        if ((sr & DRV_LCD_DONE) != 0U) {
            return DRV_LCD_OK;
        }

        if ((sr & DRV_LCD_ACK_ERROR) != 0U) {
            return DRV_LCD_ACK_FAIL;
        }

        timeout--;
    }

    return DRV_LCD_TIMEOUT;
}
