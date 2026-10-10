# PN-Guidances

## 2026-10-10 기록·표시 검토

[검토 문서](docs/reviews/2026-10_simulation_review.md)와 [기존 자료의 증거 검토](results/reviews/2026-10-10/report.md)를 추가했다. 이번 변경은 문서만 포함하며 신규 MATLAB 실행이나 코드 변경은 없다. 아래 실행 환경·설정·시험 판정은 기존 보존 자료의 설명이다.

Git 저장소는 로컬 작업 폴더의 `github_upload/`에 있다. 작업 폴더의 소스와 저장소 사본은 파일 해시가 달라 최신 작업본으로 자동 간주하지 않는다. 설정은 `src/configuration.m`, 실제 그래프 생성은 `src/visualizeSimulation.m`에서 확인한다. 저장소의 기존 시각화는 Figure 6개를 생성한다.

실행 성공, 데이터 기록·표시 확인, 유도 성능 검증은 별개다. 특정 사용자 확인 실행에서 TPN·APN 명령 배열이 동일했지만 이 사실을 모든 실행에 적용하지 않는다. 종료 표본과 시간 한도까지 실행했을 때의 마지막 이력 기록은 추가 검토 대상이다.

기준 설계는 [사용자 원본 PPT](docs/Guidance_Software_Framework.pptx)다. 문서·코드·그림을 원본 단계와 연결해 관리한다.

MATLAB 기반 2차원 PN 시뮬레이션과 소프트웨어 개발 생명주기 학습 자료를 관리하는 저장소다.

## 기본 실행

MATLAB R2025b Update 4에서 기존 실행을 확인했다. 저장소를 다운로드한 뒤 MATLAB의 현재 폴더를 저장소 최상위로 지정하고 실행한다.

```matlab
main
```

main.m은 작업 공간을 초기화하고 Figure 창을 닫는다. runSimulation을 TPN·PPN·APN별로 호출하고, 독립적인 결과 구조체 배열을 visualizeSimulation에 전달한다. 궤적, 기수각, 거리·거리 변화율, LOS 각도·각속도, 뱅크각 명령, 횡가속도 명령의 Figure 6개를 표시한다.

현재 설정은 미사일 (-1000, 1200) m, 속력 100 m/s, 표적 속력 80 m/s, 표적 횡가속도 +1 m/s², 항법상수 3이다. 표적 기동과 APN 보상 입력은 아직 함수 내부 고정값으로 관리한다.

## 시험과 결과 저장

```matlab
addpath('tests','automation');
testDirectory = runBankCommandTest();
simulationDirectory = runVersionedSimulation();
```

실행마다 results/v0.2.0/에 새 폴더를 생성한다. Figure는 PNG·FIG, 데이터는 MAT, 시험 판정은 CSV·보고서로 저장한다. [버전별 실행 목록](results/v0.2.0/README.md)에 R2024a 및 R2025b 실행과 횡가속도 1의 기동 표적 결과가 있다. 뱅크각 시험 3개는 통과했으며, 시뮬레이션 실행 성공은 유도 정확도 검증 완료를 의미하지 않는다.

v0.2.0은 개발 중이다. APN 보상항의 좌표 방향, 종료 표본 처리와 마지막 이력 표본은 추가 검토 대상이다. [설계 문서](docs/v0.2.0/05_simulation_interface.md)의 일부 계약은 아직 구현에 반영되지 않았다.

## 읽는 순서

1. [PPT 기준 단계별 산출물·결과](docs/lifecycle/README.md)
2. [생명주기 기준 MD](docs/Software_Lifecycle.md)
3. [요구사항·설계·코드·시험 추적표](docs/lifecycle/traceability.md)
4. [확보된 기존 그림과 증거 상태](results/legacy_2026-10-02/report.md)

## 저장소 폴더 역할

| 위치 | 용도 |
|---|---|
| main.m / src/ | 실행 진입점 / 설정·공통 실행·유도·운동학·시각화 코드 |
| docs/ | 기준 문서, 원본 PPT·PDF, 단계별 정리, 변경 이력 |
| examples/ | 독립 예제 guidance.m |
| tests/ | 시험 관리 및 뱅크각 단위 시험·결과 저장 함수 |
| automation/ | 기존 main 실행 및 버전별 Figure·데이터 저장 함수 |
| results/ | 기존 그림 보관과 향후 실행별 증거 |
| notes/ | 기존 학습 메모 |

2026-10-02의 기존 기록·그림은 보존하고, 2026-10-05의 구현·실행 증거를 별도로 추가했다. 상세 변경은 [변경 이력](docs/CHANGELOG.md)에 있다.

생명주기 MD의 papers/, archive/, output/, github_upload/ 설명은 로컬 작업 폴더 기준이다. 참고 논문, 자동 백업, 제작 중간 파일과 별도 발표자료는 이번 업로드에 포함하지 않았다. 과거 시험 코드와 수치 원본도 현재 확보되지 않아 포함하지 않았다.

## 2026-10-05 구조 정리
main.m만 최상위에 두고 구현 파일 7개를 src/로 이동했다. main 실행 시 src 경로를 추가한다. Figure는 표적 속력 80 m/s·횡가속도 +1 m/s²의 결과만 남겼다. 정지 표적 실행과 legacy PNG는 사용자 요청으로 삭제했으며 시험 판정과 과거 문서는 보존한다. Figure별 개별 스크립트는 없다.

