#include "app_config.h"
#include "../../common/board/board_leds.h"
#include "../../common/drivers/drv_custom_uart.h"
#include "sleep.h"
#include "xil_types.h"

int main(void)
{
    u8 tx_value = APP_FIRST_TX_VALUE;

    board_leds_init();

    for (;;) {
        (void)drv_custom_uart_send_byte(APP_CUSTOM_UART_BASE, tx_value,
                                        APP_UART_TIMEOUT);
        board_leds_write(tx_value);

        tx_value++;
        usleep(APP_TX_INTERVAL_US);
    }
}
