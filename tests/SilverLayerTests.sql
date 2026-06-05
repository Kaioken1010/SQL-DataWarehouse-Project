/* This script written in order to document and test all the data standardizations and consistency in the silver layer or silver schema. This document shows 
procedures for data validation and cleaning in order to ensure data quality and later help loading data into gold layer with much more ease.*/



----------------------------------------------------
--*****************CRM TABLES*****************-- 
----------------------------------------------------

------------------silver.crm_cust_info--

SELECT 
	cst_id,
	cst_key,
	--Data Cleaning--
	TRIM(cst_firstname) cst_firstname,
	TRIM(cst_lastname) cst_lastname,
	
	--Data standardization and missing values--
	CASE WHEN UPPER(TRIM(cst_marital_status)) =  'M' THEN 'Married' --UPPER and TRIM used to handle both error cases in the data
		 WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		 ELSE 'n/a' --NULL case handling
		 END AS cst_marital_status,
	
	CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		 WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		 ELSE 'n/a' 
		 END AS cst_gndr,
	cst_create_date
FROM 
(
--Removing duplicates
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last --Primary key cleaning using ROW_NUMBER to get the latest record for each cst_id
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL
)t
WHERE flag_last = 1;


------------------silver.crm_prd_info------------------

--Simple Duplicate check for id column 
SELECT prd_id, COUNT(*) FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

--Check for prd_cost with nulls and negative values
SELECT prd_cost FROM silver.crm_prd_info 
WHERE prd_cost IS NULL OR prd_cost < 0;

--Check the abbreviations for prd_line (NOTE - fact check all the abbreviation from the stakeholders)
SELECT
    DISTINCT(prd_line)
FROM silver.crm_prd_info; -- M(Mountain), R(Road), S(Other Sales), T(Touring)

--Checking quality of start and end date
SELECT 
    *                                       
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt /*For dates, coming to a general understanding that start date cannot be higher    
                                            than the end date and start date CANNOT BE NULL  */


------------------silver.crm_sales_details------------------

--Check for order dates greater than ship dates
SELECT 
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

--Check Data between sales, quality and price 
-->> Sales =  quantity * price
-->> cannot be 0 or NULL or Negative 

SELECT
    sls_quantity,
    sls_price,
    sls_sales
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price OR sls_sales IS NULL OR sls_quantity IS NULL
        OR sls_price IS NULL OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price



----------------------------------------------------
--*****************ERP TABLES*****************-- 
----------------------------------------------------


------------------silver.erp_cust_az12------------------

--Check for invalid BDATE values
SELECT BDATE FROM silver.erp_cust_az12
WHERE BDATE <= '1924-01-01' OR BDATE > GETDATE() -- Filter out invalid dates
ORDER BY BDATE DESC

--Check for GEN column
SELECT DISTINCT GEN FROM silver.erp_cust_az12


------------------silver.erp_loc_a101------------------

--CID quality control 
SELECT 
	REPLACE(CID, '-', '')
FROM bronze.erp_loc_a101
WHERE REPLACE(CID, '-', '') NOT IN (SELECT cst_key FROM silver.crm_cust_info)

SELECT cst_key FROM silver.crm_cust_info

--CNTRY quality control
SELECT
	DISTINCT CNTRY,
	CASE
		WHEN UPPER(TRIM(CNTRY)) IN ('DE', 'de')         THEN 'Germany'
		WHEN UPPER(TRIM(CNTRY)) IN ('USA', 'usa', 'US') THEN 'United States'
		WHEN UPPER(TRIM(CNTRY)) IS NULL                 THEN 'n/a'
		WHEN UPPER(TRIM(CNTRY)) = ''                    THEN 'n/a'
		ELSE TRIM(CNTRY)
	END as cntry1
FROM bronze.erp_loc_a101
ORDER BY CNTRY


------------------silver.erp_loc_a101------------------
--ID column checks
SELECT 
	ID
FROM silver.erp_px_cat_g1v2
WHERE ID NOT IN (SELECT cat_id FROM silver.crm_prd_info)

--Check for unwanted spaces 
SELECT
	 *
FROM silver.erp_px_cat_g1v2
WHERE CAT != TRIM(CAT) OR SUBCAT != TRIM(SUBCAT) OR MAINTENANCE != TRIM(MAINTENANCE)

--Standardization and Consistency
SELECT DISTINCT MAINTENANCE FROM silver.erp_px_cat_g1v2
