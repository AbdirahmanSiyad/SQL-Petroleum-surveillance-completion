-- ============================================================================
-- Project:     Volve production surveillance
-- Script:      isolate_shut_in_buildup_events.sql
-- Purpose:     Detect shut-in periods and quantify multi-day pressure build-up
--              windows per wellbore for Pressure Transient Analysis (PTA)
--              screening.
-- Key Logic:   Evaluates LAG() across ordered well dates BEFORE filtering
--              shut-in rows so separate shut-in events stay distinct.
-- ============================================================================

USE petroleum_surveillance;

-- Step 1: Flag daily shut-in states across the full wellbore timeline
WITH StateFlag AS (
    SELECT
        src.npd_well_bore_name AS well_id,
        DATE(src.dateprd) AS record_date,
        src.avg_downhole_pressure AS downhole_pressure,
        src.bore_oil_vol AS oil_rate,
        -- Project screening heuristic: confirm threshold units and NULL semantics before interpreting results.
        -- COALESCE currently treats missing rate or choke values as zero.
        CASE
            WHEN COALESCE(src.bore_oil_vol, 0) < 5.0 OR COALESCE(src.avg_choke_size_p, 0) = 0 THEN 1
            ELSE 0
        END AS is_shut_in
    FROM volve_production_daily AS src
),

-- Keep missing-pressure records in the timeline so they do not hide state transitions.
Timeline AS (
    SELECT
        well_id,
        record_date,
        downhole_pressure,
        oil_rate,
        is_shut_in,
        LAG(is_shut_in, 1, 0) OVER (PARTITION BY well_id ORDER BY record_date) AS previous_is_shut_in,
        LAG(record_date) OVER (PARTITION BY well_id ORDER BY record_date) AS previous_record_date
    FROM StateFlag
),

-- Step 2: Start a new event after a non-shut-in day or a gap in daily records
EventTransitions AS (
    SELECT
        well_id,
        record_date,
        downhole_pressure,
        oil_rate,
        is_shut_in,
        CASE
            WHEN is_shut_in = 1
             AND (
                 previous_is_shut_in = 0
                 OR DATEDIFF(record_date, previous_record_date) > 1
             )
            THEN 1
            ELSE 0
        END AS new_event
    FROM Timeline
),

-- Step 3: Assign event IDs before filtering for available pressure measurements
ShutInOnly AS (
    SELECT
        well_id,
        record_date,
        downhole_pressure,
        oil_rate,
        SUM(new_event) OVER (PARTITION BY well_id ORDER BY record_date) AS shut_in_id
    FROM EventTransitions
    WHERE is_shut_in = 1
)

PressureBearingShutIns AS (
    SELECT
        well_id,
        record_date,
        downhole_pressure,
        oil_rate,
        shut_in_id
    FROM ShutInOnly
    WHERE downhole_pressure IS NOT NULL
)

-- Step 4: Summarize pressure-bearing windows; pressure range is not chronological net recovery
SELECT
    well_id,
    shut_in_id,
    MIN(record_date) AS start_date,
    MAX(record_date) AS end_date,
    DATEDIFF(MAX(record_date), MIN(record_date)) AS duration_days,
    MIN(downhole_pressure) AS min_downhole_pressure,
    MAX(downhole_pressure) AS max_downhole_pressure,
    ROUND(MAX(downhole_pressure) - MIN(downhole_pressure), 4) AS pressure_range
FROM PressureBearingShutIns
GROUP BY well_id, shut_in_id
-- DATEDIFF is elapsed calendar days between pressure observations; >= 1 requires different dates.
HAVING duration_days >= 1
ORDER BY well_id, start_date;
