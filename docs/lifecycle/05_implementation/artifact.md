# Step 5. 코딩 — 산출물

기준: [원본 PPT](../../Guidance_Software_Framework.pptx) 17장. 상세 연결: [생명주기 MD](../../Software_Lifecycle.md) 7절.

이 파일은 원본과 기존 MD를 연결하는 정리본이다. 새로운 요구사항·기능·계산법·수치 기준을 추가하지 않는다.

## 관리 대상

- 모듈별 MATLAB 파일 목록
- 원본 소스 해시 목록

PPT 17장의 구현 파일 목록을 기준으로 최상위 MATLAB 파일 7개와 독립 예제 1개의 위치·해시를 기록한다. 파일 내용은 수정하지 않는다. PPT의 initializeConfiguration.m에 대응하는 현재 파일은 configuration.m이며 이를 자동으로 이름 변경하지 않는다.

| PPT의 구현 모듈 | 현재 파일 |
|---|---|
| Configuration | [configuration.m](../../../configuration.m) |
| Simulation Manager | [main.m](../../../main.m) |
| Relative Geometry | [computeRelativeGeometry.m](../../../computeRelativeGeometry.m) |
| PN Guidance | [computePNGuidance.m](../../../computePNGuidance.m) |
| Command Mapper | [computeBankCommand.m](../../../computeBankCommand.m) |
| Kinematics | [computeKinematics.m](../../../computeKinematics.m) |
| Visualization | [visualizeSimulation.m](../../../visualizeSimulation.m) |
| 독립 예제: 대화에서 별도 분류 | [guidance.m](../../../examples/guidance.m) |

전체 SHA-256은 [원본 파일 목록](../../../results/legacy_2026-10-02/source_inventory.csv)에 보관한다. 해시는 이번 정리의 기준이며 과거 PNG 생성 당시 코드 버전으로 단정하지 않는다.

## 유지보수

변경 시 원본 PPT, 연결된 MD 절, 담당 코드와 시험의 영향 범위를 확인한다. 변경 이유와 검증 여부를 기록하고, 사용자 승인 없이 원본 PPT·MATLAB 코드·합격 기준을 수정하지 않는다. 파일이 존재하는 것만으로 단계 완료를 선언하지 않는다.

[단계 결과](result.md) · [전체 추적표](../traceability.md)
