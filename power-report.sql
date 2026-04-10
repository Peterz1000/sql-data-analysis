-- ============================================
-- Industrial Equipment Downtime Report
-- Author: Edem Uyimeabasi Linus
-- Inspired by: Olam Agri electrical internship
-- Description: Track sensor-reported equipment
-- faults and calculate downtime by machine
-- ============================================

-- 1. Total downtime hours by machine (monthly)
SELECT
    machine_id,
    machine_name,
    DATE_TRUNC('month', fault_timestamp) AS month,
    COUNT(fault_id)                       AS total_faults,
    SUM(downtime_minutes) / 60.0          AS downtime_hours
FROM equipment_faults
WHERE fault_type IN ('power_imbalance', 'motor_failure', 'sensor_error')
GROUP BY 1, 2, 3
ORDER BY downtime_hours DESC;

-- 2. Most frequent fault types
SELECT
    fault_type,
    COUNT(*)                              AS occurrences,
    ROUND(AVG(downtime_minutes), 1)       AS avg_downtime_mins,
    SUM(downtime_minutes)                 AS total_downtime_mins
FROM equipment_faults
GROUP BY fault_type
ORDER BY occurrences DESC;

-- 3. Mean time between failures (MTBF) per machine
WITH fault_gaps AS (
    SELECT
        machine_id,
        fault_timestamp,
        LAG(fault_timestamp) OVER (
            PARTITION BY machine_id
            ORDER BY fault_timestamp
        ) AS prev_fault
    FROM equipment_faults
)
SELECT
    machine_id,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (fault_timestamp - prev_fault)) / 3600), 2
    ) AS avg_hours_between_failures
FROM fault_gaps
WHERE prev_fault IS NOT NULL
GROUP BY machine_id
ORDER BY avg_hours_between_failures ASC;
