# RTL / FPGA Design

RTL의 제어·데이터 경로를 설계하고, FPGA 주변장치와 소프트웨어를 연결한 프로젝트입니다.


<a id="rtl--fpga-design-projects"></a>
<a id="projects"></a>
<a id="cnn-모션인식-soc-플랫폼zynq-cnn-motion-robot-soc"></a>
<a id="fpga-vga-conductor-gamefpga-vga-conductor-game"></a>
<a id="microblaze-axi4-lite-peripheral-systemmicroblaze-axi4-lite-peripheral-system"></a>
<a id="rv32i-single-cycle-cpufpga-rv32i-single-cycle"></a>
<a id="fpga-uartfifo-sensor-control-systemfpga-uart-fifo-sensor-system"></a>
<a id="fpga-stopwatch--watchfpga-stopwatch-watch"></a>
<a id="focus-areas"></a>
<a id="portfolio-navigation"></a>

## 프로젝트

| 프로젝트 | 담당 역할 | 주요 구현·결과 |
|---|---|---|
| [CNN 모션인식 SoC 플랫폼](./zynq-cnn-motion-robot-soc) | PWM IP·C 출력 제어·기록/재생·그리퍼 안정화·Unity | 5축·20 ms 제어, 실물·가상환경 시연 · 최우수상 |
| [MicroBlaze AXI4-Lite Peripheral System](./microblaze-axi4-lite-peripheral-system) | Custom IP·Register Map·C MMIO·Slave RTL·UVM·보드 통합 | IP 5종, SPI 32/32·I2C 30/30 PASS, 두 보드 통신 |
| [FPGA VGA Conductor Game](./fpga-vga-conductor-game) | 좌표·곡 디코더 RTL/TB·프레임 동기화·PC UI 연동 | RED/GREEN 좌표 추출, Frame Delay 수정, 좌표 RTL 13프레임·오류 0건 |
| [RV32I Single-Cycle CPU](./fpga-rv32i-single-cycle) | Control Unit·Datapath·Memory·테스트벤치 | 37개 명령어 구현, Bubble Sort 프로그램 결과 자동 비교 |
| [FPGA UART/FIFO Sensor Control System](./fpga-uart-fifo-sensor-system) | DHT11 RTL·Checksum·통합 TB·FND 연동 참여 | 40-bit 센서 수신, 시계·센서·UART 통합 동작 확인 |
| [FPGA Stopwatch & Watch](./fpga-stopwatch-watch) | Stopwatch FSM·Datapath·Moment·테스트벤치 | 100 Hz 시간 계수, 순간값 저장·표시, Basys3 동작 확인 |

[병렬 결정트리 연구](https://github.com/lsy49055089/Parallel-Decision-Tree-Hardware)는 별도 저장소에서 확인할 수 있습니다.

## 검증·실행

<a id="continuous-integration"></a>

### 자동 검사와 실행

GitHub Actions에서 Icarus Verilog로 RV32I와 Stopwatch RTL의 SystemVerilog/Verilog elaboration을 자동 검사합니다.

```bash
bash scripts/check_rtl.sh
bash fpga-rv32i-single-cycle/scripts/run_sort_reproduction.sh
```

RV32I는 추가로 원본 Bubble Sort 이미지와 정렬 조건을 수정한 프로그램을 실행해 결과 배열을 자동 비교합니다. 이 테스트는 프로그램 단위 결과 확인이며, 37개 명령어의 모든 동작 조건이나 타이밍 검증을 의미하지 않습니다.

> CI는 RV32I·Stopwatch의 elaboration과 RV32I 정렬 프로그램 결과를 검사합니다. 다른 프로젝트의 Vivado Block Design·UART/FIFO 의존 소스는 각 README의 실행 조건을 따릅니다.


[CI 실행 기록](https://github.com/lsy49055089/RTL-Design-Projects/actions/workflows/rtl-ci.yml)

---

[웹 포트폴리오](https://seungyeol-rtl-portfolio.azuretide33.chatgpt.site) · [GitHub 프로필](https://github.com/lsy49055089)

[논문](https://github.com/lsy49055089/Parallel-Decision-Tree-Hardware) · [RTL / FPGA Design](https://github.com/lsy49055089/RTL-Design-Projects) · [Design Verification](https://github.com/lsy49055089/RTL-Verification-Projects) · [Embedded Systems](https://github.com/lsy49055089/Embedded-Systems-Projects) · [AI / CV](https://github.com/lsy49055089/AI-Projects)
