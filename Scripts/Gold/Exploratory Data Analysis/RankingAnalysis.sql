-----------------------------
--Ranking Analysis
-----------------------------

--Which 5 products gerenates the highest revenue

SELECT TOP 5 p.product_name, SUM(fs.sales) as revenue FROM gold.fact_sales fs
LEFT JOIN gold.dim_products p ON fs.product_key = p.product_key
GROUP BY  p.product_name
ORDER BY SUM(fs.sales) DESC
								------------


SELECT *
FROM (
SELECT 
	ROW_NUMBER() OVER(ORDER BY SUM(fs.sales) DESC) as rn,
	p.product_name, 
	SUM(fs.sales) as revenue 
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products p ON fs.product_key = p.product_key
GROUP BY p.product_name
) t
WHERE rn <= 5


--Which 5 products are worst performing in terms of sales
SELECT TOP 5 p.product_name, SUM(fs.sales) as revenue FROM gold.fact_sales fs
LEFT JOIN gold.dim_products p ON fs.product_key = p.product_key
GROUP BY  p.product_name
ORDER BY SUM(fs.sales)

--Find top 10 customers who have generated the highest revenue 

SELECT TOP 10
	c.primary_key, 
	c.first_name, 
	c.last_name, 
	SUM(sales) as rev_generated 
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers c ON c.primary_key = fs.customer_key
GROUP BY c.primary_key, c.first_name, c.last_name
ORDER BY SUM(sales) DESC

--The 3 customers with fewest orders placed 
SELECT TOP 3
	c.primary_key, 
	c.first_name, 
	c.last_name, 
	COUNT(DISTINCT fs.order_number) as number_of_order 
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers c ON c.primary_key = fs.customer_key
GROUP BY c.primary_key, c.first_name, c.last_name
ORDER BY COUNT(DISTINCT order_number)
