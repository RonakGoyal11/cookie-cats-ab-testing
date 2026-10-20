-- ============================================================
-- COOKIE CATS A/B TEST
-- DATA QUALITY CHECKS
-- ============================================================

-- 1. Total rows, unique users, and duplicate records
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT userid) AS unique_users,
    COUNT(*) - COUNT(DISTINCT userid) AS duplicate_user_records
FROM raw.cookie_cats;

-- 2. Check for missing values
SELECT
    COUNT(*) FILTER (WHERE userid IS NULL) AS missing_userid,
    COUNT(*) FILTER (WHERE version IS NULL) AS missing_version,
    COUNT(*) FILTER (WHERE sum_gamerounds IS NULL) AS missing_gamerounds,
    COUNT(*) FILTER (WHERE retention_1 IS NULL) AS missing_retention_1,
    COUNT(*) FILTER (WHERE retention_7 IS NULL) AS missing_retention_7
FROM raw.cookie_cats;

-- 3. Validate experiment groups
SELECT
    version,
    COUNT(*) AS number_of_players
FROM raw.cookie_cats
GROUP BY version
ORDER BY version;

-- 4. Check game-round distribution
SELECT
    MIN(sum_gamerounds) AS minimum_rounds,
    MAX(sum_gamerounds) AS maximum_rounds,
    ROUND(AVG(sum_gamerounds), 2) AS average_rounds,
    COUNT(*) FILTER (WHERE sum_gamerounds = 0) AS zero_round_players,
    COUNT(*) FILTER (WHERE sum_gamerounds < 0) AS negative_round_records
FROM raw.cookie_cats;

-- 5. Check for unexpected experiment-group values
SELECT DISTINCT version
FROM raw.cookie_cats
WHERE version NOT IN ('gate_30', 'gate_40')
   OR version IS NULL;
```