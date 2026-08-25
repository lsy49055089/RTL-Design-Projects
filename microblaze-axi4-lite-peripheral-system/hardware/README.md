# Hardware sources

- `block_design/design_1.bd`: MicroBlaze, AXI interconnect, BRAM, UARTLite,
  interrupt controller 및 Custom IP 연결 정보
- `ip/*`: 각 Custom IP의 top module과 AXI4-Lite register interface
- `constraints/Basys3_Master.xdc`: MicroBlaze master board pin constraints
- `rtl/slave_uart/uart_rx_led_top.sv`: 상대 Basys3의 순수 RTL UART receiver
- `constraints/Basys3_Slave_UART.xdc`: slave board pin constraints

Vivado project/run 결과는 제출 대상에서 제외했다. Custom IP packaging과
Block Design output products는 이 소스를 이용해 다시 생성할 수 있다.
