# 시험 관리

unit, integration, system, acceptance는 기존 대화의 검증 분류에 따른 관리 폴더다. PPT 원본의 시험 장은 단위 시험이며 다른 폴더를 PPT의 새 개발 단계로 해석하지 않는다.

과거 시험의 실행 파일·원본 데이터는 확보되지 않았다. 기존 시험 정의는 [생명주기 MD](../docs/Software_Lifecycle.md) 8~9절, 과거 판정 기록은 11절에 있다.

2026-10-05에 [뱅크각 단위 시험](unit/testBankCommand.m)과 [실행·결과 저장 함수](runBankCommandTest.m)를 추가했다. 0 명령과 양·음 뱅크각 제한을 확인하며, 다른 유도 성능의 검증을 의미하지 않는다.

MATLAB에서 프로젝트 최상위를 현재 폴더로 지정하고 실행한다.

```matlab
addpath('tests');
outputDirectory = runBankCommandTest();
```

시험 방법과 예상값은 tests/에, 실행 판정·데이터·소스 사본은 results/v0.2.0/<실행ID>/에 저장한다. 실행마다 새 폴더를 만들며 과거 결과를 덮어쓰지 않는다.
