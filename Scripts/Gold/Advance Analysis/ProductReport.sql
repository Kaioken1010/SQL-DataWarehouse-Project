/* 
========================================================
Product Report
========================================================
Purpose:
	- This report consolidates key product metrics and behviors.

Highlights:
	1. Gather essential fields such as product name, category, subcategory and cost.
	2. Segments products by revenue to identify High-Performers, Mid-range, or Low-Performers.
	3. Aggregates product level metrics:
		- total orders
		- total sales
		- total quantity sold 
		- total customers (unique)
		- lifespan (in months)
	4. Caculate valuable KPIs:
		- recency (months since last sale)
		- average order revenue (AOR)
		- average monthly revenue
==============================================================================================
*/
CREATE VIEW gold.product_report as 
WITH base_prod AS (
SELECT
	f.order_number,
	f.order_date,
	f.customer_key,
	f.quantity,
	f.price,
	f.sales,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
)

, product_aggr as (
SELECT 
	product_name,
	price,
	SUM(quantity) as quant_sold, 
	SUM(sales) as total_sales,
	COUNT(*) as total_orders,
	COUNT(DISTINCT customer_key) as total_customer,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as lifespan,
	DATEDIFF(MONTH, MIN(order_date), GETDATE()) as recency
FROM base_prod
GROUP BY product_name, price
)

SELECT 
	product_name, 
	price,
	quant_sold,
	total_sales,
	CASE 
		WHEN total_sales < 250000 THEN 'Low-Performer'
		WHEN total_sales BETWEEN 250000 AND 650000 THEN 'Mid Range'
		ELSE 'High-Performer'
	END as prod_segment,
	total_orders,
	total_customer,
	lifespan,
	recency,
	--Average order revenue 
	CASE WHEN total_orders = 0 THEN 0
		 ELSE ROUND((CAST(total_sales as FLOAT)/ total_orders), 2)
	END as avg_order_rev,
	--Average monthly revenue
	CASE WHEN lifespan = 0 THEN total_sales
		 ELSE ROUND((CAST(total_sales as FLOAT)/ lifespan), 2)
	END as avg_monthly_rev
FROM product_aggr
