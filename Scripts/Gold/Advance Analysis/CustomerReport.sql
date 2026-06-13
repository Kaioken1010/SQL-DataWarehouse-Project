/*
===========================================================================================
Customer report
===========================================================================================
Purpose:
	 - This report consolidates key customer metrics and behaviors

Highlights:
	1. Gather essential fields such as names , ages, and transaction details.
	2. Segement customers into categories (VIP, Regular, New) and age groups.
	3. aggregate customer level metrics:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months)
	4. Caculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend
===========================================================================================
*/

CREATE VIEW gold.customer_report AS
--Base query: retrieving core columns
WITH base_query as (
SELECT 
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales,
	f.quantity,
	c.primary_key as customer_key,
	c.customer_number,
	--c.first_name,
	--c.last_name,
	CONCAT(c.first_name, ' ', c.last_name) as customer_name,
	--c.birthdate,
	DATEDIFF(YEAR, c.birthdate, GETDATE()) as age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.primary_key = f.customer_key
WHERE f.order_date IS NOT NULL
)

, customer_aggregation as (
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) as total_order,
	SUM(sales) as total_sales,
	SUM(quantity) as total_quantity,
	COUNT(DISTINCT product_key) as total_products,
	MAX(order_date) as last_order,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as lifespan
FROM base_query
GROUP BY customer_key, customer_number, customer_name, age 
)

SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE 
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 and 29 THEN '20-29'
		WHEN age BETWEEN 30 and 39 THEN '30-39'
		WHEN age BETWEEN 40 and 49 THEN '40-49'
		ELSE '50 and above'
	END as age_groups,
	CASE 
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales < 5000 THEN 'Regular'
		ELSE 'New'
	END as customer_segment,
	last_order,
	DATEDIFF(MONTH, last_order, GETDATE()) as recency,
	total_order,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
	--compute average order value(AOV)
	CASE WHEN total_order = 0 THEN 0 
		 ELSE ROUND((total_sales * 1.0 / total_order), 2)
	END as average_order_value,
	--compute avg monthly spend
	ROUND(CASE WHEN lifespan = 0 THEN total_sales 
		 ELSE total_sales * 1.0 / lifespan
	END, 2) as avg_monthly_spend
FROM customer_aggregation
