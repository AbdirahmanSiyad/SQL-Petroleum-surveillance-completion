-- ============================================================================
-- Project:     01_volve_production_shut_in_surveillance
-- Script:      isolate_shut_in_buildup_events.sql
-- Purpose:     Detect shut-in periods and quantify multi-day pressure build-up
--              windows per wellbore for Pressure Transient Analysis (PTA)
--              screening.
-- Key Logic:   Evaluates LAG() across ordered well dates BEFORE filtering
--              shut-in rows so separate shut-in events stay distinct.
-- ============================================================================

USE petroleum_surveillance;

-- Step 1: Filter valid downhole pressure records and flag daily shut-in states per wellbore
WITH StateFlag AS (
    SELECT
        src.npd_well_bore_name AS well_id,
        DATE(src.record_date) AS record_date,
        src.avg_downhole_pressure AS downhole_pressure,
        src.bore_oil_vol AS oil_rate,
        -- Flag shut-in when oil rate is near zero (< 5.0) or choke opening is closed (0); COALESCE prevents NULL evaluation traps
        CASE
            WHEN COALESCE(src.bore_oil_vol, 0) < 5.0 OR COALESCE(src.avg_choke_size_p, 0) = 0 THEN 1
            ELSE 0
        END AS is_shut_in
    FROM (
        SELECT
            npd_well_bore_name,
            dateprd AS record_date,
            avg_downhole_pressure,
            bore_oil_vol,
            avg_choke_size_p
        FROM volve_production_daily
        -- Pressure Transient Analysis (PTA) build-up screening requires downhole pressure measurements
        WHERE avg_downhole_pressure IS NOT NULL
    ) AS src
),

-- Step 2: Detect transition into a shut-in event across the full ordered timeline per well
EventTransitions AS (
    SELECT
        well_id,
        record_date,
        downhole_pressure,
        oil_rate,
        is_shut_in,
        -- Compute LAG across all consecutive rows per well BEFORE filtering to avoid merging separate shut-in periods
        CASE
            WHEN is_shut_in = 1
             AND LAG(is_shut_in, 1, 0) OVER (PARTITION BY well_id ORDER BY record_date) = 0
            THEN 1
            ELSE 0
        END AS new_event
    FROM StateFlag
),

-- Step 3: Isolate shut-in days and assign a sequential event ID per well via cumulative sum
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

-- Step 4: Aggregate multi-day shut-in build-up windows and quantify pressure recovery
SELECT
    well_id,
    shut_in_id,
    MIN(record_date) AS start_date,
    MAX(record_date) AS end_date,
    DATEDIFF(MAX(record_date), MIN(record_date)) AS duration_days,
    -- MIN/MAX pressure acts as a build-up screen; verify monotonic rise in PTA software for radial flow analysis
    MIN(downhole_pressure) AS p_wf_initial,
    MAX(downhole_pressure) AS p_ws_final,
    ROUND(MAX(downhole_pressure) - MIN(downhole_pressure), 4) AS total_buildup
FROM ShutInOnly
GROUP BY well_id, shut_in_id
-- Keep multi-day events (>= 1 day) to filter out single-day transients or brief operational blips
HAVING duration_days >= 1
ORDER BY well_id, start_date;
