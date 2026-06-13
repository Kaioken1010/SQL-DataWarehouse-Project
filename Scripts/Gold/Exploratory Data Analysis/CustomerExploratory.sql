--Explore all the counbtries where our customers come from 
SELECT DISTINCT country FROM gold.dim_customers

--Explore all the major categories
SELECT DISTINCT category, subcategory, product_name FROM gold.dim_products
ORDER BY 1,2,3



--Exploring dates using MIN/MAX

--factsales Table
SELECT 
	MIN(order_date) as first_order,
	MAX(order_date) as last_order,
	DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) years_of_sales
FROM gold.fact_sales

--Customer Table
SELECT
	MIN(birthdate) as oldest_cust,
	DATEDIFF(YEAR, MIN(birthdate), getdate()) as age_of_oldest,
	MAX(birthdate) as youngest_cust,
	DATEDIFF(YEAR, MAX(birthdate), getdate()) as age_of_youngest
FROM gold.dim_customers 
