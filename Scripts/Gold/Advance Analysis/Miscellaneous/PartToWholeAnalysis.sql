----------------------------
--Part to Whole analysis 
----------------------------
--Calculating percentage  

--Which categories contribute most to the overall sales 

SELECT 
	p.category,
	SUM(f.sales) cat_sales,
	ROUND(SUM(f.sales) * 100.0 / (SELECT SUM(sales) FROM gold.fact_sales), 2) as percentage
FROM gold.fact_sales f 
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
GROUP BY p.category
