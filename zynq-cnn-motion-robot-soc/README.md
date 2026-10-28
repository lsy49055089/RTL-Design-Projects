# CNN 모션인식 SoC 플랫폼

CNN·스테레오 3D 입력으로 5축 로봇팔을 제어하는 시스템에서 PWM IP, C 출력 제어, 동작 기록·재생과 통합 디버깅을 담당했습니다.

## 개요

| 항목 | 내용 |
|---|---|
| 기간 | 2026.09.09–2026.10.15 |
| 교육 과정 | 대한상공회의소 서울기술교육센터 · 온디바이스 AI 시스템반도체 설계 2기 |
| 팀 | 움 이 움(움이움) · 7명 |
| 수상 | 최종 프로젝트 경진대회 **최우수상** · 2026.10.15 · 5개 팀 중 2위 · 전체 참가 34명 |
| 기술 | Zybo Z7-20, Zynq-7000, Verilog, AXI4-Lite, C, Vivado/Vitis, DDR, SD/FatFS, UART, Unity/C# |
| 전체 소스 | [팀 공동 저장소](https://github.com/realisshoon/zynq-cnn-motion-robot-soc) · [로봇팔 펌웨어](https://github.com/realisshoon/zynq-cnn-motion-robot-soc/tree/main/robot_arm) · [Unity](https://github.com/realisshoon/zynq-cnn-motion-robot-soc/tree/main/Unity) |

## 담당 역할

<a id="담당-범위"></a>

| 구분 | 수행 내용 |
|---|---|
| **개인 구현 · PWM 출력** | 카운터·비교기 기반 PWM Core, AXI4-Lite Custom IP, C MMIO 드라이버와 5축 서보 출력 |
| **개인 구현 · Record/Replay** | 20 ms 기록·재생, 출력 적용 성공 명령 기록, 첫 자세 정렬, DDR 버퍼와 SD 저장·불러오기 |
| **개인 구현 · 통합 디버깅** | 그리퍼 유효 영상 선택·히스테리시스·3회 관측 확인·1.5초 닫힘 유지, 150 mm 도약 검사·재획득·목표 갱신·출력 제한 |
| **개인 구현 · Unity** | 실물과 같은 5축 의미, 링크·브래킷·그리퍼 배치, 축별·좌우 독립 동작 점검 |
| **로봇팔팀 공동 작업** | CNN 통합 후 칼만 필터 적용, 좌우 카메라의 색상 검출 조건 튜닝, 입력 좌표와 로봇 출력 비교 |

CNN 가속기와 UVM 검증은 CNN팀이, 스테레오 3D 복원·관절각 산출은 로봇팔팀의 다른 팀원이 담당했습니다. 전체 시스템 통합과 최종 시연은 팀 공동 성과입니다.


## 설계·구현

### 시스템 구조

![카메라·CNN·로봇팔·PC 가상환경을 연결한 팀 시스템 구성도](https://raw.githubusercontent.com/realisshoon/zynq-cnn-motion-robot-soc/fc647991090b3955780308f7e371f94595f9bf7e/docs/media/system-architecture-slide12.png)

카메라 영상과 CNN 연산 데이터는 DMA·DDR 경로로 전달됩니다. PS의 C 코드는 관측 데이터·목표 관절각·출력 모드와 파일을 관리하고, PL의 PWM IP는 AXI4-Lite 레지스터 설정을 받아 서보 파형을 생성합니다.

담당 출력 경로는 **보정된 관절 명령 → 20 ms 출력 제어 → PWM 변환·HAL → AXI4-Lite PWM IP**와, 이 출력 경로에 연결한 **기록·재생**입니다.

<a id="1-pwm-ip와-pspl-출력-제어"></a>

### PWM IP와 PS–PL 출력 제어

초기에는 고정 명령을 PS에서 전달해 AXI 레지스터 쓰기와 PWM 출력을 먼저 확인했습니다. 이후 설정·모드·기록 처리를 C로 옮기고, 반복 파형 생성은 PL에 남겼습니다.

- **PWM Core:** 100 MHz 기준 20 ms 주기(2,000,000클럭), 채널별 비교기로 펄스 폭 생성. 1,500 µs는 150,000클럭에 대응합니다.
- **동시 적용:** 채널 값을 Shadow 레지스터에 기록한 뒤 마지막에 UPDATE를 요청합니다.
- **계층 분리:** ServoConfig → ServoControl → ServoHAL → PWM Driver로 설정·변환·검사·MMIO 접근을 나눴습니다.
- **적용 조건:** 전 채널 범위를 먼저 검사하고, 중간 쓰기가 실패하면 UPDATE를 수행하지 않도록 구성했습니다.

<details>
<summary>최종 5축 채널과 레지스터 맵</summary>

기존 6채널 하드웨어 주소를 유지하면서 소프트웨어는 CH0–CH4를 사용했습니다.

| 채널 | 주소 | 최종 축 |
|---|---|---|
| CH0 | 0x00 | M0 · Elbow Roll |
| CH1 | 0x04 | M1 · Elbow Pitch |
| CH2 | 0x08 | M2 · Wrist Pitch |
| CH3 | 0x0C | M3 · Wrist Roll |
| CH4 | 0x10 | M4 · Gripper |
| CH5 | 0x14 | 미사용 |
| CONTROL | 0x18 | 출력 허용·해제 |
| UPDATE | 0x1C | Shadow 값 적용 요청 |

초기 6축 자료의 Gripper 주소 0x14를 최종 5축 코드에 섞지 않도록 매핑을 정리했습니다.

[HAL 구현](https://github.com/realisshoon/zynq-cnn-motion-robot-soc/blob/fc647991090b3955780308f7e371f94595f9bf7e/robot_arm/src/drivers/pwm/servo_hal.c) · [PWM 드라이버](https://github.com/realisshoon/zynq-cnn-motion-robot-soc/blob/fc647991090b3955780308f7e371f94595f9bf7e/robot_arm/src/drivers/pwm/servo_pwm_driver.c)

</details>

<a id="2-c-기반-동작-기록재생"></a>

### C 기반 동작 기록·재생

CNN 관측 갱신과 **20 ms 제어 주기**를 분리했습니다. 새 관측은 목표를 갱신하고, 제어 틱마다 속도·가속도를 제한한 명령을 출력합니다. 기록도 새 CNN 입력 시점이 아니라 **HAL 출력 적용에 성공한 제어 틱**에 수행합니다.

| 설계 판단 | 구현 |
|---|---|
| 무엇을 기록할 것인가 | 로봇별 보정과 궤적·출력 제한을 거친 관절 명령 저장. 회전축 4개 + 그리퍼 값 1개, float 5개·20바이트 |
| 어디에 기록할 것인가 | 실행 중에는 DDR 정적 배열에 저장하고, 녹화 종료 후 SD 파일로 보관 |
| 어떻게 재생할 것인가 | 전체 샘플 검사 → 첫 자세 ALIGN → 20 ms마다 PLAY. 상위의 사람 각도 보정을 중복 적용하지 않음 |
| 제어 틱이 누락되면 | 기록을 중단해 고정 주기 샘플의 시간축 압축 방지. 재생 오류는 마지막 적용 명령 유지 |
| 저장에 실패하면 | 임시 파일 검사 후 게시. 실패 시 RAM 기록과 기존 파일 보존 |

<details>
<summary>녹화 경계·버퍼·파일 검사</summary>

- **시작:** 마지막 승인 목표 정착 → 새 HAL 명령 안정 3틱 확인 → 정지 샘플 2개 → 녹화.
- **종료:** 종료 정착 구간을 추가 기록하고 샘플 검사 후 이름 입력·저장.
- **버퍼:** 최대 2,048샘플 중 300샘플을 종료 구간에 예약. 일반 기록 상한 1,748샘플·34.96초, 종료 구간 포함 파일 상한 40.96초.
- **파일:** MRP1 식별자·버전·20 ms 주기·샘플 수·데이터 ABI·CRC 검사.
- **재생:** 유한값·관절 범위·샘플 변화량·속도·가속도 등을 사전 검사하고, 반복 재생에서도 첫 샘플까지 ALIGN.

정착 판정은 출력 명령 기준입니다. 실제 서보의 정지나 접촉력을 센서로 측정하는 구조는 아닙니다.

[기록·재생 구현](https://github.com/realisshoon/zynq-cnn-motion-robot-soc/blob/fc647991090b3955780308f7e371f94595f9bf7e/robot_arm/src/app/robot/record_replay/motion_record_replay.c) · [파일 처리](https://github.com/realisshoon/zynq-cnn-motion-robot-soc/blob/fc647991090b3955780308f7e371f94595f9bf7e/robot_arm/src/app/robot/record_replay/motion_library.c) · [SD 입출력](https://github.com/realisshoon/zynq-cnn-motion-robot-soc/blob/fc647991090b3955780308f7e371f94595f9bf7e/robot_arm/src/app/robot/record_replay/motion_sd.c)

</details>

<a id="3-cnn-통합-후-디버깅"></a>

### CNN 통합 후 디버깅

| 문제 | 담당·수정 | 동작 변화 |
|---|---|---|
| 좌우 카메라의 검출 상태가 달라 한쪽 마커 누락이 그리퍼 판정에 영향 | **개인:** 손목과 두 색상 마커가 유효한 한쪽 영상으로 판정. 기존 영상이 불완전하면 반대쪽 유효 영상 선택 | 양쪽 영상이 모두 유효해야 하는 의존성 완화 |
| 그리퍼가 닫힌 직후 잡음으로 다시 열림 | **개인:** 진입·취소 임계값을 나누는 히스테리시스, 새 유효 관측 3회 확인, 닫힘 명령 적용 후 최소 1.5초 유지 | 순간적인 입력 변화가 즉시 개폐 명령으로 이어지는 현상 억제 |
| 큰 좌표 변화와 새 목표가 급격한 팔 동작으로 연결 | **개인:** 150 mm 도약 검사·후보 재확인, 새 유효 목표 갱신, 20 ms 궤적·속도·가속도 제한 | 입력 이상치 보류와 점진적 출력 변경을 분리 |
| CNN·3D 복원 좌표의 흔들림 | **공동:** One Euro 필터 검토 후 칼만 필터 적용·계수 조정, 카메라별 색상 조건 튜닝 | 관측과 추종 동작 안정화 |

3회 확인에는 중복 프레임을 포함하지 않으며, 영상 소스 변경이나 긴 관측 공백에서는 이력을 초기화합니다. 150 mm는 관절각 제한이 아니라 **이전 승인 3D 좌표와 새 좌표 사이의 입력 도약 기준**입니다.

위치 피드백이 없는 환경에서 검출 좌표·3D 좌표·목표 관절각·PWM 명령을 나눠 UART 로그와 실제 로봇 반응을 비교했습니다.

[그리퍼 제어](https://github.com/realisshoon/zynq-cnn-motion-robot-soc/blob/fc647991090b3955780308f7e371f94595f9bf7e/robot_arm/src/app/robot/control/gripper_control.c) · [출력 적용](https://github.com/realisshoon/zynq-cnn-motion-robot-soc/blob/fc647991090b3955780308f7e371f94595f9bf7e/robot_arm/src/app/robot/control/servo_output.c) · [관측·제어 주기 연결](https://github.com/realisshoon/zynq-cnn-motion-robot-soc/blob/fc647991090b3955780308f7e371f94595f9bf7e/robot_arm/src/app/robot/control/robot_motion.c)


## 검증 결과

<a id="4-검증과-결과"></a>

### 검증 요약

| 검증 기준 | 확인한 내용 | 결과 |
|---|---|---|
| 개발 중 PWM RTL 통합 TB | 축소 주기의 채널별 펄스 폭·주기, Shadow/UPDATE, 출력 Disable | 기능 확인 |
| 개발 중 C 기록·재생 회귀 | 시작·종료 경계, HAL 실패, 틱 누락, 취소, 파일 보호 | LEFT 16 / RIGHT 16 시나리오 통과 |
| 개발 중 PC 모니터 회귀 | REC_STATE, 선택·저장·삭제, 재접속 시 표시 복구 | 131개 테스트 통과 |
| 최종 발표 시연 | CNN 관측·스테레오 3D·목표각 변환과 실제 로봇팔·Unity 연동 | 실물 통합 동작 시연 · 최우수상 |

C 회귀는 PC의 레지스터 모의·메모리 FatFS 기준입니다. PWM TB는 축소 주기 시뮬레이션이며 실제 보드의 20 ms 파형 계측과 구분합니다. 팀 공개 소스의 빌드·도구별 회귀 상태는 [실행 검증 기록](https://github.com/realisshoon/zynq-cnn-motion-robot-soc/blob/main/VALIDATION_SUMMARY.md)에서 확인할 수 있습니다.

<details>
<summary>Unity 가상환경 시연</summary>

![입력 영상·로봇팔 모델·제어 UI가 함께 보이는 Unity 시연](https://raw.githubusercontent.com/realisshoon/zynq-cnn-motion-robot-soc/fc647991090b3955780308f7e371f94595f9bf7e/docs/media/unity-digital-twin-slide35.gif)

실물과 같은 M0–M4 축 의미를 적용하고 링크·브래킷·그리퍼를 배치했습니다. UART의 TK 데이터는 서보 명령을 표시하며 실제 엔코더 위치 피드백과 구분합니다.

[Unity 소스와 실행 방법](https://github.com/realisshoon/zynq-cnn-motion-robot-soc/tree/main/Unity)

</details>

### 최종 통합 시연

![사람의 팔 동작과 실제 로봇팔·Unity 화면을 함께 보여주는 최종 발표 시연](https://raw.githubusercontent.com/realisshoon/zynq-cnn-motion-robot-soc/fc647991090b3955780308f7e371f94595f9bf7e/docs/media/demo-final-slide10.gif)

*2026.10.15 최종 발표 당시 시연. 사람의 동작 입력, 실물 로봇팔과 가상 로봇 화면을 함께 확인할 수 있습니다.*


## 실행 방법

### 소스와 자료

| 자료 | 확인할 내용 |
|---|---|
| [팀 공동 저장소](https://github.com/realisshoon/zynq-cnn-motion-robot-soc) | CNN RTL·UVM·로봇 펌웨어·Unity 전체 구성과 팀 분담 |
| [로봇팔 펌웨어 README](https://github.com/realisshoon/zynq-cnn-motion-robot-soc/blob/fc647991090b3955780308f7e371f94595f9bf7e/robot_arm/README.md) | 폴더 구조, RIGHT/LEFT 역할, 제어 흐름과 Vitis 빌드 |
| [발표 미디어 목록](https://github.com/realisshoon/zynq-cnn-motion-robot-soc/blob/fc647991090b3955780308f7e371f94595f9bf7e/docs/media/SOURCES.md) | 팀 발표자료의 원본 GIF·구성도 |
| [공개 소스 실행 검증 기록](https://github.com/realisshoon/zynq-cnn-motion-robot-soc/blob/main/VALIDATION_SUMMARY.md) | 빌드·모의 검증·실물 시험의 범위와 실행 상태 |

소스 링크 기준: 팀 저장소 commit [fc64799](https://github.com/realisshoon/zynq-cnn-motion-robot-soc/commit/fc647991090b3955780308f7e371f94595f9bf7e).

[RTL / FPGA 프로젝트 목록](../README.md) · [GitHub 포트폴리오](https://github.com/lsy49055089)


---

[웹 포트폴리오](https://seungyeol-rtl-portfolio.azuretide33.chatgpt.site) · [GitHub 프로필](https://github.com/lsy49055089)

[논문](https://github.com/lsy49055089/Parallel-Decision-Tree-Hardware) · [RTL / FPGA Design](https://github.com/lsy49055089/RTL-Design-Projects) · [Design Verification](https://github.com/lsy49055089/RTL-Verification-Projects) · [Embedded Systems](https://github.com/lsy49055089/Embedded-Systems-Projects) · [AI / CV](https://github.com/lsy49055089/AI-Projects)
