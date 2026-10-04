# v0.2.0 — 공통 시뮬레이션 함수 설계

작성일: 2026-10-03 (Asia/Seoul)

상태: **실행 함수의 입출력·책임 정의, 구현·실행 검증 전**.

기준: [변경 요구사항](01_requirements.md), [결과 컨테이너 설계](04_module_design.md). 기존 02~04 문서는 결과 표시 범위의 설계로 보존한다. 이 문서는 그 설계에 실행 부분의 계약을 추가한다. 파일 번호 05는 문서 정렬용이며 개발 생명주기의 새로운 단계를 뜻하지 않는다.

## PX4 참고 원칙

프로그램 프레임워크, 코드 작성 기법(코드 스킬), 코드 적용 방법은 PX4의 공식 문서와 소스를 참고하여 설계·구현한다.

- 실행 관리와 알고리즘 계산의 책임을 분리한다. runSimulation은 실행 흐름을 관리하고, 유도 계산 함수는 현재 입력으로 명령을 계산한다.
- 유도법칙 선택에는 목적에 맞는 단순한 switch 분기를 사용할 수 있다. PX4의 FlightModeManager도 모드에 따른 Task 선택에 분기를 사용한다.
- PX4 구조를 MATLAB에 적용할 때는 현재 시뮬레이션 규모에 맞게 조정한다. 클래스·작업 큐·uORB를 그대로 도입하는 것이 필수는 아니다.
- 실제 비행 제어기의 상태 입력과 시뮬레이터의 운동 적분을 구분한다. 이 프로젝트에서는 computeKinematics와 적분기가 다음 상태를 생성한다.
- 적용 시 참고한 PX4 버전 또는 커밋과 해당 소스 위치를 기록한다. 성능 개선 여부는 실제 측정으로 확인한다.

참고: [PX4 모듈 프레임워크 공식 문서](https://docs.px4.io/main/en/modules/module_template), [FlightModeManager 공식 소스](https://github.com/PX4/PX4-Autopilot/blob/main/src/modules/flight_mode_manager/FlightModeManager.cpp). 위 링크의 main은 변경될 수 있으며 특정 버전의 고정 기준은 아니다.

## 1. 함수 계약

```matlab
function SimulationResult = runSimulation(Config, guidanceType)
```

한 번의 호출은 하나의 유도법칙으로 시뮬레이션을 실행하고 스칼라 결과 구조체 하나를 반환한다. 각 호출의 상태·이력·종료 판단은 함수 내부 지역 변수로 관리한다. 이전 호출의 최종 상태를 다음 호출의 초기 상태로 사용하지 않는다.

| 입력 | 형식 | 의미 |
|---|---|---|
| Config | 스칼라 구조체 | simulation, missile, target, wind, environment, guidance 설정 |
| guidanceType | 스칼라 string | "TPN", "PPN", "APN" 중 하나 |

Config의 기존 필드 이름과 단위는 유지한다. 표적 기동 입력은 `Config.target.lateralAccel` 스칼라 값(m/s²)으로 추가할 예정이다. 다음 단계의 PPN 기준 실행에서는 0을 사용해 기존 비기동 표적 조건을 확인하고, 기동 조건 적용은 별도로 구분한다. 현재 루트 코드의 고정값 1을 함수 내부에 숨겨 두지 않는다.

지원하지 않는 guidanceType은 오류로 알리고 다른 유도법칙으로 자동 대체하지 않는다. 시간은 유한한 값이며 timeStep > 0, endTime > startTime이어야 한다. 속력은 음수가 아니어야 하고, 유도식과 운동학이 요구하는 미사일 속력은 양수여야 한다. 중력가속도는 양수여야 한다. 필요한 필드의 누락은 오류로 알린다.

## 2. 반환 결과

SimulationResult는 기존 SimulationResults 배열의 원소와 동일한 형식이다. 유효 표본 수를 K라고 할 때 다음 데이터를 반환한다.

| 필드 | 형상 | 의미·단위 |
|---|---|---|
| name | 스칼라 string | guidanceType과 같은 결과 식별 이름 |
| time | 1×K double | 해당 실행의 표본 시각, s |
| data.targetStateHistory | K×3 double | 표적 [x, y, heading], m·m·rad |
| data.missileStateHistory | K×3 double | 미사일 [x, y, heading], m·m·rad |
| data.geometryHistory | K×4 double | [range, rangeRate, losAngle, losRate], m·m/s·rad·rad/s |
| data.bankAngleHistory | K×1 double | 제한 적용 후 미사일 뱅크각 명령, rad |
| data.lateralAccelCmdHistory | K×1 double | 제한 적용 전 유도법칙의 횡가속도 명령, m/s² |
| source | 스칼라 string | 적용한 함수·설정 출처 설명 |

함수 내부의 `missileBankCmdHistory`를 반환할 때 기존 시각화 인수 이름인 `bankAngleHistory`에 연결한다. 나머지 이력 이름은 유지한다. source는 출처 설명이며 검증 합격이나 확정 Git 버전을 의미하지 않는다. 초기 구현에서는 "runSimulation; caller-provided Config; version unverified"처럼 사실에 맞게 기록한다.

각 결과는 자신의 time을 가진다. 결과 간 표본 수를 맞추려고 보간하거나 값을 채우지 않는다. 반환 결과에는 원래 단위를 저장하고 각도의 deg 변환은 시각화에서 수행한다.

## 3. 책임 배분

| 담당 | 책임 |
|---|---|
| configuration.m | 초기조건·환경·기동·유도 설정 구성 |
| main.m | 설정 읽기, 실행 대상 순서 지정, 결과 배열 수집, 시각화 호출 |
| runSimulation.m | 한 실행의 초기화, 반복, 함수 호출, 적분, 이력·종료 관리, 결과 반환 |
| 기존 계산 함수 | 상대기하·유도 명령·뱅크각·운동학 계산 |
| visualizeSimulation.m | 결과 배열을 읽고 기존 6개 Figure에 표시 |

runSimulation은 figure 생성, 파일 저장, clear, clc, close all, 전역 변수 사용을 하지 않는다. Config를 수정하지 않고, 유도법칙별로 전체 반복문을 복제하지 않는다. 새로운 클래스는 도입하지 않는다.

## 4. 한 실행의 처리 흐름

1. 입력을 확인하고 시간 벡터·초기 상태를 구성한다.
2. 상태·기하·명령 이력을 최대 표본 수로 미리 할당한다.
3. 현재 상태의 상대기하를 계산하고 종료 조건을 평가한다.
4. guidanceType으로 유도법칙을 선택해 횡가속도 명령 하나를 계산한다.
5. 뱅크각 변환·제한을 적용하고 같은 시각의 상태·기하·명령을 기록한다.
6. 다음 시각이 있으면 현재 명령을 유지한 채 ode45로 표적·미사일 상태를 적분한다.
7. 종료 후 유효 표본만 잘라 결과 구조체를 반환한다.

모든 반환 이력의 행 i는 time(i)에 대응한다. 최대시간의 마지막 표본도 기하와 명령을 계산해 기록하고 추가 적분은 하지 않는다. 사전 할당된 0을 마지막 계산 결과처럼 반환하지 않는다.

## 5. 종료와 특이점 처리

기존 접근 종료 조건인 `previousRangeRate < 0 && rangeRate >= 0`을 사용하되, 전환이 확인된 현재 표본까지 기록한다. 단순히 iStep - 1로 잘라 상태와 종료 판단 시점을 어긋나게 하지 않는다. 각 호출은 자신의 종료 시점을 가진다.

종료 표본에서는 적분에 사용할 명령을 새로 생성하지 않고 두 명령 이력을 NaN으로 기록한다. 이는 그 시각의 명령이 적용되지 않았음을 뜻한다. 나머지 상태·기하 이력은 실제 계산값을 보존한다.

상대거리 0은 상대기하 함수의 나눗셈 전에 검사한다. 해당 상태를 마지막 표본으로 보존하고 range는 0, 정의되지 않는 거리 변화율·LOS 값 및 명령은 NaN으로 기록한 뒤 종료한다. 이 처리는 요격 성공 거리 기준을 새로 정하는 것이 아니다. 별도의 요격 성공·실패 판정은 이번 함수 계약에 포함하지 않는다.

## 6. 다음 구현 단계와 확인 기준

먼저 PPN 하나를 이 계약에 맞게 실행한다. 그다음 TPN·APN 선택을 추가한다. 알고리즘별 계산식·명령 방향·APN 보상항의 좌표 투영은 이 문서에서 확정하지 않고 해당 구현 단계에서 정리한다.

- 결과가 스칼라 구조체이며 필드와 단위가 계약에 맞는지 확인한다.
- 같은 Config의 두 호출이 독립적으로 같은 초기 상태에서 시작하는지 확인한다.
- 모든 이력의 표본 수와 time의 길이가 일치하는지 확인한다.
- 종료 표본과 마지막 표본에 계산하지 않은 0이 남지 않는지 확인한다.
- 함수 호출만으로 Figure나 저장 파일이 생성되지 않는지 확인한다.

이번 단계에서는 MATLAB 소스 수정, 실행, 시험 및 배포를 수행하지 않았다.


## 2026-10-05 폴더 적용
실행 진입점 main.m은 최상위에, configuration.m 및 계산·실행·시각화 함수는 src/에 배치했다. main에서 src 경로를 추가한다. 시험·결과 저장 함수도 src 경로를 사용한다. 이전 문서의 최상위 구현 파일 참조는 당시 위치 기록이다.

