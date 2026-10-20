-- ============================================================
-- COOKIE CATS A/B TEST
-- EXPERIMENT KPI SUMMARY
-- ============================================================

SELECT
    version,
    experiment_group,

    COUNT(*) AS total_players,

    SUM(retention_1_flag) AS retained_day_1,
    ROUND(AVG(retention_1_flag) * 100, 2) AS retention_1_pct,

    SUM(retention_7_flag) AS retained_day_7,
    ROUND(AVG(retention_7_flag) * 100, 2) AS retention_7_pct,

    ROUND(AVG(sum_gamerounds), 2) AS avg_rounds_with_outlier,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY sum_gamerounds)::NUMERIC,
        2
    ) AS median_rounds,

    ROUND(
        AVG(sum_gamerounds)
        FILTER (WHERE is_extreme_outlier = FALSE),
        2
    ) AS avg_rounds_without_outlier,

    COUNT(*) FILTER (
        WHERE is_zero_round_player = TRUE
    ) AS zero_round_players

FROM analytics.cookie_cats_analysis

GROUP BY
    version,
    experiment_group

ORDER BY version;
