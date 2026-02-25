DROP TABLE IF EXISTS purchases;

CREATE TABLE purchases (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    revenue NUMERIC,
    discount NUMERIC,
    refund NUMERIC,
    country VARCHAR(50)
);

INSERT INTO purchases VALUES
(1, 101, '2024-01-05', 120, 10, 0, 'Germany'),
(2, 102, '2024-01-07', 200, 0, 0, 'France'),
(3, 103, '2024-02-01', 150, 15, 0, 'Germany'),
(4, 101, '2024-02-10', 300, 0, 50, 'Germany'),
(5, 104, '2024-03-03', 250, 25, 0, 'Spain'),
(6, 105, '2024-03-15', 180, 0, 0, 'France'),
(7, 102, '2024-04-02', 400, 40, 0, 'France'),
(8, 106, '2024-04-10', 220, 0, 20, 'Italy'),
(9, 103, '2024-05-05', 130, 10, 0, 'Germany'),
(10, 107, '2024-05-18', 500, 50, 0, 'Spain');

SELECT SUM(revenue) AS total_revenue
FROM purchases;

SELECT SUM(revenue - discount - refund) AS net_revenue
FROM purchases;

SELECT 
    SUM(revenue - discount - refund) / NULLIF(COUNT(order_id), 0) AS avg_order_value
FROM purchases;

SELECT 
    DATE_TRUNC('month', order_date) AS month
    , SUM(revenue - discount - refund) AS monthly_net_revenue
FROM purchases
GROUP BY month
ORDER BY month;

SELECT 
    country
    , SUM(revenue - discount - refund) AS net_revenue
FROM purchases
GROUP BY country
ORDER BY net_revenue DESC;

SELECT 
    customer_id
    , SUM(revenue - discount - refund) AS total_spent
FROM purchases
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 5;

SELECT 
    round(SUM(refund) * 100.0 / NULLIF(SUM(revenue), 0), 2) AS refund_rate_percent
FROM purchases;

SELECT 
    country
    , SUM(revenue - discount - refund) AS country_net_revenue
    , ROUND( SUM(revenue - discount - refund) * 100.0 
    / NULLIF(SUM(SUM(revenue - discount - refund)) OVER (), 0), 2) AS revenue_share_percent
FROM purchases
GROUP BY country
ORDER BY revenue_share_percent DESC;

WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month
        , SUM(revenue - discount - refund) AS net_revenue
    FROM purchases
    GROUP BY month
)
SELECT 
    month
    , net_revenue
    , SUM(net_revenue) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_revenue
FROM monthly_revenue
ORDER BY month;

SELECT 
    customer_id
    , SUM(revenue - discount - refund) AS total_net_revenue
    , ROUND(SUM(revenue - discount - refund) * 100.0 
    		/ SUM(SUM(revenue - discount - refund)) OVER (), 2
    ) AS revenue_contribution_percent
FROM purchases
GROUP BY customer_id
ORDER BY revenue_contribution_percent DESC
LIMIT 5;
