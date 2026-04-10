-- ============================================
-- Data Cleaning Script
-- Author: Edem Uyimeabasi Linus
-- Description: Common data quality fixes
-- ============================================

-- 1. Find and remove duplicate records
WITH duplicates AS (
    SELECT
        id,
        ROW_NUMBER() OVER (
            PARTITION BY email, full_name
            ORDER BY created_at DESC
        ) AS row_num
    FROM customers
)
DELETE FROM customers
WHERE id IN (
    SELECT id FROM duplicates WHERE row_num > 1
);

-- 2. Standardise phone number format
UPDATE customers
SET phone = REGEXP_REPLACE(
    TRIM(phone),
    '[^0-9+]', '', 'g'
);

-- 3. Handle NULL values with sensible defaults
UPDATE sales_data
SET
    region    = COALESCE(region, 'Unknown'),
    category  = COALESCE(category, 'Uncategorised'),
    quantity  = COALESCE(quantity, 0);

-- 4. Flag outliers in numeric columns
SELECT
    id,
    revenue,
    AVG(revenue) OVER ()                        AS mean_revenue,
    STDDEV(revenue) OVER ()                     AS std_revenue,
    CASE
        WHEN ABS(revenue - AVG(revenue) OVER ())
             > 3 * STDDEV(revenue) OVER ()
        THEN 'Outlier'
        ELSE 'Normal'
    END AS outlier_flag
FROM transactions;
