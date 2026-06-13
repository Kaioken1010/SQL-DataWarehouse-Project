------------------------------
--Performance Analysis
------------------------------
--Calculating Delta

/*Analyzing the yearly performance of the products by comparing each product's  
sales to both its average sales performance and the previous year's sales */

WITH yearly_pro_sales as (
SELECT 
	YEAR(f.order_date) as order_year,
	p.product_name,
	SUM(f.sales) as current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(f.order_date), p.product_name
)

SELECT 
	order_year,
	product_name,
	current_sales,
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) as py_sales, 
	AVG(current_sales) OVER (PARTITION BY product_name) as avg_pro_sales,
	(current_sales - AVG(current_sales) OVER (PARTITION BY product_name)) as delta_avg,
	(current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year)) as  delta_py_sales,
	CASE WHEN (current_sales - AVG(current_sales) OVER (PARTITION BY product_name)) > 0 THEN 'Above Avg'
		 WHEN (current_sales - AVG(current_sales) OVER (PARTITION BY product_name)) < 0 THEN 'Below Avg'
		 ELSE 'Avg'
		 END as indicator,
	CASE WHEN (current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year)) > 0 THEN 'Increase'
		 WHEN (current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year)) < 0 THEN 'Decrease'
		 ELSE 'No change'
		 END as py_change
FROM yearly_pro_sales
ORDER BY product_name, order_year
