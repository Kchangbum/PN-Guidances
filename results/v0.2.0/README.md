# v0.2.0 결과

현재 보관하는 Figure는 표적 속력 80 m/s, 횡가속도 +1 m/s² 조건의 결과뿐이다.

- [기동 표적 Figure 6개와 원본 데이터](2026-10-05_005619_729/report.md): R2025b Update 4, APN 보상 입력 +1 m/s². PNG·FIG 각 6개.
- [R2025b 뱅크각 시험](2026-10-05_005327_073/report.md): 3개 PASS.
- [R2024a 뱅크각 시험](2026-10-05_005300_017/report.md): 3개 PASS.

2026-10-05 사용자 요청으로 정지 표적 실행 폴더 2개와 legacy PNG를 삭제했다. legacy 문서·과거 판정은 이력으로 남긴다. 시험 결과에는 Figure가 없다.

v0.2.0은 개발 중이다. 표본 최소 거리를 연속 최근접 거리나 요격 판정으로 해석하지 않는다.

시험 코드는 tests/, 구현 코드는 src/, 실행 진입점은 main.m에 있다. Figure별 별도 스크립트는 만들지 않는다. 기존 결과의 data/source/는 당시 실행 코드의 증거 사본이다.

```matlab
addpath('automation');
outputDirectory = runVersionedSimulation();
```

새 실행은 <실행ID>/ 아래 report.md, data/, figures/, logs/에 저장한다. 각 Figure를 생성하는 코드는 src/visualizeSimulation.m 하나다.

- [src 이동 후 시험](2026-10-05_011406_010/report.md): 뱅크각 3개 PASS. main에서 Figure 6개·실행 결과 3개·표적 속력 80을 확인했다. 검증 실행은 Figure를 새로 저장하지 않았다.

