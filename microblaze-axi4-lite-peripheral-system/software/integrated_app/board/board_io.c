#include "board_io.h"
#include "../app/app_config.h"
#include "../../common/drivers/drv_gpio.h"
#include "sleep.h"

static const u8 fnd_hex_table[16] = {
    0xC0U, 0xF9U, 0xA4U, 0xB0U,
    0x99U, 0x92U, 0x82U, 0xF8U,
    0x80U, 0x90U, 0x88U, 0x83U,
    0xC6U, 0xA1U, 0x86U, 0x8EU
};

void board_io_init(void)
{
    drv_gpio_set_direction(APP_GPIO_FND_SEG_BASE, 0xFFU);
    drv_gpio_set_direction(APP_GPIO_FND_COM_BASE, 0x0FU);
    drv_gpio_set_direction(APP_GPIO_LED_BASE, 0xFFU);
    drv_gpio_set_direction(APP_GPIO_SWITCH_BASE, 0x00U);

    board_led_write(0x00U);
    board_fnd_off();
}

u8 board_read_switches(void)
{
    return drv_gpio_read_input(APP_GPIO_SWITCH_BASE);
}

u8 board_read_buttons(void)
{
    u8 raw;

    raw = drv_gpio_read_input(APP_GPIO_FND_COM_BASE);
    return (u8)((raw >> 4) & 0x0FU);
}

void board_led_write(u8 value)
{
    drv_gpio_write_output(APP_GPIO_LED_BASE, value);
}

void board_fnd_display_hex_once(u8 value)
{
    u8 low;
    u8 high;

    low = value & 0x0FU;
    high = (value >> 4) & 0x0FU;

    drv_gpio_write_output(APP_GPIO_FND_SEG_BASE, fnd_hex_table[low]);
    drv_gpio_write_output(APP_GPIO_FND_COM_BASE, 0x0EU);
    usleep(1000);

    drv_gpio_write_output(APP_GPIO_FND_SEG_BASE, fnd_hex_table[high]);
    drv_gpio_write_output(APP_GPIO_FND_COM_BASE, 0x0DU);
    usleep(1000);
}

void board_fnd_off(void)
{
    drv_gpio_write_output(APP_GPIO_FND_SEG_BASE, 0xFFU);
    drv_gpio_write_output(APP_GPIO_FND_COM_BASE, 0x0FU);
}

void board_wait_button_release(void)
{
    while (board_read_buttons() != 0U) {
        usleep(10000);
    }

    usleep(50000);
}
