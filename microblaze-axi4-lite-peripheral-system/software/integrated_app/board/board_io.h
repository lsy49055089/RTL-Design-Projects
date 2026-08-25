#ifndef BOARD_IO_H
#define BOARD_IO_H

#include "xil_types.h"

#define BOARD_BTN_U      0x01U
#define BOARD_BTN_D      0x02U
#define BOARD_BTN_L      0x04U
#define BOARD_BTN_R      0x08U

#define BOARD_BTN_TIMER  BOARD_BTN_U
#define BOARD_BTN_CLEAR  BOARD_BTN_D
#define BOARD_BTN_SPI    BOARD_BTN_L
#define BOARD_BTN_UART   BOARD_BTN_R

void board_io_init(void);
u8 board_read_switches(void);
u8 board_read_buttons(void);
void board_led_write(u8 value);
void board_fnd_display_hex_once(u8 value);
void board_fnd_off(void);
void board_wait_button_release(void);

#endif
