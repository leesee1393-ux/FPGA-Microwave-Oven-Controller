# Ponytail / Codex 작업 지시서 — 전자레인지 기능 확장

**작업 경로:** `D:\project\FPGA\ai2\00.microwave_oven`

**개발 환경:** Basys3 FPGA, Vivado, Verilog HDL, 100MHz Clock

**역할:** FPGA RTL 설계 및 디버깅 엔지니어

## 1. 프로젝트 현황

기존 구현 기능:
- Rotary Encoder CW/CCW 기반 시간 설정
- KEY Toggle 기반 설정 모드 전환
- 0~540초 시간 설정
- FND MM.SS 형식 표시
- 1ms Tick 기반 Timer 카운트다운
- 설정 완료 후 3초 대기 및 자동 시작
- Setup Timing 최적화 완료

기존 기능과 Timing 최적화 구조를 유지하면서 새로운 기능만 추가하세요.

## 2. 추가 기능 A — Timer 종료 시 Buzzer 3회

**동작 조건**
- Timer가 00.00에 도달하면 Buzzer 작동
- Beep 3회 출력 후 자동 정지
- Beep ON 200ms / OFF 200ms
- 약 2kHz 구형파 출력
- Reset 시 즉시 정지
- 다음 Timer 종료 시 다시 3회 작동

**구현 요구사항**
- 기존 `timer_done` 신호 재사용
- `timer_done` 상승 에지 감지로 중복 실행 방지
- 기존 1ms Tick 재사용
- 기존 Buzzer 모듈이 없다면 `buzzer_controller.v` 생성
- Top의 `buzzer` 출력에 연결
- 실제 부저 종류와 활성 극성 확인

## 3. 추가 기능 B — SG90 Servo 도어 개폐

Basys3의 `sw` 입력으로 SG90 서보모터를 제어하세요.

| Switch | 상태 | 목표 각도 | 초기 PWM 펄스 |
|---|---|---|---|
| `sw=0` | CLOSE | 0° | 1.0ms |
| `sw=1` | OPEN | 90° | 1.5ms |

**Switch XDC**

```tcl
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports {sw}]
```

**PWM 요구사항**
- PWM 주파수 50Hz
- 주기 20ms
- 100MHz 기준 2,000,000클럭
- `sw=0`이면 CLOSE 위치 유지
- `sw=1`이면 OPEN 위치 유지
- 목표 각도 및 펄스 폭 파라미터화
- 스위치 입력에 2단 플립플롭 동기화 적용

**모듈 구성**
- 기존 서보 모듈이 없다면 `servo_controller.v` 생성
- 기존 Top의 `door` 출력을 Servo PWM으로 사용
- 기존 JA1 핀의 XDC 할당 확인
- 기존 모듈과 충돌하지 않도록 연결

**하드웨어 주의사항**
- SG90은 외부 5V 전원 사용
- FPGA GND와 외부 전원 GND 공통 연결
- FPGA I/O 핀으로 서보 전원 공급 금지
- 기구적 한계를 넘지 않도록 PWM 범위 제한

## 4. Top 모듈 통합

`top_microwave_oven.v`에 다음 구조로 연결하세요.

```text
                top_microwave_oven
                         │
           ┌─────────────┼──────────────┐
           │             │              │
       Rotary + FND   Buzzer          Servo
           │             │              │
       timer_done ───────┘              │
                                         │
                                    sw → PWM
                                         │
                                       door
```

기존 Timer 기능과 새로운 Servo 제어는 독립적으로 동작하도록 구성하세요.

현재 단계에서 도어 열림 시 조리 중단 인터록은 추가하지 마세요.

## 5. 기존 기능 유지 및 코드 품질

- KEY Toggle 방식 유지
- Rotary CW/CCW 시간 설정 유지
- 0~540초 범위 유지
- Timer 카운트다운 및 FND 표시 유지
- Setup Timing 최적화 구조 유지
- 기존 `tick_generator` 재사용
- 중복 모듈 및 불필요한 연산 추가 금지
- 100MHz `clk` 기반 순차회로 사용
- 신규 기능과 관계없는 RTL 수정 금지
- Verilog 문법 및 포트 연결 오류 방지
- 기존 XDC와 핀 중복 여부 확인

## 6. 작업 진행 방식

1. 프로젝트의 기존 RTL과 XDC 분석
2. Buzzer 및 Servo 구현에 필요한 변경 범위 확인
3. 기존 모듈 재사용을 우선하여 기능 추가
4. Top 모듈 연결 및 XDC 반영
5. 변경된 코드의 문법·합성 가능성 점검
6. Vivado Synthesis 및 Implementation이 가능하면 실행하여 Timing 결과 확인

**Testbench 파일은 작성하지 마세요. 시뮬레이션용 코드도 추가하지 마세요.**

## 7. 최종 보고

작업 완료 후 다음 내용을 보고하세요.

- 신규 생성 및 수정 파일
- Buzzer 3회 알림 구현 방식
- SG90 PWM 제어 방식
- Top 모듈 연결 변경 사항
- XDC 핀 설정 변경 사항
- 기존 기능에 미치는 영향
- 실제 실행한 합성·Timing 확인 결과
- 보드에서 직접 확인해야 할 사항

**최종 목표:** 기존 전자레인지 Timer 기능과 Timing 최적화 상태를 유지하면서, Buzzer 3회 완료 알림과 SG90 도어 개폐를 통합하는 것입니다.