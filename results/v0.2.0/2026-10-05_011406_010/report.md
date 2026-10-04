# Bank command test

Version: v0.2.0 development

Run ID (Asia/Seoul): 2026-10-05_011406_010

MATLAB: 25.2.0.3150157 (R2025b) Update 4

Scope: zero command and +/-45 degree limits only.

Tolerance: 1e-10 rad. No guidance performance verdict or simulation figures.

| Test | Input (m/s^2) | Expected (deg) | Actual (deg) | Verdict |
|---|---|---|---|---|
| Zero command | 0 | 0 | 0 | PASS |
| Upper limit | 1000 | 45 | 45 | PASS |
| Lower limit | -1000 | -45 | -45 | PASS |

Historical figures: ../../legacy_2026-10-02/report.md
