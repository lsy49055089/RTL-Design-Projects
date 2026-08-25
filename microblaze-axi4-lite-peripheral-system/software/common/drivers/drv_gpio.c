#include "drv_gpio.h"
#include "../hal/hal_mmio.h"

void drv_gpio_set_direction(u32 base, u8 output_mask)
{
    hal_write32(base, DRV_GPIO_CR_OFFSET, output_mask);
}

u8 drv_gpio_read_input(u32 base)
{
    return (u8)(hal_read32(base, DRV_GPIO_IDR_OFFSET) & 0xFFU);
}

void drv_gpio_write_output(u32 base, u8 value)
{
    hal_write32(base, DRV_GPIO_ODR_OFFSET, value);
}
