# FPGA Microwave Oven Controller

Basys3 (Artix-7)와 Verilog HDL로 구현한 전자레인지 제어 프로젝트입니다.

## 주요 기능
- Rotary Encoder(S1/S2) 시간 설정, KEY Toggle 설정 모드
- 0~540초 카운트다운과 4자리 FND `MM.SS` 표시
- Timer 완료 시 Buzzer 3회 알림
- SW 입력을 통한 SG90 Servo Door 열림/닫힘
- Vivado Setup Timing 경로 최적화

## 시스템 블록 다이어그램

![Microwave Oven Block Diagram](docs/images/block_diagram.png)

[블록 다이어그램 크게 보기](docs/images/block_diagram.png)

## FSM / 동작 흐름도

![Microwave Oven FSM Diagram](docs/images/fsm_diagram.png)

[FSM 다이어그램 크게 보기](docs/images/fsm_diagram.png)

> FSM 그림은 전체 동작을 설명하기 위한 개념도이며, 실제 RTL에 존재하는 상태 레지스터와 1:1 대응하는지는 소스 코드 확인이 필요합니다.

## 핵심 구성

| 블록 | 역할 |
|---|---|
| Debouncer | KEY, Rotary 입력 안정화 |
| Rotary Controller | CW/CCW 판단 및 시간 설정 |
| Tick Generator | 1ms Tick 생성 |
| FND / Timer Controller | 카운트다운 및 MM.SS 표시 |
| Buzzer Controller | 타이머 종료 후 3회 Beep |
| Servo Controller | SW 기반 SG90 50Hz PWM 제어 |

## 동작 시연 영상

[![Microwave Oven Controller 동작 시연](https://img.youtube.com/vi/Dh0c_G7ZhPM/hqdefault.jpg)](https://youtu.be/Dh0c_G7ZhPM)

▶ **[동작 시연 영상 보기 (YouTube)](https://youtu.be/Dh0c_G7ZhPM)**

시연 순서: KEY 설정 → Rotary 시간 증감 → 카운트다운 → Buzzer 3회 → SG90 Door OPEN/CLOSE.

## Troubleshooting
- Rotary 시간 설정과 분·초 데이터 비트 폭 문제
- FND 표시 입력 연결 문제
- 긴 분·초 변환 연산 경로로 인한 Setup Timing 위반: 총 초를 `set_time`으로 직접 전달하여 최적화

## 기술 스택
**Basys3 · Verilog HDL · Vivado · KiCad**

---
*첨부된 설계 이미지 두 장은 `docs/images/`에 업로드해야 위 이미지 링크가 표시됩니다.*
