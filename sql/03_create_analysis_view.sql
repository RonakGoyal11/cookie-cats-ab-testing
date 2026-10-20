-- ============================================================
-- COOKIE CATS A/B TEST
-- ANALYSIS-READY VIEW
-- ============================================================

-- Keep analysis objects separate from the raw imported data
CREATE SCHEMA IF NOT EXISTS analytics;

-- Create an analysis-ready view without modifying the raw table
CREATE OR REPLACE VIEW analytics.cookie_cats_analysis AS
SELECT
    c.userid,
    c.version,

    CASE
        WHEN c.version = 'gate_30' THEN 'Control'
        WHEN c.version = 'gate_40' THEN 'Treatment'
    END AS experiment_group,

    c.sum_gamerounds,
    c.retention_1,
    c.retention_7,

    -- Numeric versions make calculations easier later
    c.retention_1::INTEGER AS retention_1_flag,
    c.retention_7::INTEGER AS retention_7_flag,

    -- Zero rounds are valid but useful to identify separately
    CASE
        WHEN c.sum_gamerounds = 0 THEN TRUE
        ELSE FALSE
    END AS is_zero_round_player,

    -- Flag the isolated maximum instead of deleting it
    CASE
        WHEN c.sum_gamerounds = maximum.max_rounds THEN TRUE
        ELSE FALSE
    END AS is_extreme_outlier

FROM raw.cookie_cats AS c

CROSS JOIN (
    SELECT MAX(sum_gamerounds) AS max_rounds
    FROM raw.cookie_cats
) AS maximum;
