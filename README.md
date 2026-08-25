# RTL / FPGA Design Projects

Verilog·SystemVerilog 기반 RTL 설계와 FPGA 시스템 구현 결과를 정리한 포트폴리오 저장소입니다.

**Portfolio focus:** RTL architecture · FPGA system integration · functional verification

> **Related Conference Paper:** [Parallel Decision Tree Hardware](https://github.com/lsy49055089/Parallel-Decision-Tree-Hardware) — 현재 노드와 좌·우 자식 노드를 병렬 계산하고, 논문 명세의 4-state FSM으로 제어한 RTL 설계입니다.

## Projects

### [MicroBlaze AXI4-Lite Peripheral System](./microblaze-axi4-lite-peripheral-system)

MicroBlaze가 5개의 AXI4-Lite Custom IP를 제어하고, 두 대의 Basys3가 UART/SPI로 데이터를 교환하도록 구성한 개인 HW/SW 통합 프로젝트입니다.

- **Stack:** Verilog, SystemVerilog, UVM, Vitis C, Xilinx Vivado, Basys3 FPGA
- **Architecture:** MicroBlaze, AXI Interconnect, GPIO/Timer/UART/SPI/I2C LCD Custom IP, Slave RTL
- **Key Features:** MMIO Driver, 2-Board UART/SPI, I2C LCD, SPI 32/32 PASS, I2C 30/30 PASS
- **My Role:** Custom IP와 Register Map 설계, Vitis C 제어, Slave RTL, UVM 검증, 보드 통합

### [RV32I Single-Cycle CPU](./fpga-rv32i-single-cycle)

SystemVerilog로 32-bit RISC-V Single-Cycle CPU의 Control Unit과 전체 Datapath를 설계한 개인 프로젝트입니다.

- **Stack:** SystemVerilog, RISC-V RV32I, Xilinx Vivado
- **Architecture:** Control Unit, PC, Register File, ALU, Immediate, Instruction/Data Memory
- **Key Features:** 37개 RV32I 명령어, Load/Store, Branch/JAL/JALR
- **My Role:** CPU RTL 전체 설계, instruction decode, memory access, testbench 및 waveform 분석

### [FPGA UART/FIFO Sensor Control System](./fpga-uart-fifo-sensor-system)

Stopwatch·Watch·DHT11·HC-SR04를 UART/FIFO와 하나의 Basys3 시스템으로 통합한 프로젝트입니다.

- **Stack:** Verilog HDL, Xilinx Vivado, Basys3 FPGA, DHT11, HC-SR04
- **Architecture:** FSM/Datapath, UART RX/TX, FIFO, ASCII Decoder/Sender, 공용 FND 출력
- **Key Features:** PC ASCII 제어, 온습도·거리 측정, 시간 기능, timeout·checksum 검증
- **My Role:** DHT11 RTL·검증, 최종 통합 테스트벤치, FND 및 센서 Control 통합 참여

### [FPGA Stopwatch & Watch](./fpga-stopwatch-watch)

Digilent Basys3 보드에서 동작하는 디지털 시계와 스톱워치 통합 시스템입니다.

- **Stack:** Verilog HDL, Xilinx Vivado, Basys3 FPGA
- **Architecture:** Control Unit / Datapath 분리, FSM 기반 모드 제어
- **Key Features:** 100 Hz tick, 시간 계수, 버튼 디바운싱, Moment 캡처, 4자리 7-Segment 표시
- **My Role:** Stopwatch FSM·Datapath 설계, Moment 기능 구현, 테스트벤치 작성 및 시뮬레이션 검증

## Focus Areas

- RISC-V ISA 기반 CPU Control Unit 및 Datapath 설계
- FSM 및 Datapath 기반 RTL 설계
- FPGA 주변장치와 UART/FIFO 시스템 통합
- MicroBlaze와 AXI4-Lite Custom IP 기반 HW/SW 통합
- SystemVerilog/Verilog 테스트벤치와 파형 기반 기능 검증
- 센서 timing, timeout 및 checksum 처리


---

## Portfolio Navigation

[Conference Paper](https://github.com/lsy49055089/Parallel-Decision-Tree-Hardware) · [RTL / FPGA Design](https://github.com/lsy49055089/RTL-Design-Projects) · [Design Verification](https://github.com/lsy49055089/RTL-Verification-Projects) · [Embedded Systems](https://github.com/lsy49055089/Embedded-Systems-Projects) · [Edge AI / CV](https://github.com/lsy49055089/AI-Projects)
