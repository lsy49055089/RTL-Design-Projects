#ifndef APP_CONFIG_H
#define APP_CONFIG_H

#include "xparameters.h"

/* Basys3 GPIO roles */
#define APP_GPIO_FND_SEG_BASE  XPAR_GPIO_0_S00_AXI_BASEADDR
#define APP_GPIO_FND_COM_BASE  XPAR_GPIO_1_S00_AXI_BASEADDR
#define APP_GPIO_LED_BASE      XPAR_GPIO_2_S00_AXI_BASEADDR
#define APP_GPIO_SWITCH_BASE   XPAR_GPIO_3_S00_AXI_BASEADDR

/* Custom AXI4-Lite peripherals */
#define APP_CUSTOM_UART_BASE   XPAR_UART_0_S00_AXI_BASEADDR
#define APP_I2C_LCD_BASE       XPAR_I2C_LCD_AXI_0_S00_AXI_BASEADDR

#ifdef XPAR_SPI_0_S00_AXI_BASEADDR
#define APP_HAS_SPI            1
#define APP_SPI_BASE           XPAR_SPI_0_S00_AXI_BASEADDR
#else
#define APP_HAS_SPI            0
#endif

/* Polling limits are loop counts, not elapsed microseconds. */
#define APP_UART_TIMEOUT       1000000U
#define APP_LCD_TIMEOUT        20000000U
#define APP_SPI_TIMEOUT        1000000U
#define APP_SPI_CLOCK_DIVIDER  100U

#endif
