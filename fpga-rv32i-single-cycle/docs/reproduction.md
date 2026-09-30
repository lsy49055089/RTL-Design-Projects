# Bubble Sort Reproduction Record

이 문서는 제출 당시 Vivado 보고서와 구분되는 **후속 재현 환경의 실행 기록**입니다. 기존 CPU RTL, 원본 C와 원본 memory image는 변경하지 않았습니다.

## Environment and Command

- 확인일: 2026-09-30
- Simulator: Icarus Verilog 12.0
- 수정 memory image 생성: RISC-V GCC 13.2.0, `-march=rv32i -mabi=ilp32 -O0`, binutils 2.42
- 실행: 저장소 루트에서 `bash fpga-rv32i-single-cycle/scripts/run_sort_reproduction.sh`
- 실행에 필요한 두 memory image가 저장소에 포함되어 있습니다. 기본 테스트에는 RISC-V compiler가 필요하지 않습니다.

## Observed Output

```text
PASS sort_reproduction: legacy=1 cycles=707 values=6
PASS sort_reproduction: legacy=0 cycles=532 values=5
```

| Mode | 입력과 프로그램 | TB가 확인한 결과 |
|---|---|---|
| `legacy=1` | 원본 104-word image, 원본 배열의 여섯 번째 초기값 `0` 포함 | RAM word 53..58: `0,1,3,5,7,9`; word 59: `0x12345678` |
| `legacy=0` | 후속 126-word image, 5개 값과 수정된 loop bound | RAM word 4..8: `1,3,5,7,9` |

위 cycle은 reset 해제 이후 완료 위치에 도달할 때까지의 TB 계수입니다. 두 프로그램은 데이터 개수, startup과 결과 출력 코드가 다르므로 **성능 비교 수치로 사용하지 않습니다**.

## Failure Detection Checked

테스트벤치가 단순 실행 완료만 확인하지 않는지, 임시로 만든 잘못된 image로 확인했습니다. 변조한 image는 저장소에 포함하지 않습니다.

- 수정 프로그램의 초기값 `3`을 `4`로 바꾸면 결과 배열 불일치로 실패합니다.
- 첫 명령어를 자기 자신으로 jump하도록 바꾸면 5,000-cycle 제한에서 timeout으로 실패합니다.
- 두 경우 모두 simulator가 비정상 종료하여 shell/CI에 실패를 전달합니다.

## Rebuild the Fixed Image

```bash
bash fpga-rv32i-single-cycle/scripts/build_sort_program.sh
```

기본 compiler prefix는 `riscv64-unknown-elf-`이며 `RISCV_PREFIX`로 다른 경로를 지정할 수 있습니다. compiler 버전이 바뀌면 명령어 배치와 cycle 수가 달라질 수 있으므로, 재생성 후 결과 비교 테스트를 다시 실행해야 합니다.

수정 C는 `j < count - i - 1`을 사용하고 입력 배열 길이를 5로 맞췄습니다. 작은 Harvard memory 구성에 맞춰 상수 데이터를 startup에서 복사하는 대신 C 코드의 명시적 대입으로 배열을 초기화합니다. `start.S`가 Stack Pointer를 256으로 설정하고 main에서 복귀하면 PC 8의 완료 loop에 머뭅니다.

## Verification Scope

- simulation 전용 ROM과 초기화 코드를 새 TB에만 추가했습니다. CPU·Datapath·Control Unit·Data RAM의 원본 RTL은 유지했습니다.
- 프로그램 결과, 완료 위치, timeout, PC와 word 단위 load/store 주소 범위를 확인합니다.
- 37개 명령어의 모든 corner case, 공식 ISA compliance, FPGA 보드 동작 또는 timing closure를 확인한 테스트는 아닙니다.
