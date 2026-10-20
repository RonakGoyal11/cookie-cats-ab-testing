-- ============================================================
-- COOKIE CATS A/B TEST
-- POWER BI REPORTING VIEWS
-- ============================================================


-- ------------------------------------------------------------
-- 1. PLAYER-LEVEL DETAIL VIEW
-- Used for filters, distributions and detailed visuals
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW analytics.pbi_player_detail AS
SELECT
    userid AS player_id,
    version,
    experiment_group,
    sum_gamerounds,

    -- The extreme outlier becomes NULL only in this analysis column.
    -- The original number remains available in sum_gamerounds.
    CASE
        WHEN is_extreme_outlier = FALSE
        THEN sum_gamerounds
        ELSE NULL
    END AS analysis_gamerounds,

    retention_1,
    retention_7,
    retention_1_flag,
    retention_7_flag,

    CASE
        WHEN retention_1 = TRUE THEN 'Returned'
        ELSE 'Did Not Return'
    END AS day_1_status,

    CASE
        WHEN retention_7 = TRUE THEN 'Returned'
        ELSE 'Did Not Return'
    END AS day_7_status,

    CASE
        WHEN sum_gamerounds = 0 THEN '0 rounds'
        WHEN sum_gamerounds BETWEEN 1 AND 10 THEN '1 to 10'
        WHEN sum_gamerounds BETWEEN 11 AND 50 THEN '11 to 50'
        WHEN sum_gamerounds BETWEEN 51 AND 100 THEN '51 to 100'
        WHEN sum_gamerounds BETWEEN 101 AND 500 THEN '101 to 500'
        ELSE '501 or more'
    END AS engagement_band,

    is_zero_round_player,
    is_extreme_outlier

FROM analytics.cookie_cats_analysis;


-- ------------------------------------------------------------
-- 2. EXPERIMENT KPI SUMMARY
-- Used for KPI cards and group comparisons
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW analytics.pbi_experiment_summary AS
SELECT
    version,
    experiment_group,

    COUNT(*) AS total_players,

    SUM(retention_1_flag) AS retained_day_1,

    ROUND(
        AVG(retention_1_flag::NUMERIC) * 100,
        4
    ) AS retention_1_pct,

    SUM(retention_7_flag) AS retained_day_7,

    ROUND(
        AVG(retention_7_flag::NUMERIC) * 100,
        4
    ) AS retention_7_pct,

    ROUND(
        AVG(sum_gamerounds::NUMERIC),
        2
    ) AS avg_rounds_with_outlier,

    ROUND(
        AVG(sum_gamerounds::NUMERIC)
        FILTER (
            WHERE is_extreme_outlier = FALSE
        ),
        2
    ) AS avg_rounds_without_outlier,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY sum_gamerounds
        )::NUMERIC,
        2
    ) AS median_rounds,

    COUNT(*) FILTER (
        WHERE is_zero_round_player = TRUE
    ) AS zero_round_players,

    COUNT(*) FILTER (
        WHERE is_extreme_outlier = TRUE
    ) AS extreme_outliers

FROM analytics.cookie_cats_analysis

GROUP BY
    version,
    experiment_group;


-- ------------------------------------------------------------
-- 3. RETENTION-PATTERN SUMMARY
-- Used to show how users behaved across both retention periods
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW analytics.pbi_retention_patterns AS

WITH player_patterns AS (
    SELECT
        version,
        experiment_group,

        CASE
            WHEN retention_1 = TRUE
                 AND retention_7 = TRUE
                THEN 'Returned Day 1 and Day 7'

            WHEN retention_1 = TRUE
                 AND retention_7 = FALSE
                THEN 'Returned Day 1 only'

            WHEN retention_1 = FALSE
                 AND retention_7 = TRUE
                THEN 'Returned Day 7 only'

            ELSE 'Did not return'
        END AS retention_pattern

    FROM analytics.cookie_cats_analysis
),

pattern_counts AS (
    SELECT
        version,
        experiment_group,
        retention_pattern,
        COUNT(*) AS player_count

    FROM player_patterns

    GROUP BY
        version,
        experiment_group,
        retention_pattern
)

SELECT
    version,
    experiment_group,
    retention_pattern,
    player_count,

    ROUND(
        player_count::NUMERIC
        / SUM(player_count) OVER (
            PARTITION BY version
        )
        * 100,
        2
    ) AS group_percentage

FROM pattern_counts;
