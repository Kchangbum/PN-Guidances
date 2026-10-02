# 2D PPN 유도 소프트웨어 개발 생명주기

작성일: 2026-10-02 (Asia/Seoul)

이 문서는 사용자 제공 설계 자료, 현재 MATLAB 소스, 별도 검증 실행에서 얻은 산출물을 소프트웨어 생명주기 순서로 연결한다. 기존 MATLAB 파일은 수정하지 않는다. 테스트 실행용 파일과 결과는 이 폴더 안에만 저장한다. 코드 수정 제안은 이 문서에 수록하지 않고 채팅으로 전달한다.

## 1. 개발 목적과 범위

2차원 평면에서 단일 요격자와 단일 표적의 운동을 모사하고, 비례항법 명령을 선회 명령으로 변환하여 궤적과 유도 결과를 확인한다.

- 현재 활성 유도법칙: PPN, `a_cmd = N * V_M * losRate`.
- 상태: `[x; y; heading]`, 단위는 m, m, rad.
- 비행 모델: 일정 속력의 운동학 모델과 순간 뱅크각 명령.
- 유도 명령 계산 주기: 설정된 `timeStep`.
- 적분: 각 명령 주기 내 `ode45`, 명령은 구간 동안 고정.
- APN, 표적 가속도 추정, 기체 동역학과 자동조종기 지연은 현재 검증 범위에 포함하지 않는다.

### 현재 기준 설정

이번 검증에서는 현재 `configuration.m`을 기준으로 한다. 앞서 제작한 발표자료의 초기조건과 다를 수 있다.

| 항목 | 설정 |
|---|---|
| 시간 | 0~60 s |
| 시간 간격 | 0.1 s |
| 요격자 위치 | (-1000, 200) m |
| 요격자 기수각 | -25 deg |
| 요격자 속력 | 100 m/s |
| 표적 위치 | (0, 0) m |
| 표적 기수각·속력 | 0 deg, 0 m/s |
| 바람 | 0 m/s, 방향 0 rad |
| 중력가속도 | 9.81 m/s² |
| 항법상수 | N = 3 |
| 뱅크각 제한 | -45~45 deg |

## 2. V 모델과 단계별 산출물

| 정의·설계 단계 | 설계 산출물 | 대응 검증 | 검증 산출물 |
|---|---|---|---|
| 요구사항 분석 | 범위, REQ-001~005, 합격 기준 | 인수 검증 | 요구사항 추적표, 충족 증거 |
| 시스템 설계 | 기능 구성, 실행 시나리오 | 시스템 테스트 | 실제 실행 데이터, 궤적 PNG |
| 아키텍처 설계 | 모듈 구성, 데이터 흐름, 규약 | 통합 테스트 | 명령·상태·이력 일치 결과 |
| 상세 설계 | 변수 정의, 명명 규칙, 함수별 입력·계산·출력 | 단위 테스트 | 해석해 비교, 수치 테스트 기록 |
| 구현 | MATLAB 소스 | 기준 버전 확인 | 실행 환경, 소스 SHA-256 |

완료 여부는 문서나 코드의 존재와 실제 검증 결과를 구분하여 판단한다. 실행 성공만으로 모든 요구사항의 충족을 주장하지 않는다.

## 3. 요구사항 분석

원본 `Guidance_Software_Framework.pdf`의 REQ-001~005를 유지한다. 아래 합격 기준은 이번 검증에서 구체화한 기준이다.

| ID | 요구사항 | 검증 기준 |
|---|---|---|
| REQ-001 | 2D 환경에서 요격자와 표적의 운동을 모사 | 직선·일정 뱅크각 선회 해석해와 비교 |
| REQ-002 | 초기조건 설정 가능 | Config 구조와 실제 기준 실행 초기 상태 일치 |
| REQ-003 | PN 법칙으로 요격 명령 생성 | 현재 구현인 PPN 식, 명령 부호와 수치 일치 |
| REQ-004 | 설정된 조건으로 시뮬레이션 수행 | 유한 상태, 시간 진행, 이력 길이와 시점 일치 |
| REQ-005 | 궤적과 요격 결과 제공 | 원본 그래프 출력과 거리·명령 이력 확인 |

이번 테스트는 학술용 시뮬레이션의 검증 증거이며 공식 인수 완료 판정은 아니다. 요격 성공은 사전에 정한 거리 기준과 종료 정책이 있어야 판정할 수 있다. 별도의 성공 거리 기준을 임의로 적용하여 성공률을 산출하지 않는다.

## 4. 시스템 설계

1. 설정 읽기 및 상태·이력 초기화.
2. 요격자와 표적의 현재 상태 구성.
3. 상대기하 계산.
4. 종료 조건 평가.
5. PPN 횡가속도 계산.
6. 뱅크각 변환 및 포화.
7. 표적·요격자 운동학 적분.
8. 상태 갱신 및 이력 기록.
9. 반복 종료 후 이력 절단 및 시각화.

기준 실행은 기존 `main.m`을 그대로 호출한다. 다른 시간 간격 등의 진단은 별도의 검증 드라이버가 기존 계산 함수를 호출하며, 원본 main 실행 결과와 혼합하지 않는다.

## 5. 아키텍처 설계

| 모듈 | 실제 파일 | 책임 | 주요 데이터 |
|---|---|---|---|
| Configuration | `configuration.m` | 기준 설정 | Config |
| Relative Geometry | `computeRelativeGeometry.m` | 상대기하 | range, rangeRate, closingSpeed, losAngle, losRate |
| PN Guidance | `computePNGuidance.m` | PPN 횡가속도 | Guidance, Geometry, Missile |
| Command Mapper | `computeBankCommand.m` | 뱅크각 변환·제한 | Environment, lateralAccelCmd |
| Kinematics | `computeKinematics.m` | 상태 미분 | state, Vehicle, Wind, Environment, bankCmd |
| Simulation Manager | `main.m` | 반복·적분·기록 | time, 상태·기하·명령 이력 |
| Visualization | `visualizeSimulation.m` | 그래프 출력 | 저장된 이력 |
| 별도 예제 | `guidance.m` | 바람 유무 선회 비교 | 원본 예제 상태 이력 |

공통 규약은 Cartesian 좌표계, 기수각 rad, 속력 m/s, 가속도 m/s²이다. 출력 그래프는 각도를 deg로 변환한다. `computeKinematics`의 속력 0 조건은 위치와 기수각 미분을 모두 0으로 반환하는 현재 모델 규약으로 기록한다.

## 6. 상세 모듈 설계

변수 정의와 명명 규칙은 상세 설계 산출물이다. 변수 정의는 데이터의 의미·형상·단위를 명시하고, 명명 규칙은 모듈을 구현할 때 사용할 표기 기준을 정한다. 아래 규칙은 원본 `Guidance_Software_Framework.pdf` 8~11쪽을 기준으로 정리하며, 데이터 정의는 현재 소스에서 확인한 실제 이름을 사용한다.

### 6.1 명명 규칙

| 대상 | 표기 방식 | 규칙 | 예시 |
|---|---|---|---|
| 일반 변수 | camelCase | 소문자로 시작하고 이후 단어의 첫 글자를 대문자로 표기 | `timeStep`, `missileState`, `lateralAccelCmd` |
| 개수 변수 | n + 대상 | 개수를 나타내는 변수에 n 접두사 | `nSteps` |
| 반복 인덱스 | i + 대상 | 반복 대상이 드러나는 이름 | `iStep` |
| Boolean 변수 | is / has / can + 의미 | 긍정형 조건을 나타내는 이름 | 원본 규칙 예시: `is...`, `has...`, `can...` |
| 상수 | UPPER_CASE | 대문자와 언더바로 의미를 구분 | 문서상의 예: `MAX_BANK_ANGLE`, `MIN_RANGE` |
| 구조체 | PascalCase | 구조체 이름은 대문자로 시작 | `Config`, `Missile`, `Target`, `Geometry` |
| 구조체 Field | camelCase | 관련 데이터를 묶고 Field의 의미를 명확하게 표시 | `Config.simulation`, `Geometry.losRate` |
| 함수 | camelCase | 수행 동작을 나타내는 동사로 시작 | `computeRelativeGeometry`, `computeBankCommand` |

일반 변수와 함수에서 언더바 사용을 지양하고, 의미가 불분명한 축약어를 피한다. 넓은 범위의 변수는 의미가 명확한 이름을 사용하고, 좁은 범위의 임시 변수는 짧은 이름을 사용할 수 있다. 구조체는 관련 데이터끼리 묶고 지나치게 깊은 계층은 지양한다. 함수는 가능한 한 하나의 명확한 기능을 수행한다.

함수 접두사 규칙은 계산 `compute...`, 초기화 `initialize...`, 값 획득 `get...`, 값 설정 `set...`, Boolean 반환 `is...`이다. 현재 `configuration.m`은 설정 스크립트이며 함수로 정의되어 있지 않다.

사용자가 바꾸는 시뮬레이션 파라미터는 Config 설정값으로 관리한다. 원본 자료의 `MAX_ITERATIONS`, `MAX_BANK_ANGLE`, `MIN_RANGE`, `NUMERICAL_TOLERANCE`는 상수 명명 규칙의 예시이며 현재 소스에 이 이름의 상수가 선언되어 있다는 뜻은 아니다. 이 절은 설계 규칙을 기록한 것으로 전체 소스의 규칙 준수를 판정한 결과가 아니다.

### 6.2 실행·상태·명령 변수 정의

현재 숫자형 상태와 이력은 MATLAB `double` 배열이다. `nSteps`는 원래 전체 시간 벡터 길이이며, 실행 종료 후 잘린 이력의 표본 수와 구분한다. 아래 표의 K는 절단 후 저장된 유효 표본 수이다.

| 변수 | 형상·자료형 | 의미 | 단위 |
|---|---|---|---|
| `timeStep` | scalar double | 유도 명령 갱신 및 시뮬레이션 시간 간격 | s |
| `time` | 1×K double | 저장 이력의 시간 벡터 | s |
| `nSteps` | scalar double, 정수값 | 초기 전체 시간 표본 수 | 개 |
| `iStep` | scalar double, 정수값 | 현재 루프 인덱스 | 없음 |
| `endStep` | scalar double, 정수값 | 저장 이력의 절단 끝 인덱스 | 없음 |
| `previousRangeRate` | scalar double | 이전 평가 시점의 거리 변화율, 초기값 NaN | m/s |
| `missileState` | 3×1 double | 현재 요격자 상태 `[x; y; heading]` | m, m, rad |
| `targetState` | 3×1 double | 현재 표적 상태 `[x; y; heading]` | m, m, rad |
| `stateDerivative` | 3×1 double | 운동학 상태 미분 `[xRate; yRate; headingRate]` | m/s, m/s, rad/s |
| `lateralAccelCmd` | scalar double | PPN 횡가속도 명령 | m/s² |
| `missileBankCmd` | scalar double | 요격자 뱅크각 명령 | rad |
| `targetBankCmd` | scalar double | 표적 뱅크각 명령, 현재 0 | rad |
| `timeSpan` | 1×2 double | 한 명령 구간의 적분 시작·끝 시각 | s |

### 6.3 구조체와 설정 데이터 정의

Config 하위 그룹은 camelCase Field이며 각각 구조체 값을 가진다. 함수의 구조체 인수명 `Vehicle`, `Wind`, `Environment`, `Guidance`는 각 함수의 역할에 맞춘 이름이다.

| 데이터 | Field | 의미·단위 |
|---|---|---|
| `Config.simulation` | `timeStep`, `startTime`, `endTime` | 시간 간격·시작·끝, s |
| `Config.missile` | `initialX`, `initialY`, `initialHeading`, `speed` | 요격자 초기 위치 m, 초기 기수각 rad, 속력 m/s |
| `Config.target` | `initialX`, `initialY`, `initialHeading`, `speed` | 표적 초기 위치 m, 초기 기수각 rad, 속력 m/s |
| `Config.wind` | `speed`, `direction` | 바람 속력 m/s, 방향 rad |
| `Config.environment` | `gravity` | 중력가속도 m/s² |
| `Config.guidance` | `navigationGain` | 항법상수, 무차원 |
| `Missile`, `Target` | `x`, `y`, `heading`, `speed` | 기하 계산 시점의 위치 m, 기수각 rad, 속력 m/s |
| `Geometry` | `range`, `rangeRate`, `closingSpeed` | 상대거리 m, 거리 변화율 m/s, 접근속도 m/s |
| `Geometry` | `losAngle`, `losRate` | LOS 각 rad, LOS 각속도 rad/s |

### 6.4 상대기하·운동학 내부 변수 정의

| 실제 변수명 | 정의 | 단위 |
|---|---|---|
| `relativeX`, `relativeY` | 표적 위치 − 요격자 위치의 x·y 성분 | m |
| `relativeVelocityX`, `relativeVelocityY` | 표적 속도 − 요격자 속도의 x·y 성분 | m/s |
| `range` | 상대위치 벡터 크기 | m |
| `rangeRate` | 거리의 시간 변화율 | m/s |
| `closingSpeed` | `-rangeRate`, 양수이면 접근 | m/s |
| `losAngle` | x축 기준 LOS 방향각, `atan2(relativeY, relativeX)` | rad |
| `losRate` | LOS 방향각의 시간 변화율 | rad/s |
| `heading` | 운동학 계산에 사용되는 `state(3)` | rad |
| `xRate`, `yRate` | 관성 좌표계의 위치 미분, 바람 포함 | m/s |
| `headingRate` | 뱅크각과 속력에 따른 기수각 변화율 | rad/s |

### 6.5 이력 데이터 정의

| 변수 | 형상 | 열 또는 원소 의미 | 단위 |
|---|---|---|---|
| `missileStateHistory` | K×3 | `[x, y, heading]` | m, m, rad |
| `targetStateHistory` | K×3 | `[x, y, heading]` | m, m, rad |
| `geometryHistory` | K×4 | `[range, rangeRate, losAngle, losRate]` | m, m/s, rad, rad/s |
| `missileBankCmdHistory` | K×1 | 각 평가 시점의 요격자 뱅크각 명령 | rad |
| `lateralAccelCmdHistory` | K×1 | 각 평가 시점의 PPN 횡가속도 명령 | m/s² |

`closingSpeed`는 Geometry 출력 Field이지만 현재 `geometryHistory`의 저장 열에는 포함되지 않는다. `visualizeSimulation`의 `bankAngleHistory` 인수는 `missileBankCmdHistory`를 전달받으며 함수 내부에서 deg로 변환한다. 위치·기하·명령이 같은 시점에 대응하는지는 이력 정렬 테스트로 확인한다.

### 6.6 함수별 입력·출력 정의

| 함수 | 입력 | 출력 |
|---|---|---|
| `computeRelativeGeometry` | `Target`, `Missile` | `Geometry` 구조체 |
| `computePNGuidance` | `Guidance`, `Geometry`, `Missile` | `lateralAccelCmd`, m/s² |
| `computeBankCommand` | `Environment`, `lateralAccelCmd` | `bankCmd`, rad |
| `computeKinematics` | 시간, `state`, `Vehicle`, `Wind`, `Environment`, `bankCmd` | `stateDerivative`, 3×1 |
| `visualizeSimulation` | 시간과 상태·기하·뱅크각·가속도 이력 | 반환값 없음, figure 6개 생성 |

`computeKinematics`의 시간 인수는 원본에서 `~`로 표시되어 계산에 직접 사용되지 않는다. `main.m`과 `configuration.m`은 함수 인수·반환값 대신 스크립트 작업공간의 데이터를 사용한다.

### 6.7 상대기하 계산 설계

```text
dx = x_T - x_M
dy = y_T - y_M
R = sqrt(dx² + dy²)
dvx = V_T*cos(heading_T) - V_M*cos(heading_M)
dvy = V_T*sin(heading_T) - V_M*sin(heading_M)
rangeRate = (dx*dvx + dy*dvy) / R
closingSpeed = -rangeRate
losAngle = atan2(dy, dx)
losRate = (dx*dvy - dy*dvx) / R²
```

### 6.8 유도와 명령 변환 설계

```text
lateralAccelCmd = N * V_M * losRate
bankCmd = atan2(lateralAccelCmd, gravity)
bankCmd = clamp(bankCmd, -45 deg, +45 deg)
```

### 6.9 운동학 계산 설계

```text
Vehicle.speed = 0: stateDerivative = [0; 0; 0]
Otherwise:
  xRate = V*cos(heading) + V_w*cos(direction_w)
  yRate = V*sin(heading) + V_w*sin(direction_w)
  headingRate = gravity*tan(bankCmd) / V
```

### 6.10 현재 종료 규칙

원본 main은 이전 거리 변화율이 음수이고 현재 값이 0 이상이면 반복을 끝낸다. 이는 최근접점 통과 감지이며 별도의 요격 성공 거리 기준은 소스에 정의되어 있지 않다. 저장된 표본 최소거리와 연속시간의 실제 최소거리는 구분한다.

## 7. 구현 및 기준 버전 보존

- 기존 `.m` 8개는 읽기와 실행만 수행한다.
- 새 테스트 파일: `tests/runVerification.m`.
- 실행 전·후 소스 해시: `data/source_hashes_before.json`, `data/source_hashes_after.json`.
- 원본 기준 실행 데이터: `data/baseline_original_main.mat`.
- 별도 예제 실행 데이터: `data/guidance_example.mat`.
- 검증용 드라이버 실행 데이터: `data/diagnostic_runs.mat`.
- MATLAB 버전과 실행 시각은 실행 로그와 JSON에 기록한다.

## 8. 검증 계획과 독립 기준

| 테스트 묶음 | 내용 | 기준 |
|---|---|---|
| UT-01~03 | 상대기하·부호·미분 검증 | 직접 계산값과 유한차분 |
| UT-04~06 | PPN·뱅크각 포화 | 독립 수치 기대값 |
| UT-07~09 | 직선·바람·정지 상태 미분 | 벡터 성분 기대값 |
| UT-10~12 | 운동학 적분 | 원운동·직선 해석해 |
| IT-01~03 | 기준 실행 명령·포화·기하 이력 | 식·상태에서 재계산 |
| IT-04 | 별도 드라이버의 기준 일치 | 원본 main의 저장 상태 |
| ST-01~03 | 원본 main 실행·그림·이력 길이 | 실제 실행 객체·데이터 |
| EDGE-01 | 동일 위치의 상대기하 | 유한 출력 요구 기준 |
| EDGE-02 | 시간 종료 시 마지막 기하 이력 | 원본 배열 할당·루프 범위의 독립 재현 |
| EDGE-03 | 정지 표적·횡풍의 LOS 일치 | 원본 운동학 상대속도에서 재계산 |
| EX-01~02 | 별도 바람 예제 | 기수각 일치·바람 변위 해석값 |

EDGE-02는 원본 main의 다른 설정 실행이 아니라, 동일한 배열 할당과 루프 범위를 별도 진단에서 재현한 결과다. 경계 테스트는 요구 기준에 대한 판정이며 모든 입력에 대한 보증은 아니다.

허용 오차는 테스트에 따라 명시한다. 일정 뱅크각 10 s 선회 위치 오차는 0.01 m, 기수각 오차는 1e-4 rad를 기준으로 한다. 대수 계산과 명령 비교는 각 기록에 제시한 절대 허용 오차를 사용한다.

### 8.1 기준 시나리오와 판정 방법

그림별 합격 판정은 1절의 무풍·정지 표적 기준 시나리오를 대상으로 한다. 각 그림에는 사용한 설정, 데이터 출처, 시간·단위, 저장된 마지막 표본과 종료 평가 시점을 표시한다. 조건을 바꾼 결과는 별도 시험으로 구분한다.

그래프는 판정 근거를 보여주는 산출물이며, 합격 여부는 원본 데이터에서 계산한 측정값과 기대값을 비교하여 결정한다. 곡선의 매끄러움이나 거리·LOS 각속도의 감소만으로 합격을 판정하지 않는다. 이 절을 추가하면서 MATLAB이나 기존 테스트를 다시 실행하지 않았으며, 아래 상태는 11절의 기존 검증 증거에 근거한다.

| 판정 | 의미 |
|---|---|
| PASS | 정의한 항목을 실행했고 측정값이 허용 범위 안에 있음 |
| FAIL | 정의한 항목의 실행 또는 명시한 독립 재현에서 기준 위반 확인 |
| 미실행 | 기준은 작성했지만 해당 측정·검증 증거를 아직 확보하지 않음 |
| 판정 보류 | 성능 목표나 허용 차이가 아직 확정되지 않음 |

소프트웨어 계산의 정확성과 시나리오 성능은 별도로 판정한다. 계산이 정확하더라도 요구하는 성능을 충족하지 못할 수 있다. 합격표에서 한 항목의 PASS를 다른 항목이나 전체 요구사항의 합격으로 확대하지 않는다.

### 8.2 추천 결과 그림과 생명주기 단계

| 그림 ID | 결과 그림과 구성 | 축·단위 | 대응 검증 단계 | 관련 요구사항 |
|---|---|---|---|---|
| FIG-01 | 평면 궤적, 시작·종료 표본, 종료 부근 확대 | x–y [m], 동일 축 비율 | 기준 시나리오 시스템 검증 | REQ-001, REQ-002, REQ-005 |
| FIG-02 | 상대거리와 거리 변화율, 종료 평가 표본 구분 | 시간 [s], R [m], Ṙ [m/s] | 이력 통합 검증·종료 시스템 검증 | REQ-004, REQ-005 |
| FIG-03 | LOS 각속도와 기수각−LOS각 | 시간 [s], 각속도 [deg/s], 각도 [deg] | 상대기하 단위 검증·시스템 동작 확인 | REQ-001, REQ-003, REQ-005 |
| FIG-04 | 요청 가속도·제한 후 운동학 가속도, 뱅크각 | 시간 [s], 가속도 [m/s²], 뱅크각 [deg] | 유도·명령 변환·운동학 통합 검증 | REQ-003, REQ-004, REQ-005 |
| FIG-05 | 시간 간격별 종료 부근 거리 및 최소 표본거리 | 시간 [s]–R [m], dt [s]–최소 표본거리 [m] | 시스템 수준의 수치 민감도 검증 | REQ-004, REQ-005 |

FIG-01~05는 결과 그림의 계획 ID다. 기존 PNG 5개 또는 원본 figure 6개와 일대일 대응하는 파일 번호가 아니며, 모든 추천 구성이 이미 제작되었다는 뜻은 아니다. `png/02_baseline_dashboard.png`는 FIG-01~04의 일부 정보를 포함하고, `png/03_time_step_sensitivity.png`는 FIG-05의 기존 비교 증거다. 이 경로들은 프로젝트의 `lifecycle_artifacts` 폴더를 기준으로 한다.

### 8.3 그림별 합격 기준표

아래 수치 기준은 이번 소프트웨어 계산 검증에 적용할 기준안이다. 기존 테스트에서 사용한 절대 허용 오차를 해당 항목에 연결했으며, 새로운 성능 목표를 기존 결과에 맞추어 설정하지 않는다.

| 기준 ID | 그림 | 확인 항목 | 합격 조건·허용 오차 | 기존 증거와 현재 상태 |
|---|---|---|---|---|
| AC-01 | FIG-01 | 초기 상태와 설정 일치 | 두 비행체의 첫 위치·기수각이 Config와 일치. 위치 오차 ≤1e-8 m, 기수각 오차 ≤1e-10 rad | 기준 데이터 존재. 이 허용 오차로 항목을 기록하는 검증은 미실행 |
| AC-02 | FIG-01 | 궤적 데이터의 유효성 | 기준 실행의 모든 상태값이 유한하고 상태 이력 길이가 시간 표본 수와 일치 | ST-01, ST-03 PASS |
| AC-03 | FIG-02 | 상대거리 이력의 정확성 | 매 표본의 저장 거리와 두 위치에서 재계산한 거리의 최대 차이 ≤1e-8 m | IT-03 PASS, 차이 0 m |
| AC-04 | FIG-02 | 종료 평가 표본의 보존 | 저장 이력과 결과 설명이 종료 판정에 사용한 시점·상태를 누락하지 않으며, 평가 표본을 추적할 수 있음 | FAIL. 10.3 s 종료 평가 표본이 원본 이력에서 제외됨; 별도 검증 데이터에는 보존 |
| AC-05 | FIG-02 | 시간 종료의 마지막 기하 이력 | 마지막 저장 거리와 마지막 상태에서 계산한 거리의 차이 ≤1e-8 m | EDGE-02 FAIL. 원본 루프 규칙의 독립 재현이며 직접 main 시간 종료 실행은 아님 |
| AC-06 | FIG-03 | 상대기하 계산의 정확성 | 지정한 정면·비축 기대값은 UT-01·02의 허용 오차 이내, 유한차분은 UT-03의 절대 허용 오차 0.002 이내 | UT-01~03 PASS. 지정한 시험 조건에 한정 |
| AC-07 | FIG-03 | 상대 방향각 후처리 | 기수각−LOS각을 [-180°, 180°]로 정규화하고 독립 후처리값과 차이 ≤1e-8 deg | 추천 그림의 해당 후처리 검증은 미실행 |
| AC-08 | FIG-04 | PPN 요청 가속도 | 저장 명령과 N·V_M·losRate의 최대 차이 ≤1e-10 m/s² | IT-01 PASS, 차이 0 m/s² |
| AC-09 | FIG-04 | 뱅크각 변환과 포화 | 지정 입력의 변환 오차 ≤1e-12 rad, 전체 기준 실행에서 절댓값 ≤π/4+1e-12 rad | UT-06, IT-02 PASS |
| AC-10 | FIG-04 | 제한 후 가속도의 연결 | 원본 운동학으로 구한 V_M·headingRate와 g·tan(bankCmd)의 최대 차이 ≤1e-10 m/s² | 데이터로 평가 가능한 기준. 이 항목의 별도 검증은 미실행 |
| AC-11 | FIG-05 | 비교 조건과 정의의 일관성 | dt 외의 설정과 적분 방식이 같고, 모든 실행에서 같은 정의의 평가 표본 최소거리·시각을 사용 | 기존 진단은 동일 설정과 드라이버를 사용. 비교 정의·데이터는 11.3절에 기록 |
| AC-12 | FIG-05 | 시간 간격별 성능 차이 | 최소거리·최근접 시각의 허용 차이를 사전에 정한 뒤 동일 평가 기준으로 비교 | 판정 보류. 허용 차이 미확정; 수렴 완료를 선언하지 않음 |
| AC-13 | FIG-01, FIG-02 | 시나리오의 성공 여부 | 사전에 정한 성공 거리와 종료 정책을 만족 | 판정 보류. 성공 거리 미확정 |

AC-06의 유한차분 허용 오차는 기존 UT-03에서 거리 변화율 [m/s]과 LOS 각속도 [rad/s] 각각에 적용한 수치 절대 오차다. 두 물리량을 합산한 오차가 아니다. 이 기준을 다른 입력 범위 전체의 정확도 보증으로 사용하지 않는다.

AC-07의 정규화 각도에는 ±180° 경계에서 표시 점프가 생길 수 있다. 이를 물리적 운동의 불연속으로 판정하지 않는다. LOS 각속도와 상대 방향각이 항상 단조 감소하거나 최종값이 반드시 0이어야 한다는 조건은 부과하지 않는다.

FIG-04에서 `g·tan(bankCmd)`는 현재 운동학 모델의 제한 후 가속도다. 실제 기체의 측정 가속도가 아니므로 그래프 범례에 구분해서 표시한다. 이 값과 상대 방향각은 기존 저장 데이터를 이용한 후처리 대상이며, 원본 코드를 수정했다는 뜻이 아니다.

### 8.4 합격 기준의 확정 상태와 판정 기록

이 기준표는 문서에 추가한 검증 기준안이며 모든 성능 기준의 확정이나 인수 완료를 의미하지 않는다. 계산·이력·명령 제한 항목은 위 수치 기준으로 검증하고, 성공 거리와 시간 간격별 허용 차이는 판정 보류로 남긴다. 미실행 항목은 측정 결과가 확보되기 전까지 PASS로 표시하지 않는다.

| 기록 항목 | 저장할 내용 |
|---|---|
| 시험 조건 | Config, 기준 소스, MATLAB 버전, 실행 시각 |
| 요구사항·판정 기준 | REQ ID, AC ID, 기대값, 절대 허용 오차 |
| 측정 결과 | 측정값·최대 오차, 평가 시점과 표본 수 |
| 근거 | 그림 ID와 실제 PNG 파일, CSV·JSON·MAT 경로 |
| 판정 | PASS / FAIL / 미실행 / 판정 보류, 직접 실행·독립 재현 여부 |

## 9. 요구사항 추적

| 요구사항 | 설계·구현 | 검증 증거 | 범위 |
|---|---|---|---|
| REQ-001 | 좌표계·운동학, computeKinematics | UT-07~12, EX-01~02 | 기준 및 해석해 시나리오 |
| REQ-002 | Config, configuration, main 초기화 | 실제 baseline Config·첫 상태 | 현재 설정 실행; 전체 설정 조합 아님 |
| REQ-003 | PPN 식, computePNGuidance | UT-04~05, IT-01 | 활성 PPN 구현 |
| REQ-004 | main 반복·적분·이력 | IT-02~04, ST-01~03, EDGE 테스트 | 기준 실행과 별도 경계 검증 |
| REQ-005 | visualizeSimulation | 원본 그래프 PNG, baseline 데이터 | 그래프·최소 표본거리 증거 |

## 10. 산출물 폴더

```text
lifecycle_artifacts/
  Software_Lifecycle.md
  tests/
    runVerification.m
  png/
    00_test_summary.png
    01_unit_kinematics.png
    02_baseline_dashboard.png
    03_time_step_sensitivity.png
    04_boundary_evidence.png
    05_guidance_example.png
    baseline_original_01.png ... baseline_original_06.png
  data/
    source_hashes_before.json
    source_hashes_after.json
    source_integrity.json
    matlab_execution.log
    verification_results.json
    test_records.csv
    time_step_results.csv
    baseline_original_main.mat
    guidance_example.mat
    diagnostic_runs.mat
```

PNG는 결과를 확인·발표하는 용도이며, 수치 근거와 재실행 정보는 JSON, CSV, MAT, 테스트 파일에 보존한다. 기존 PPTX/PDF와 원본 MATLAB 소스는 변경하지 않는다.

### 재실행

프로젝트 원본 폴더에서 MATLAB을 실행한 뒤 아래 명령을 사용한다. 테스트 파일은 원본 함수를 호출하며, 기존 산출물 폴더의 테스트 결과 파일을 다시 기록한다. 원본 main과 guidance의 `clear`, `close all`이 현재 MATLAB 세션에 영향을 줄 수 있으므로 별도 배치 프로세스에서 실행하는 방식이 적합하다.

```matlab
addpath(fullfile(pwd, 'lifecycle_artifacts', 'tests'));
runVerification
```

실제 검증은 별도의 MATLAB 배치 프로세스에서 수행했다.

## 11. 실행 결과

MATLAB R2025b Update 4 (`25.2.0.3150157`)에서 실제 실행했다. 최종 실행 시작 시각은 2026-10-02 17:24:40 (Asia/Seoul)이며, **24개 검증 중 21개 PASS, 3개 FAIL**이다. 실패한 경계 검증을 제외하거나 통과로 처리하지 않았다.

### 11.1 테스트별 결과

| ID | 결과 | 확인한 내용 |
|---|---|---|
| UT-01 | PASS | 정면 접근: R=1000 m, Ṙ=-100 m/s, Vc=100 m/s, LOS 각속도=0 |
| UT-02 | PASS | 비축 방향 LOS 각속도=0.005 rad/s |
| UT-03 | PASS | 거리·LOS 미분이 유한차분과 허용 오차 내 일치 |
| UT-04 | PASS | 양의 PPN 명령=3 m/s² |
| UT-05 | PASS | 음의 PPN 명령=-3 m/s² |
| UT-06 | PASS | 0, ±g, ±2g 입력의 뱅크각 변환과 ±45 deg 포화 |
| UT-07 | PASS | 무풍·뱅크각 0 상태 미분=[100, 0, 0] |
| UT-08 | PASS | 횡풍 5 m/s 상태 미분=[100, 5, 0] |
| UT-09 | PASS | 속력 0일 때 현재 정지 모델 규약 유지 |
| UT-10 | PASS | 10 s 일정 뱅크각 선회 위치 해석해 비교 |
| UT-11 | PASS | 10 s 일정 뱅크각 선회 기수각 해석해 비교 |
| UT-12 | PASS | 10 s 직선 비행 최종 상태=[1000, 0, 0] |
| IT-01 | PASS | 원본 main의 PPN 명령 식 일치 |
| IT-02 | PASS | 원본 main의 뱅크각 제한 유지 |
| IT-03 | PASS | 저장된 상대거리와 상태에서 재계산한 거리 일치 |
| IT-04 | PASS | 별도 드라이버가 기준 main의 저장 상태와 일치 |
| ST-01 | PASS | 원본 main 이력에 비유한 값 없음 |
| ST-02 | PASS | 원본 시각화 그래프 6개 생성 |
| ST-03 | PASS | 모든 상태·명령·기하 이력 길이=103 |
| EDGE-01 | FAIL | R=0에서 rangeRate와 losRate가 NaN |
| EDGE-02 | FAIL | 1 s 종료 진단의 마지막 실제 거리는 922.142489 m, 원본 할당·루프 규칙의 마지막 기하 값은 0 |
| EDGE-03 | FAIL | 정지 표적·횡풍 5 m/s에서 Geometry LOS rate=0, Kinematics 기반 LOS rate=-0.005 rad/s |
| EX-01 | PASS | 원본 guidance 예제의 바람 유무 기수각 차이=8.88e-16 rad |
| EX-02 | PASS | 원본 guidance 예제의 바람 변위 최대 오차=1.32e-5 m |

EDGE-01과 EDGE-03은 원본 함수의 직접 실행 결과다. EDGE-02는 시간 종료에 대한 원본 루프 규칙의 독립 재현 결과이며, 원본 main을 시간 1 s로 바꾸어 실행한 결과가 아니다. 동일 위치의 LOS 방향 자체는 정의되지 않으므로 EDGE-01의 판정은 그 입력을 안전하게 다루는 유한값 요구 기준에 대한 결과다.

### 11.2 기준 시나리오의 실제 결과

| 항목 | 측정값 |
|---|---|
| 저장 이력 표본 수 | 103 |
| 저장 이력 종료 시각 | 10.2 s |
| 저장 이력의 최소 표본거리 | 5.611612196 m |
| 종료 판정 시각 | 10.3 s |
| 종료 판정 시 계산된 거리 | 4.388387804 m |
| 종료 판정 시 거리 변화율 | 약 +100 m/s |
| 저장 거리와 상태 재계산 거리의 최대 차이 | 0 m |
| 일정 뱅크각 선회 최대 위치 오차 | 1.361377231e-8 m |
| 일정 뱅크각 선회 최대 기수각 오차 | 2.220446049e-16 rad |

10.3 s의 종료 평가 상태는 원본의 절단 규칙에 따라 10.2 s까지의 저장 이력에 포함되지 않는다. 위 두 거리는 서로 다른 표본의 값이며 연속시간 miss distance 또는 요격 성공 판정값으로 해석하지 않는다.

### 11.3 시간 간격 진단

기존 계산 함수를 호출하는 별도 드라이버에서 설정값을 메모리상으로 달리하여 실행했다. 원본 설정 파일이나 main은 변경하지 않았다. IT-04로 dt=0.1 s 드라이버와 원본 main의 저장 상태가 일치함을 확인했다.

| dt [s] | 평가된 표본 최소거리 [m] | 해당 표본 시각 [s] |
|---|---|---|
| 0.1 | 4.388387804 | 10.3 |
| 0.05 | 0.632707082 | 10.25 |
| 0.025 | 0.643282237 | 10.25 |
| 0.0125 | 0.601423341 | 10.2625 |

이 비교에는 유도 명령 갱신 주기 변화와 거리 측정 표본 변화가 함께 포함된다. 표본 최소거리는 dt에 따라 단조 감소하지 않으며, 위 결과만으로 연속시간 최소거리의 수렴을 선언하지 않는다.

### 11.4 단계별 검증 상태

| 단계 | 현재 상태 | 산출물 |
|---|---|---|
| 요구사항 분석 | 범위와 검증 기준 정리 | 이 문서 1~3절 |
| 시스템·아키텍처·상세 설계 | 현재 구현과 연결하여 정리 | 이 문서 4~6절 |
| 구현 기준 보존 | 기존 소스 8개 해시 일치 | source_integrity.json |
| 단위 검증 | 12개 통과 | test_records.csv, 01_unit_kinematics.png |
| 통합 검증 | 4개 통과 | test_records.csv, baseline 데이터 |
| 기준 시스템 검증 | 3개 통과 | 원본 그래프 6개, 02_baseline_dashboard.png |
| 경계 검증 | 3개 실패 | JSON·CSV, 04_boundary_evidence.png |
| 별도 바람 예제 검증 | 2개 통과 | guidance_example.mat, 05_guidance_example.png |
| 전체 요구사항 인수 | 완료 판정하지 않음 | 검증 범위·판정 근거는 위 추적표에 명시 |

기준 무풍 PPN 시나리오와 정상 입력의 계산·운동학은 테스트 기준을 충족했다. 경계 입력의 실패와 표본 거리의 해석 한계가 있어 전체 소프트웨어 검증 완료를 주장하지 않는다. 필요한 코드 변경 내용은 사용자 요청에 따라 채팅에만 전달한다.
