#include "app_config.h"
#include "../../common/board/board_leds.h"
#include "../../common/drivers/drv_custom_uart.h"
#include "sleep.h"
#include "xil_types.h"

int main(void)
{
    u16 wait_pattern = APP_WAIT_PATTERN_INITIAL;

    board_leds_init();
    board_leds_write(APP_STARTUP_PATTERN);
    usleep(APP_STARTUP_DELAY_US);

    for (;;) {
        u8 rx_value;

        if (drv_custom_uart_try_read(APP_CUSTOM_UART_BASE, &rx_value) ==
            DRV_UART_OK) {
            board_leds_write(rx_value);
        } else {
            board_leds_write(wait_pattern);
            wait_pattern ^= APP_WAIT_PATTERN_TOGGLE;
            usleep(APP_WAIT_INTERVAL_US);
        }
    }
}
