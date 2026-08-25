# Vitis application sources

`common`은 세 application에서 공유하는 board LED, GPIO, Custom UART,
MMIO 계층이다.
`integrated_app/drivers`에는 해당 앱만 사용하는 I2C LCD와 SPI driver가 있다.

각 앱을 Vitis에서 빌드할 때 다음 source folder들을 application project에
추가한다.

- 공통: `common/board`, `common/drivers`, `common/hal`
- 통합 앱: `integrated_app/app`, `integrated_app/board`,
  `integrated_app/drivers`
- 송신 앱: `uart_sender_app/app`
- 수신 앱: `uart_receiver_app/app`

`xparameters.h`, standalone BSP, linker script, startup code는 hardware
platform에서 자동 생성되므로 이 제출본에는 포함하지 않는다.
