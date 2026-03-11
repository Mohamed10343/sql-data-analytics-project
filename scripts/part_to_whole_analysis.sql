WITH catagory_sales AS
(
SELECT
p.category,
SUM(s.sales_amount) AS total_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p   
ON s.product_key =p.product_key
GROUP BY p.category
)

SELECT
category,
total_sales,
SUM(total_sales) OVER() AS overall_sales,
CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER()) * 100 ,2) , '%') AS perecentage_of_total
FROM catagory_sales