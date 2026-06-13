-----------------------
--Data Segmentation 
-----------------------

/* Segmenting products into cost ranges and count how many products fall into each segment */

WITH prod_segemnt as (
SELECT 
	product_key,
	product_name,
	cost,
	CASE 
		WHEN cost < 100 THEN 'Below 100'
		WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		ELSE 'Above 1000'
	END as cost_range
FROM gold.dim_products
)

SELECT 
	cost_range,
	COUNT(*) num_of_prods
FROM prod_segemnt
GROUP BY cost_range
ORDER BY COUNT(*)

/* Grouping customers nto three segements based on their spending behavior: 
	- VIP: Customers with at least 12 months of history and spending more than 5000
	- Regular: Customers with at least 12 months of history but spending 5000 or less 
	- New: Customers with lifespan less than 12 months.
And find the total number of customers by each group 
*/
WITH cust_order_spend as (
SELECT 
	f.customer_key,
	SUM(f.sales) as total_spending,
	MIN(f.order_date) as first_order,
	MAX(f.order_date) as last_order,
	DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) as lifespan
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c ON c.primary_key = f.customer_key
GROUP BY f.customer_key
)
SELECT
	customer_segment,
	COUNT(*) as cust_per_segemnt
FROM
(
	SELECT 
		*,
		CASE
			WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
			ELSE 'New'
		END as customer_segment
	FROM cust_order_spend
)t
GROUP BY customer_segment
