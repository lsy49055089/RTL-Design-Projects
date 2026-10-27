# XY Detection Regression

기본 RTL 파라미터(RED 최소 후보 8개, GREEN 최소 후보 16개)를 유지하고, 320×240 전체 Raster 입력에서 좌표·동기 신호·전달 조건을 확인합니다.

## 결과

Icarus Verilog 12.0 · 2026.10.28 · **13개 Frame 시나리오 / ERROR 0 / 좌표 Packet 수락 7회**

| 조건 | 확인 내용 |
|---|---|
| RED·GREEN 단독 / 동시 검출 | 10-bit 좌표 4개와 40-bit Packet의 정확한 값 |
| 미검출 | 해당 좌표 1023, 두 색 모두 미검출이면 Valid=0 |
| 출력 Timing | Frame Done에서 좌표 확정·동기 Pulse, 다음 Clock의 Valid |
| Ready=0 / 지연 수락 | 프레임 내 좌표·Valid 유지와 수락 후 Valid 해제 |
| 다음 프레임 도착 | 미수락 결과를 새 프레임 결과로 갱신하는 현재 정책 |
| GREEN 후보 15 / 16개 | 최소 후보 수 경계의 미검출 / 검출 |
| RED 후보 7 / 8개 | 최소 후보 수 경계의 미검출 / 검출 |
| 유효 군집 뒤 원거리 잡음 | Bounding Box 주변 범위 밖의 후보 제외 |

같은 Raster 좌표를 2 Clock 동안 유지해 pixel_tick에서만 픽셀을 누적하는 조건도 확인합니다. 인접 픽셀이 필요한 군집화 조건에 맞춰 실제 연속 좌표를 입력합니다.

## 실행

Icarus Verilog와 vvp가 PATH에 있는 환경에서 실행합니다.

```bash
bash verification/run.sh
```

오류가 있으면 Testbench가 $fatal로 실패를 반환합니다. [실행 로그](xy-regression.log)

## RTL 출처와 검증 범위

RTL 사본은 팀 저장소의 [xy_detection.sv](https://github.com/realisshoon/fpga-vga-conductor-game/blob/1a9b05f2e1142ee4140b4132cc1cd278a7374ec7/rtl/filter_detect/xy_detection.sv)와 동일합니다. 이 디렉터리에는 개인 좌표 처리 검증에 사용하는 RTL·Testbench·실행 방법을 정리했습니다.

테스트 결과는 좌표 처리 모듈의 RTL 시뮬레이션 범위입니다. 실제 카메라 영상·UART·게임 로직의 팀 보드 시연은 프로젝트 본문의 별도 자료에서 확인할 수 있습니다.
