------------------------------------------
--Cumulative Analysis--Changes over time 
------------------------------------------

--Calculate total sales for each month
--and the running total of sales over time 

SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER( ORDER BY order_date ) as running_total,
	avg_price,
	AVG(avg_price) OVER (ORDER BY order_date) as moving_avg 
FROM
(
SELECT 
	DATETRUNC(MONTH, order_date) as order_date,
	SUM(sales) as total_sales,
	AVG(price) as avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
)t

