# Executive Summary: Cookie Cats A/B Testing Analysis

## Objective

This project evaluated whether moving the first progression gate in Cookie Cats from level 30 to level 40 improved player retention and engagement.

## Experiment Design

- Control group: gate_30
- Treatment group: gate_40
- Total players: 90,189
- Primary metric: Day 7 retention
- Secondary metrics: Day 1 retention and total game rounds

## Key Findings

The treatment group did not improve player behaviour.

Day 1 retention decreased from 44.82% to 44.23%, a decline of 0.59 percentage points. This result was not statistically significant at the 5% level.

Day 7 retention decreased from 19.02% to 18.20%, a decline of 0.82 percentage points. This result was statistically significant, with a p-value of 0.0016.

Game-round engagement was nearly unchanged. After excluding one extreme outlier from the engagement average, the control group averaged 51.34 rounds and the treatment group averaged 51.30 rounds. The Mann-Whitney U test did not show a statistically significant engagement difference at the 5% level, and the effect size was negligible.

## Experiment Health

The experiment showed a Sample Ratio Mismatch warning under an assumed 50/50 allocation split. The SRM p-value was 0.0086.

This does not automatically invalidate the outcome analysis, but it means the assignment or logging process should be reviewed before using the result as final production evidence.

## Recommendation

Do not roll out gate_40.

The treatment reduced the primary metric, Day 7 retention, without producing a meaningful engagement improvement. The current evidence supports keeping the gate at level 30.

## Next Step

Review the intended traffic allocation, audit assignment logs, and rerun the experiment if the allocation imbalance cannot be explained.
