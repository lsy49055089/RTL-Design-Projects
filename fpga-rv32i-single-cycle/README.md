# RV32I Single-Cycle CPU

32-bit RV32I CPU의 Control Unit과 Datapath를 SystemVerilog로 설계하고, Bubble Sort 프로그램의 정렬 결과를 자동 비교했습니다.

## 개요

| 항목 | 내용 |
|---|---|
| 기간 | 2026.05.19–2026.05.27 |
| 형태 | 개인 프로젝트 |
| 기술 | SystemVerilog · RISC-V RV32I · Vivado · Icarus Verilog |


## 담당 역할

<a id="my-work"></a>

개인 프로젝트로 다음 항목을 직접 설계하고 분석했습니다.

- CPU top, Control Unit 및 전체 Datapath 통합
- ALU와 signed/unsigned Branch 비교 로직
- Register File, Immediate Extend, Program Counter 및 Write-Back MUX
- Byte/Halfword/Word Data Memory 접근과 sign/zero extension
- R/I/S/B/U/J-Type instruction decode 및 control signal 생성
- Testbench 작성, waveform 분석 및 Bubble Sort 프로그램 흐름 검증


## 설계·구현

<a id="architecture"></a>

### 시스템 구조

![RV32I single-cycle architecture](./assets/architecture.png)

최상위 SoC는 CPU Core, Instruction Memory, Data Memory로 구성됩니다. CPU 내부는 Control Unit과 Datapath로 분리했으며 Datapath에 Program Counter, Register File, ALU, Immediate Extend, Write-Back MUX를 배치했습니다.

<a id="implemented-features"></a>

### 주요 기능

- 32-bit instruction, register, ALU 및 memory datapath
- `opcode`, `funct3`, `funct7` 기반 combinational instruction decoder
- x0 hard-wired zero 처리와 2-read/1-write Register File
- I/S/B/U/J-Type별 Immediate 생성 및 sign extension
- `PC+4`, Branch, JAL, JALR 기반 next-PC 선택
- Byte/Halfword/Word Load·Store와 sign/zero extension
- Bubble Sort C 코드와 104-word instruction memory image
- Vivado waveform 기반 instruction 및 프로그램 흐름 분석

<a id="instruction-support"></a>

### 명령어 지원

제출 RTL을 기준으로 RV32I 기본 명령어 40개 중 아래 **37개**를 구현했습니다.

| Group | Instructions |
|---|---|
| Register ALU | `ADD SUB SLL SLT SLTU XOR SRL SRA OR AND` |
| Immediate ALU | `ADDI SLTI SLTIU XORI ORI ANDI SLLI SRLI SRAI` |
| Load | `LB LH LW LBU LHU` |
| Store | `SB SH SW` |
| Branch | `BEQ BNE BLT BGE BLTU BGEU` |
| Upper Immediate | `LUI AUIPC` |
| Jump | `JAL JALR` |

`FENCE`, `ECALL`, `EBREAK`은 포함하지 않습니다.


## 검증 결과

<a id="verification-summary"></a>

### 검증 항목

- R/I/S/Load/B/U/J/JALR Type별 decode, ALU, Write Back 흐름 확인
- `LB/LH` sign extension 및 `LBU/LHU` zero extension 확인
- Branch의 `b_taken`, target address, `PC+4` 선택 흐름 확인
- JAL/JALR 함수 호출·복귀와 Return Address 저장 흐름 분석
- Bubble Sort 파형에서 Stack Frame, 배열 Load/Store, Branch, swap 호출을 추적
- 보고서 기준 Single-Cycle critical path에서 negative slack을 확인하고 Multi-Cycle/Pipeline 구조를 개선 방향으로 도출

### 프로그램 실행 검증

Icarus Verilog가 설치된 환경에서 저장소 루트 기준으로 실행합니다. 실행에 필요한 memory image를 포함했으므로 RISC-V compiler는 기본 테스트에 필요하지 않습니다.

```bash
bash fpga-rv32i-single-cycle/scripts/run_sort_reproduction.sh
```

| Test | Expected Result | 자동 확인 범위 |
|---|---|---|
| 제출 당시 memory image | `0, 1, 3, 5, 7, 9` | 결과 6개, 완료 marker, 프로그램 종료 위치 |
| 정렬 조건을 수정한 프로그램 | `1, 3, 5, 7, 9` | 결과 5개, main 복귀 후 종료 위치 |

테스트는 시간 제한과 PC·word 접근 주소 범위를 확인하고, 결과 불일치 시 `$fatal`로 실패합니다. GitHub Actions에서 같은 테스트를 실행합니다. 실행 기록과 원본·수정 프로그램의 차이는 [프로그램 실행 조건](./docs/reproduction.md)에 정리했습니다.

수정 프로그램은 배열 길이를 5로 맞추고 `j < count - i - 1` 조건을 사용합니다. 원본 `bubble_sort.c`와 memory image는 제출 기록으로 보존했습니다. 수정 이미지 재생성에는 RISC-V GCC/binutils와 Python 3가 필요합니다.

```bash
bash fpga-rv32i-single-cycle/scripts/build_sort_program.sh
```


## 실행 방법

### 실행 조건

- 원본 `rtl/instruction_mem.sv`는 LUI/AUIPC smoke-test ROM입니다. 자동 비교 TB는 별도의 simulation ROM에 memory image를 로드하며, CPU와 Data RAM은 원본 RTL을 사용합니다.
- 원본 Register File의 초기값은 x1=1, x2=2입니다. 자동 비교 TB는 초기 Register File과 Data RAM을 명시적으로 초기화하며, 프로그램 첫 명령어가 Stack Pointer를 256으로 설정합니다.
- 원본 `bubble_sort.c`는 `int Num[6] = {3,5,9,1,7}`과 `j < size - i` 조건 때문에 여섯 번째 초기값 `0`까지 비교합니다. 새 TB에서도 원본 이미지의 `0,1,3,5,7,9` 결과를 확인했습니다.
- 원본 `tb_rv32i.sv`는 파형 관찰용이며 자동 판정이 없습니다. `tb_sort_reproduction.sv`는 Icarus Verilog에서 정렬 결과를 자동 비교합니다.
- Bubble Sort 테스트는 프로그램 단위 결과 확인입니다. 37개 명령어의 모든 corner case, ISA 적합성 또는 timing closure를 검증한 결과는 아닙니다.
- FPGA 보드 구현, XDC, Pipeline, Cache, Interrupt, CSR 및 privileged architecture는 범위에 포함하지 않았습니다.

<a id="source-structure"></a>

### 소스 구성

| Path | Description |
|---|---|
| `rtl/top_rv32i_soc.sv` | CPU, Instruction ROM, Data RAM 통합 |
| `rtl/rv32i_cpu.sv` | Control Unit과 Datapath 연결 |
| `rtl/control_unit.sv` | Instruction decode 및 control signal 생성 |
| `rtl/rv32i_datapath.sv` | PC, Register File, ALU, Immediate, MUX |
| `rtl/instruction_mem.sv` | 기본 instruction smoke-test ROM |
| `rtl/data_mem.sv` | Load/Store 및 sign/zero extension |
| `rtl/define.vh` | Opcode, ALU, memory mode 정의 |
| `tb/tb_rv32i.sv` | Clock/reset 기반 top-level simulation |
| `program/bubble_sort.c` | 제출된 Bubble Sort C source |
| `program/instruction_mem_sort.mem` | 제출된 104-word RISC-V memory image |
| `program/reproduction/` | 정렬 조건을 수정한 C, startup, linker script, 생성된 memory image |
| `tb/tb_sort_reproduction.sv` | 원본·수정 프로그램의 정렬 결과 자동 비교 |
| `scripts/run_sort_reproduction.sh` | Icarus Verilog 기반 두 프로그램 실행 |

원본의 `type.vh`는 `define.vh`와 동일한 중복 파일이어서 공개 구조에서는 제외했습니다.

<a id="project-layout"></a>

### 디렉터리

```text
fpga-rv32i-single-cycle/
├── assets/
│   └── architecture.png
├── rtl/
│   ├── control_unit.sv
│   ├── data_mem.sv
│   ├── define.vh
│   ├── instruction_mem.sv
│   ├── rv32i_cpu.sv
│   ├── rv32i_datapath.sv
│   └── top_rv32i_soc.sv
├── tb/
│   ├── tb_rv32i.sv
│   └── tb_sort_reproduction.sv
├── program/
│   ├── bubble_sort.c
│   ├── instruction_mem_sort.mem
│   └── reproduction/
├── scripts/
├── docs/
├── .gitignore
└── README.md
```


---

[웹 포트폴리오](https://seungyeol-rtl-portfolio.azuretide33.chatgpt.site) · [GitHub 프로필](https://github.com/lsy49055089)

[논문](https://github.com/lsy49055089/Parallel-Decision-Tree-Hardware) · [RTL / FPGA Design](https://github.com/lsy49055089/RTL-Design-Projects) · [Design Verification](https://github.com/lsy49055089/RTL-Verification-Projects) · [Embedded Systems](https://github.com/lsy49055089/Embedded-Systems-Projects) · [AI / CV](https://github.com/lsy49055089/AI-Projects)
