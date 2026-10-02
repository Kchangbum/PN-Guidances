# PN-Guidances

기준 설계는 [사용자 원본 PPT](docs/Guidance_Software_Framework.pptx)다. 문서·코드·그림을 원본 단계와 연결해 관리한다.

MATLAB 기반 2차원 PN 시뮬레이션과 소프트웨어 개발 생명주기 학습 자료를 관리하는 저장소다.

## 기본 실행

MATLAB R2025b Update 4에서 기존 실행을 확인했다. 저장소를 다운로드한 뒤 MATLAB의 현재 폴더를 저장소 최상위로 지정하고 실행한다.

```matlab
main
```

main.m은 작업 공간을 초기화하고 Figure 창을 닫는다. 기본 실행은 궤적, 기수각, 거리·거리 변화율, LOS 각도·각속도, 뱅크각 명령, 횡가속도 명령을 표시한다. 이번 폴더 정리와 업로드에서는 MATLAB을 다시 실행하지 않았다.

## 읽는 순서

1. [PPT 기준 단계별 산출물·결과](docs/lifecycle/README.md)
2. [생명주기 기준 MD](docs/Software_Lifecycle.md)
3. [요구사항·설계·코드·시험 추적표](docs/lifecycle/traceability.md)
4. [확보된 기존 그림과 증거 상태](results/legacy_2026-10-02/report.md)

## 저장소 폴더 역할

| 위치 | 용도 |
|---|---|
| 최상위 MATLAB 파일 7개 | 기본 실행 원본 |
| docs/ | 기준 문서, 원본 PPT·PDF, 단계별 정리, 변경 이력 |
| examples/ | 독립 예제 guidance.m |
| tests/ | 단위·통합·시스템·인수 시험의 관리 위치. 현재 실행 파일 없음 |
| automation/ | 자동화 구현 위치. 현재 운영 안내만 있으며 스크립트 미구현 |
| results/ | 기존 그림 보관과 향후 실행별 증거 |
| notes/ | 기존 학습 메모 |

기본 실행 위치와 MATLAB 코드 내용은 그대로 유지했다. 이번 변경은 산출물 정리와 업로드이며 신규 시험을 실행하지 않았다. 상세 운영 제약은 생명주기 MD 12~13절에 있다.

생명주기 MD의 papers/, archive/, output/, github_upload/ 설명은 로컬 작업 폴더 기준이다. 참고 논문, 자동 백업, 제작 중간 파일과 별도 발표자료는 이번 업로드에 포함하지 않았다. 과거 시험 코드와 수치 원본도 현재 확보되지 않아 포함하지 않았다.
