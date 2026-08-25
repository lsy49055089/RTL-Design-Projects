#ifndef DRV_GPIO_H
#define DRV_GPIO_H

#include "xil_types.h"

#define DRV_GPIO_CR_OFFSET  0x00U
#define DRV_GPIO_IDR_OFFSET 0x04U
#define DRV_GPIO_ODR_OFFSET 0x08U

void drv_gpio_set_direction(u32 base, u8 output_mask);
u8 drv_gpio_read_input(u32 base);
void drv_gpio_write_output(u32 base, u8 value);

#endif
