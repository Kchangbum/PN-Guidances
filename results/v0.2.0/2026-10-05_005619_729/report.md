# v0.2.0 development simulation

Run ID (Asia/Seoul): 2026-10-05_005619_729

MATLAB: 25.2.0.3150157 (R2025b) Update 4

Executed existing main.m and visualizeSimulation.m. Source snapshot: data/source/.

Status: execution and figure export completed; guidance accuracy is not certified.

## Conditions

Target speed: 80 m/s. Target lateral acceleration: +1 m/s². APN target acceleration input: +1 m/s². Missile speed: 100 m/s. Navigation gain: 3. Command step: 0.1 s.

## Figures

- [XY Trajectories](figures/01_xy_trajectories.png)
- [Heading](figures/02_heading.png)
- [Range](figures/03_range.png)
- [LOS](figures/04_los.png)
- [LOS](figures/05_bank_command.png)
- [LOS](figures/06_lateral_acceleration.png)

## Closest saved sample

| Guidance | Time (s) | Range (m) |
|---|---|---|
| TPN | 47.800000 | 1.940771610 |
| PPN | 44.300000 | 0.677426161 |
| APN | 43.400000 | 5.330144574 |

These are sampled distances, not continuous closest-approach or hit verdicts.

Historical figures: [legacy report](../../legacy_2026-10-02/report.md).
