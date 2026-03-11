/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================

IF OBJECT_ID('gold.report_products','V') IS NOT NULL
    DROP VIEW gold.report_products;
GO  

CREATE VIEW gold.report_products AS
WITH base_query AS(
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
SELECT
    s.order_number,
    s.customer_key,
    s.order_date,
    s.sales_amount,
    s.quantity,
    s.price,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost
FROM gold.fact_sales s  
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE order_date IS NOT NULL),

product_aggregations AS(
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT customer_key) AS total_customers
FROM base_query
GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost)
/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATEDIFF(MONTH,last_sale_date,GETDATE()) AS recency_in_months,
    CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    -- Average Order Revenue (AOR)
    CASE
        WHEN total_orders = 0 THEN '0'
        ELSE total_sales / total_orders 
    END AS avg_order_revenue
FROM product_aggregations