/* This script is for creating gold layer schema where all the data are connected and unified into 3 different Views. I have followed star schema i.e one fact table with final dimensions for simplicity */

----------------------------------
	----------------CustomerView
----------------------------------
	IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW gold.dim_customers;
	GO

	CREATE VIEW gold.dim_customers AS
	SELECT
		ROW_NUMBER() OVER(ORDER BY ci.cst_id) as customer_key, --Surrogate Key
		ci.cst_id as customer_id,
		ci.cst_key as customer_number,
		ci.cst_firstname as first_name,
		ci.cst_lastname as last_name,
		loc.cntry as country,
		ci.cst_marital_status as marital_status,
		CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
			 ELSE COALESCE(ca.gen, 'n/a')
		END as gender, --CRM is the master for gender integration
		ca.bdate as birthdate,
		ci.cst_create_date
	FROM silver.crm_cust_info ci --Conidering this as master table for customers  
	LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 loc ON ci.cst_key = loc.cid;
	GO


----------------------------------
	----------------ProductsView
----------------------------------   
    
	IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
	DROP VIEW gold.dim_products;
	GO

	CREATE VIEW gold.dim_products AS
	SELECT
		ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) as product_key, --Surrogate Key
		pn.prd_id as product_id,
		pn.prd_key as product_number,
		pn.prd_nm as product_name,
		pn.cat_id as category_id,
		pc.cat as category,
		pc.subcat as subcategory,
		pc.maintenance,
		pn.prd_cost as cost,
		pn.prd_line as line,
		pn.prd_start_dt as start_date
	FROM silver.crm_prd_info pn
	LEFT JOIN silver.erp_px_cat_g1v2 pc ON pn.cat_id = pc.id
	WHERE prd_end_dt IS NULL; --Filtering historical data
	GO

----------------------------------
	----------------FactSalesView
----------------------------------    
	IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW gold.fact_sales;
	GO
	
	CREATE VIEW gold.fact_sales AS
	SELECT
		sls_ord_num as order_number,
		pr.product_key,
		cu.customer_key as customer_key,
		sls_order_dt as order_date,
		sls_ship_dt as shipping_date,
		sls_due_dt as due_date,
		sls_quantity as quantity,
		sls_price as price,
		sls_sales as sales
	FROM silver.crm_sales_details sd
	LEFT JOIN gold.dim_products pr  ON sd.sls_prd_key = pr.product_number
	LEFT JOIN gold.dim_customers cu ON sd.sls_cust_id = cu.customer_id;
	/* surogate keys replaces the keys present in the fact table for the easier access and determination */
	GO
