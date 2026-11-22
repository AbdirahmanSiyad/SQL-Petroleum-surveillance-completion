/* ==============================================================================
   DDL & Batch Loading Script: Volve Production Surveillance Ingestion
   Sources:
     - /Users/abdirahmanosmansiyad/Desktop/Petroelum_surveillance peoject 1/volve_daily_production_all_rows_clean.csv
     - /Users/abdirahmanosmansiyad/Desktop/Petroelum_surveillance peoject 1/volve_monthly_production_all_rows_clean.csv
   ============================================================================== */

SET @batch_start = NOW(6);
SET @step_start  = NOW(6);

CREATE DATABASE IF NOT EXISTS petroleum_surveillance
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE petroleum_surveillance;

DROP TEMPORARY TABLE IF EXISTS tmp_log;
CREATE TEMPORARY TABLE tmp_log (
    log_id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    logged_at     DATETIME(6) NOT NULL,
    step_name     VARCHAR(100) NOT NULL,
    status        VARCHAR(20) NOT NULL,
    rows_affected BIGINT NULL,
    duration_sec  DECIMAL(10, 3) NULL,
    details       VARCHAR(500) NULL
);

INSERT INTO tmp_log (logged_at, step_name, status, rows_affected, duration_sec, details)
VALUES (
    NOW(6),
    'INIT_DATABASE',
    'SUCCESS',
    NULL,
    ROUND(TIMESTAMPDIFF(MICROSECOND, @step_start, NOW(6)) / 1000000, 3),
    'Ensured `petroleum_surveillance` database exists and initialized `tmp_log`.'
);

-- ==============================================================================
-- 1. DDL: Recreate Tables with Composite Primary Keys
-- ==============================================================================
SET @step_start = NOW(6);

DROP TABLE IF EXISTS volve_production_daily;
CREATE TABLE volve_production_daily (
    dateprd                  DATE NOT NULL,
    well_bore_code           VARCHAR(40) NULL,
    npd_well_bore_code       INT NOT NULL,
    npd_well_bore_name       VARCHAR(40) NULL,
    npd_field_code           INT NULL,
    npd_field_name           VARCHAR(40) NULL,
    npd_facility_code        INT NULL,
    npd_facility_name        VARCHAR(60) NULL,
    on_stream_hrs            DOUBLE NULL,
    avg_downhole_pressure    DOUBLE NULL,
    avg_downhole_temperature DOUBLE NULL,
    avg_dp_tubing            DOUBLE NULL,
    avg_annulus_press        DOUBLE NULL,
    avg_choke_size_p         DOUBLE NULL,
    avg_choke_uom            VARCHAR(20) NULL,
    avg_whp_p                DOUBLE NULL,
    avg_wht_p                DOUBLE NULL,
    dp_choke_size            DOUBLE NULL,
    bore_oil_vol             DOUBLE NULL,
    bore_gas_vol             DOUBLE NULL,
    bore_wat_vol             DOUBLE NULL,
    bore_wi_vol              DOUBLE NULL,
    flow_kind                VARCHAR(30) NULL,
    well_type                VARCHAR(20) NULL,
    loaded_at                DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (npd_well_bore_code, dateprd),
    INDEX idx_daily_well_name_date (npd_well_bore_name, dateprd),
    INDEX idx_daily_dateprd (dateprd),
    INDEX idx_daily_flow_kind (flow_kind)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS volve_production_monthly;
CREATE TABLE volve_production_monthly (
    wellbore_name  VARCHAR(40) NULL,
    npd_code       INT NOT NULL,
    year           INT NULL,
    month          INT NULL,
    report_date    DATE NOT NULL,
    on_stream_hrs  DOUBLE NULL,
    oil_sm3        DOUBLE NULL,
    gas_sm3        DOUBLE NULL,
    water_sm3      DOUBLE NULL,
    gi_sm3         DOUBLE NULL,
    wi_sm3         DOUBLE NULL,
    loaded_at      DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (npd_code, report_date),
    INDEX idx_monthly_well_date (wellbore_name, report_date),
    INDEX idx_monthly_ym (year, month)
) ENGINE=InnoDB;

INSERT INTO tmp_log (logged_at, step_name, status, rows_affected, duration_sec, details)
VALUES (
    NOW(6),
    'DDL_TABLES',
    'SUCCESS',
    NULL,
    ROUND(TIMESTAMPDIFF(MICROSECOND, @step_start, NOW(6)) / 1000000, 3),
    'Recreated `volve_production_daily` and `volve_production_monthly` with composite primary keys.'
);

-- ==============================================================================
-- 2. Session Local Infile Configuration
-- ==============================================================================
SET @step_start = NOW(6);
SET GLOBAL local_infile = 1;

INSERT INTO tmp_log (logged_at, step_name, status, rows_affected, duration_sec, details)
VALUES (
    NOW(6),
    'SET_LOCAL_INFILE',
    'SUCCESS',
    NULL,
    ROUND(TIMESTAMPDIFF(MICROSECOND, @step_start, NOW(6)) / 1000000, 3),
    CONCAT('Global local_infile value: ', @@GLOBAL.local_infile)
);

-- ==============================================================================
-- 3. Truncate & Load: volve_production_daily
-- ==============================================================================
SET @step_start = NOW(6);
TRUNCATE TABLE volve_production_daily;

LOAD DATA LOCAL INFILE '/Users/abdirahmanosmansiyad/Desktop/Petroelum_surveillance peoject 1/volve_daily_production_all_rows_clean.csv'
INTO TABLE volve_production_daily
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @dateprd,
    @well_bore_code,
    @npd_well_bore_code,
    @npd_well_bore_name,
    @npd_field_code,
    @npd_field_name,
    @npd_facility_code,
    @npd_facility_name,
    @on_stream_hrs,
    @avg_downhole_pressure,
    @avg_downhole_temperature,
    @avg_dp_tubing,
    @avg_annulus_press,
    @avg_choke_size_p,
    @avg_choke_uom,
    @avg_whp_p,
    @avg_wht_p,
    @dp_choke_size,
    @bore_oil_vol,
    @bore_gas_vol,
    @bore_wat_vol,
    @bore_wi_vol,
    @flow_kind,
    @well_type
)
SET
    dateprd                  = NULLIF(TRIM(@dateprd), ''),
    well_bore_code           = NULLIF(TRIM(@well_bore_code), ''),
    npd_well_bore_code       = NULLIF(TRIM(@npd_well_bore_code), ''),
    npd_well_bore_name       = NULLIF(TRIM(@npd_well_bore_name), ''),
    npd_field_code           = NULLIF(TRIM(@npd_field_code), ''),
    npd_field_name           = NULLIF(TRIM(@npd_field_name), ''),
    npd_facility_code        = NULLIF(TRIM(@npd_facility_code), ''),
    npd_facility_name        = NULLIF(TRIM(@npd_facility_name), ''),
    on_stream_hrs            = NULLIF(TRIM(@on_stream_hrs), ''),
    avg_downhole_pressure    = NULLIF(TRIM(@avg_downhole_pressure), ''),
    avg_downhole_temperature = NULLIF(TRIM(@avg_downhole_temperature), ''),
    avg_dp_tubing            = NULLIF(TRIM(@avg_dp_tubing), ''),
    avg_annulus_press        = NULLIF(TRIM(@avg_annulus_press), ''),
    avg_choke_size_p         = NULLIF(TRIM(@avg_choke_size_p), ''),
    avg_choke_uom            = NULLIF(TRIM(@avg_choke_uom), ''),
    avg_whp_p                = NULLIF(TRIM(@avg_whp_p), ''),
    avg_wht_p                = NULLIF(TRIM(@avg_wht_p), ''),
    dp_choke_size            = NULLIF(TRIM(@dp_choke_size), ''),
    bore_oil_vol             = NULLIF(TRIM(@bore_oil_vol), ''),
    bore_gas_vol             = NULLIF(TRIM(@bore_gas_vol), ''),
    bore_wat_vol             = NULLIF(TRIM(@bore_wat_vol), ''),
    bore_wi_vol              = NULLIF(TRIM(@bore_wi_vol), ''),
    flow_kind                = NULLIF(TRIM(@flow_kind), ''),
    well_type                = NULLIF(TRIM(REPLACE(@well_type, '\r', '')), ''),
    loaded_at                = NOW(6);

SET @daily_rows = (SELECT COUNT(*) FROM volve_production_daily);

INSERT INTO tmp_log (logged_at, step_name, status, rows_affected, duration_sec, details)
VALUES (
    NOW(6),
    'LOAD_DAILY_PRODUCTION',
    'SUCCESS',
    @daily_rows,
    ROUND(TIMESTAMPDIFF(MICROSECOND, @step_start, NOW(6)) / 1000000, 3),
    'Truncated and loaded `volve_production_daily` with NULL handling on empty values.'
);

-- ==============================================================================
-- 4. Truncate & Load: volve_production_monthly
-- ==============================================================================
SET @step_start = NOW(6);
TRUNCATE TABLE volve_production_monthly;

LOAD DATA LOCAL INFILE '/Users/abdirahmanosmansiyad/Desktop/Petroelum_surveillance peoject 1/volve_monthly_production_all_rows_clean.csv'
INTO TABLE volve_production_monthly
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @wellbore_name,
    @npd_code,
    @year,
    @month,
    @report_date,
    @on_stream_hrs,
    @oil_sm3,
    @gas_sm3,
    @water_sm3,
    @gi_sm3,
    @wi_sm3
)
SET
    wellbore_name = NULLIF(TRIM(@wellbore_name), ''),
    npd_code      = NULLIF(TRIM(@npd_code), ''),
    year          = NULLIF(TRIM(@year), ''),
    month         = NULLIF(TRIM(@month), ''),
    report_date   = NULLIF(TRIM(@report_date), ''),
    on_stream_hrs = NULLIF(TRIM(@on_stream_hrs), ''),
    oil_sm3       = NULLIF(TRIM(@oil_sm3), ''),
    gas_sm3       = NULLIF(TRIM(@gas_sm3), ''),
    water_sm3     = NULLIF(TRIM(@water_sm3), ''),
    gi_sm3        = NULLIF(TRIM(@gi_sm3), ''),
    wi_sm3        = NULLIF(TRIM(REPLACE(@wi_sm3, '\r', '')), ''),
    loaded_at     = NOW(6);

SET @monthly_rows = (SELECT COUNT(*) FROM volve_production_monthly);

INSERT INTO tmp_log (logged_at, step_name, status, rows_affected, duration_sec, details)
VALUES (
    NOW(6),
    'LOAD_MONTHLY_PRODUCTION',
    'SUCCESS',
    @monthly_rows,
    ROUND(TIMESTAMPDIFF(MICROSECOND, @step_start, NOW(6)) / 1000000, 3),
    'Truncated and loaded `volve_production_monthly` with NULL handling on empty values.'
);

-- ==============================================================================
-- 5. Batch Summary & Single Consolidated Result Output
-- ==============================================================================
INSERT INTO tmp_log (logged_at, step_name, status, rows_affected, duration_sec, details)
VALUES (
    NOW(6),
    'BATCH_COMPLETE',
    'SUCCESS',
    (@daily_rows + @monthly_rows),
    ROUND(TIMESTAMPDIFF(MICROSECOND, @batch_start, NOW(6)) / 1000000, 3),
    CONCAT('Total rows loaded: ', (@daily_rows + @monthly_rows), ' (Daily: ', @daily_rows, ', Monthly: ', @monthly_rows, ').')
);

SELECT
    log_id,
    logged_at,
    step_name,
    status,
    rows_affected,
    duration_sec,
    details
FROM tmp_log
ORDER BY log_id;

DROP TEMPORARY TABLE IF EXISTS tmp_log;


USE petroleum_surveillance;

SELECT 'volve_production_daily' AS table_name, COUNT(*) AS total_rows
FROM volve_production_daily
UNION ALL
SELECT 'volve_production_monthly' AS table_name, COUNT(*) AS total_rows
FROM volve_production_monthly;



