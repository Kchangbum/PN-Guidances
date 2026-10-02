# 기존 산출물 정리 결과

이 폴더는 신규 MATLAB 실행 결과가 아니라 기존 output/에서 발견한 PNG의 보관 묶음이다. 날짜는 기존 MD의 기록일 기준이며 각 그림의 실제 생성 시각을 새로 확정한 것이 아니다.

## 확보한 그림

| 파일 | 내용 |
|---|---|
| [png/05_guidance_example.png](png/05_guidance_example.png) | 독립 바람 예제 |
| [png/baseline_original_01.png](png/baseline_original_01.png) | XY 궤적 |
| [png/baseline_original_02.png](png/baseline_original_02.png) | 기수각 |
| [png/baseline_original_03.png](png/baseline_original_03.png) | 거리·거리 변화율 |
| [png/baseline_original_04.png](png/baseline_original_04.png) | LOS 각도·각속도 |
| [png/baseline_original_05.png](png/baseline_original_05.png) | 뱅크각 명령 |
| [png/baseline_original_06.png](png/baseline_original_06.png) | 횡가속도 명령 |

PNG 이동 전후 SHA-256이 일치한다. 원본 데이터, 시험 실행 코드, 실행 로그는 확보되지 않았으므로 PNG만으로 수치 판정이나 현재 소스와의 정확한 버전 대응을 확정하지 않는다. 사용자가 최근 첨부한 화면과 여기 보관된 PNG를 같은 실행으로 간주하지 않는다.

## 과거 기록과 현재 확인의 구분

- 기존 MD: 과거 24개 시험 중 21개 통과·3개 실패 기록.
- 현재 확인: PNG 7개와 원본 PPT·MATLAB 파일 존재 및 이동·정리 전후 내용 보존.
- 현재 미확보: runVerification.m, test_records.csv, verification_results.json, MAT 원본, 시험 로그, 나머지 요약·단위·시간 간격·경계 PNG.
- 이번 MATLAB 실행: 미실행. 인수 합격: 판정보류.
- 결과 폴더를 만들었다는 사실은 시험 완료를 의미하지 않는다.

## 다음 기록의 보존

이번 정리에서 MATLAB 원본 8개와 설계 PPT·PDF 4개의 SHA-256 보존을 확인했다. [원본 목록](source_inventory.csv)은 파일 보존 기록이며 기능 시험 결과가 아니다. 관리 문서의 로컬 파일 링크를 확인했으며 누락된 링크가 없었다.

새 실행은 results/<실행_ID>/에 별도로 보관한다. 이 폴더의 그림과 manifest.json은 덮어쓰지 않는다. 시험 코드와 수치 증거가 복원되면 출처·해시와 복원 시각을 별도 기록한다.
