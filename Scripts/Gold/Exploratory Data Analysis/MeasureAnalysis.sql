--------------------------------
--Measures Exploration--
--------------------------------
--Finding total sales 
	SELECT SUM(sales) as total_sales FROM gold.fact_sales 

--Finding how many items are sold 
	SELECT SUM(quantity) as total_items_sold FROM  gold.fact_sales 

--Finding the average selling price 
	SELECT AVG(price) as avg_selling_price FROM  gold.fact_sales 

--Finding the total number of orders 
	SELECT COUNT(DISTINCT order_number) as total_orders FROM gold.fact_sales 

--Finding the total numbers of products  
	SELECT COUNT(DISTINCT product_key) as total_products FROM gold.dim_products 

--Finding the total number of customers 
	SELECT COUNT(primary_key) as total_cust FROM gold.dim_customers

--Finding the total number of customers that has placed order 
	SELECT COUNT(DISTINCT customer_key) as total_order_placed_by_cust FROM gold.fact_sales 



--Generating a report that shows all key metrics of the business

	SELECT 'Total sales' as measure_name, SUM(sales) as measure_value FROM gold.fact_sales
	UNION ALL
	SELECT 'Total Items Sold', SUM(quantity) FROM  gold.fact_sales
	UNION ALL
	SELECT 'AVG Selling Price', AVG(price) FROM  gold.fact_sales
	UNION ALL
	SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
	UNION ALL
	SELECT 'Total Products',COUNT(DISTINCT product_key) FROM gold.dim_products
	UNION ALL
	SELECT 'Total Customers', COUNT(primary_key) FROM gold.dim_customers
	UNION ALL
	SELECT 'Total Order Placed By Cust', COUNT(DISTINCT customer_key) FROM gold.fact_sales
