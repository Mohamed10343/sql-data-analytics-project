WITH customer_spending AS 
(
    SELECT
    c.customer_key,
    SUM(s.sales_amount) AS total_spending,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan
    FROM gold.fact_sales s  
    LEFT JOIN gold.dim_customers c  
    ON s.customer_key = c.customer_key
    GROUP BY c.customer_key
)

SELECT
customer_segments,
COUNT(customer_key)AS total_customers
FROM(
    SELECT
    customer_key,
    total_spending,
    lifespan,
    CASE 
        WHEN lifespan > 12 AND total_spending > 5000 THEN 'VIP'
        WHEN lifespan > 12 AND total_spending <= 5000 THEN 'Regular'
        ELSE 'New'
    END customer_segments
    FROM customer_spending)t 
GROUP BY customer_segments
ORDER BY total_customers DESC