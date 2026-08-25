#include "app_config.h"
#include "../board/board_io.h"
#include "../drivers/drv_lcd.h"
#include "../drivers/drv_spi.h"
#include "../../common/drivers/drv_custom_uart.h"
#include "xil_printf.h"
#include "xil_types.h"

static u8 button_rising_edge(u8 current, u8 previous, u8 mask)
{
    return (u8)(((current & mask) != 0U) && ((previous & mask) == 0U));
}

static void show_ready_screen(void)
{
    int lcd_result;

    lcd_result = drv_lcd_show(APP_I2C_LCD_BASE, DRV_LCD_MODE_SWITCH,
                              0x00U, APP_LCD_TIMEOUT);
    xil_printf("[READY] LCD result=%d\r\n", lcd_result);
}

static void handle_uart_event(u8 value)
{
    int uart_result;
    int lcd_result;

    board_led_write(value);

    uart_result = drv_custom_uart_send_byte(APP_CUSTOM_UART_BASE, value,
                                            APP_UART_TIMEOUT);
    if (uart_result != DRV_UART_OK) {
        xil_printf("[CUSTOM UART] TX timeout SR=0x%08lx\r\n",
                   (unsigned long)drv_custom_uart_status(APP_CUSTOM_UART_BASE));
    }

    lcd_result = drv_lcd_show(APP_I2C_LCD_BASE, DRV_LCD_MODE_UART,
                              value, APP_LCD_TIMEOUT);
    xil_printf("[UART] DATA=0x%02x UART result=%d LCD result=%d\r\n",
               value, uart_result, lcd_result);
}

static void handle_spi_event(u8 value)
{
#if APP_HAS_SPI
    u8 received_value;
    int spi_result;
    int lcd_result;

    board_led_write(value);

    spi_result = drv_spi_transfer_byte(APP_SPI_BASE, value,
                                       APP_SPI_CLOCK_DIVIDER,
                                       APP_SPI_TIMEOUT, &received_value);
    lcd_result = drv_lcd_show(APP_I2C_LCD_BASE, DRV_LCD_MODE_SPI,
                              value, APP_LCD_TIMEOUT);

    xil_printf("[SPI] TX=0x%02x RX=0x%02x SPI result=%d LCD result=%d\r\n",
               value, received_value, spi_result, lcd_result);
#else
    (void)value;
    xil_printf("[SPI] SPI_0 is not present in this platform\r\n");
#endif
}

static void handle_timer_event(u8 value)
{
    int lcd_result;

    board_led_write(value);
    lcd_result = drv_lcd_show(APP_I2C_LCD_BASE, DRV_LCD_MODE_TIMER,
                              value, APP_LCD_TIMEOUT);

    xil_printf("[TIMER] CNT=0x%02x LCD result=%d\r\n",
               value, lcd_result);
}

static void handle_clear_event(void)
{
    int lcd_result;

    board_led_write(0x00U);
    board_fnd_off();

    lcd_result = drv_lcd_show(APP_I2C_LCD_BASE, DRV_LCD_MODE_SWITCH,
                              0x00U, APP_LCD_TIMEOUT);
    xil_printf("[CLEAR] LCD result=%d\r\n", lcd_result);
}

int main(void)
{
    u8 previous_buttons = 0x00U;
    u8 display_value = 0x00U;
    u8 timer_value = 0x00U;

    xil_printf("\r\n============================\r\n");
    xil_printf("MASTER BUTTON MODE TEST\r\n");
    xil_printf("============================\r\n");

    board_io_init();
    show_ready_screen();

    for (;;) {
        u8 switches = board_read_switches();
        u8 buttons = board_read_buttons();

        if (button_rising_edge(buttons, previous_buttons, BOARD_BTN_UART)) {
            display_value = switches;
            handle_uart_event(display_value);
            board_wait_button_release();
        }

        if (button_rising_edge(buttons, previous_buttons, BOARD_BTN_SPI)) {
            display_value = switches;
            handle_spi_event(display_value);
            board_wait_button_release();
        }

        if (button_rising_edge(buttons, previous_buttons, BOARD_BTN_TIMER)) {
            timer_value++;
            display_value = timer_value;
            handle_timer_event(display_value);
            board_wait_button_release();
        }

        if (button_rising_edge(buttons, previous_buttons, BOARD_BTN_CLEAR)) {
            display_value = 0x00U;
            timer_value = 0x00U;
            handle_clear_event();
            board_wait_button_release();
        }

        board_fnd_display_hex_once(display_value);
        previous_buttons = buttons;
    }
}
