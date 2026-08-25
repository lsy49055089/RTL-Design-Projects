#include "board_leds.h"
#include "../drivers/drv_gpio.h"
#include "xparameters.h"

#define BOARD_LED_LOW_BASE  XPAR_GPIO_2_S00_AXI_BASEADDR
#define BOARD_LED_HIGH_BASE XPAR_GPIO_3_S00_AXI_BASEADDR

void board_leds_init(void)
{
    drv_gpio_set_direction(BOARD_LED_LOW_BASE, 0xFFU);
    drv_gpio_set_direction(BOARD_LED_HIGH_BASE, 0xFFU);
}

void board_leds_write(u16 value)
{
    drv_gpio_write_output(BOARD_LED_LOW_BASE, (u8)(value & 0x00FFU));
    drv_gpio_write_output(BOARD_LED_HIGH_BASE,
                          (u8)((value >> 8) & 0x00FFU));
}
