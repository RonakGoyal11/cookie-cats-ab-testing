-- ============================================================
-- COOKIE CATS A/B TEST
-- TREATMENT EFFECT AND LIFT
-- ============================================================

WITH group_metrics AS (
    SELECT
        version,
        COUNT(*) AS total_players,
        AVG(retention_1_flag::NUMERIC) AS retention_1_rate,
        AVG(retention_7_flag::NUMERIC) AS retention_7_rate,

        AVG(sum_gamerounds::NUMERIC)
            FILTER (WHERE is_extreme_outlier = FALSE)
            AS avg_rounds_without_outlier,

        PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY sum_gamerounds)
            AS median_rounds

    FROM analytics.cookie_cats_analysis
    GROUP BY version
),

control AS (
    SELECT *
    FROM group_metrics
    WHERE version = 'gate_30'
),

treatment AS (
    SELECT *
    FROM group_metrics
    WHERE version = 'gate_40'
)

SELECT
    ROUND(control.retention_1_rate * 100, 2)
        AS control_day_1_pct,

    ROUND(treatment.retention_1_rate * 100, 2)
        AS treatment_day_1_pct,

    ROUND(
        (treatment.retention_1_rate - control.retention_1_rate) * 100,
        2
    ) AS day_1_absolute_lift_pp,

    ROUND(
        (
            treatment.retention_1_rate
            / control.retention_1_rate
            - 1
        ) * 100,
        2
    ) AS day_1_relative_lift_pct,

    ROUND(control.retention_7_rate * 100, 2)
        AS control_day_7_pct,

    ROUND(treatment.retention_7_rate * 100, 2)
        AS treatment_day_7_pct,

    ROUND(
        (treatment.retention_7_rate - control.retention_7_rate) * 100,
        2
    ) AS day_7_absolute_lift_pp,

    ROUND(
        (
            treatment.retention_7_rate
            / control.retention_7_rate
            - 1
        ) * 100,
        2
    ) AS day_7_relative_lift_pct,

    ROUND(control.avg_rounds_without_outlier, 2)
        AS control_avg_rounds,

    ROUND(treatment.avg_rounds_without_outlier, 2)
        AS treatment_avg_rounds,

    ROUND(
        treatment.avg_rounds_without_outlier
        - control.avg_rounds_without_outlier,
        2
    ) AS average_round_difference,

    control.median_rounds AS control_median_rounds,
    treatment.median_rounds AS treatment_median_rounds

FROM control
CROSS JOIN treatment;
