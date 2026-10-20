-- Create a separate database schema for untouched source data
CREATE SCHEMA IF NOT EXISTS raw;

-- Create the table that will store the Cookie Cats experiment dataset
CREATE TABLE IF NOT EXISTS raw.cookie_cats (
    userid INTEGER PRIMARY KEY,
    version VARCHAR(10) NOT NULL
        CHECK (version IN ('gate_30', 'gate_40')),
    sum_gamerounds INTEGER NOT NULL
        CHECK (sum_gamerounds >= 0),
    retention_1 BOOLEAN NOT NULL,
    retention_7 BOOLEAN NOT NULL
);
