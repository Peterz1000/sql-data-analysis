-- ============================================
-- Sales Performance Analysis
-- Author: Edem Uyimeabasi Linus
-- Description: Analyse revenue trends,
-- identify top products and customer segments
-- ============================================

-- 1. Total revenue by month
SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(order_value)                AS total_revenue,
    COUNT(DISTINCT order_id)        AS total_orders,
    ROUND(AVG(order_value), 2)      AS avg_order_value
FROM orders
WHERE order_date >= '2024-01-01'
GROUP BY 1
ORDER BY 1;

-- 2. Top 10 products by revenue
SELECT
    p.product_name,
    SUM(o.order_value)           AS total_revenue,
    COUNT(o.order_id)            AS units_sold,
    ROUND(SUM(o.order_value) /
          COUNT(o.order_id), 2)  AS revenue_per_unit
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 3. Customer segmentation by spend
WITH customer_spend AS (
    SELECT
        customer_id,
        SUM(order_value) AS lifetime_value
    FROM orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN lifetime_value >= 10000 THEN 'High Value'
        WHEN lifetime_value >= 3000  THEN 'Mid Value'
        ELSE 'Low Value'
    END AS segment,
    COUNT(customer_id)       AS customer_count,
    ROUND(AVG(lifetime_value), 2) AS avg_lifetime_value
FROM customer_spend
GROUP BY segment
ORDER BY avg_lifetime_value DESC;

-- 4. Month-over-month revenue growth
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(order_value)                AS revenue
    FROM orders
    GROUP BY 1
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)  AS prev_month,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 2
    ) AS growth_pct
FROM monthly
ORDER BY month;
