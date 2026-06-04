/* 
=======================================================
Stored Procedure: Load Silver Layer (Bronze --> Silver) 
=======================================================
Purpose: This script facilitates the extract, transform, and load (ETL) process for migrating 
data from the bronze layer to the silver layer. It ensures the data is thoroughly cleaned 
and standardized to support downstream analytical processing.

Eg. Usage -->> EXEC silver.load
*/



CREATE OR ALTER PROCEDURE silver.load AS 

BEGIN
	DECLARE @StartTime DATETIME, @EndTime DATETIME, @BatchStartTime DATETIME, @BatchEndTime DATETIME
		BEGIN TRY
			
			SET @BatchStartTime = GETDATE()
			---------------------------------------------
			--**************CRM TABLES*****************--
			---------------------------------------------
			SET @StartTime = GETDATE()
			--silver.crm_cust_info------------------------------------------
			PRINT('Truncating Table: silver.crm_cust_info');
			TRUNCATE TABLE silver.crm_cust_info;
			PRINT('Inserting Data into silver.crm_cust_info');
			INSERT INTO silver.crm_cust_info(
				cst_id,
				cst_key,
				cst_firstname,
				cst_lastname,
				cst_marital_status,
				cst_gndr,
				cst_create_date
			)

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
			PRINT('Data Loaded in silver.crm_cust_info');
			SET @EndTime = GETDATE()
			PRINT('Total time taken  to process table silver.crm_cust_info ' + CAST(DATEDIFF(SECOND, @StartTime,@EndTime) as VARCHAR) + ' Seconds');
			PRINT('-----------*****-------------');
			



			--silver.crm_prd_info------------------------------------------
			SET @StartTime = GETDATE()
			PRINT('Truncating Table: silver.crm_prd_info');
			TRUNCATE TABLE silver.crm_prd_info;
			PRINT('Inserting Data into silver.crm_prd_info');
			INSERT INTO silver.crm_prd_info(
				prd_id,
				cat_id,
				prd_key,
				prd_nm,
				prd_cost,
				prd_line,
				prd_start_dt,
				prd_end_dt
			)

			SELECT prd_id
				  ,UPPER(REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_')) as cat_id --Extract Category ID
				  ,SUBSTRING(TRIM(prd_key), 7, LEN(prd_key)) as prd_key --Extract Product Key
				  ,TRIM(prd_nm) as prd_nm
				  ,COALESCE([prd_cost],0) as prd_cost
				  ,CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
						WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
						WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
						WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
						ELSE 'Unknown' END AS prd_line
				  ,[prd_start_dt]
				  ,DATEADD(DAY,-1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) as prd_end_dt
			FROM [bronze].[crm_prd_info];
			PRINT('Data Loaded in silver.crm_prd_info');
			SET @EndTime = GETDATE()
			PRINT('Total time taken  to process table silver.crm_prd_info ' + CAST(DATEDIFF(SECOND, @StartTime,@EndTime) as VARCHAR) + ' Seconds');
			PRINT('-----------*****-------------');



			--silver.crm_sales_details------------------------------------------
			SET @StartTime = GETDATE()
			PRINT('Truncating Table: silver.crm_sales_details');
			TRUNCATE TABLE silver.crm_sales_details;
			PRINT('Inserting Data into crm_sales_details');
			INSERT INTO silver.crm_sales_details(
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				sls_order_dt,
				sls_ship_dt,
				sls_due_dt,
				sls_sales,
				sls_quantity,
				sls_price
			)

			SELECT [sls_ord_num]
				  ,[sls_prd_key]
				  ,[sls_cust_id]
      
				  ,CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8  THEN NULL
						ELSE CAST(CAST(sls_order_dt as VARCHAR) as DATE) 
				   END AS sls_order_dt
      
				  ,CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8  THEN NULL
						ELSE CAST(CAST(sls_ship_dt as VARCHAR) as DATE) 
				   END AS sls_ship_dt

				  ,CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8  THEN NULL
						ELSE CAST(CAST(sls_due_dt as VARCHAR) as DATE) 
				   END AS sls_due_dt

				  ,CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
						ELSE sls_sales
				   END AS sls_sales
      
				  ,[sls_quantity]
      
				  ,CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN ABS(sls_sales)/NULLIF(sls_quantity, 0)
						ELSE ABS(sls_price)
				   END AS sls_price
  
			FROM [bronze].[crm_sales_details];
			PRINT('Data Loaded in silver.crm_sales_details');
			SET @EndTime = GETDATE()
			PRINT('Total time taken  to process table silver.crm_sales_details ' + CAST(DATEDIFF(SECOND, @StartTime,@EndTime) as VARCHAR) + ' Seconds');
			PRINT('-----------*****-------------');



			---------------------------------------------
			--**************ERP TABLES*****************--
			---------------------------------------------


			--silver.erp_cust_az12------------------------------------------
			SET @StartTime =  GETDATE()
			PRINT('Truncating Table: silver.erp_cust_az12');
			TRUNCATE TABLE silver.erp_cust_az12;
			PRINT('Inserting Data into silver.erp_cust_az12');
			INSERT INTO silver.erp_cust_az12 (
				cid, 
				bdate, 
				gen
			)

			SELECT
	
				CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID))
					 ELSE CID
				END AS cid,
	
				CASE WHEN BDATE > GETDATE() THEN NULL 
					 ELSE BDATE 
				END as bdate,
	
				CASE WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
					 WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
					 ELSE 'n/a'
				END as gen
			FROM bronze.erp_cust_az12;
			PRINT('Data Loaded in silver.erp_cust_az12');
			SET @EndTime = GETDATE()
			PRINT('Total time taken  to process table silver.erp_cust_az12 ' + CAST(DATEDIFF(SECOND, @StartTime,@EndTime) as VARCHAR) + ' Seconds');
			PRINT('-----------*****-------------');



			--silver.erp_loc_a101------------------------------------------
			SET @StartTime = GETDATE()
			PRINT('Truncating Table: silver.erp_loc_a101');
			TRUNCATE TABLE silver.erp_loc_a101;
			PRINT('Inserting Data into silver.erp_loc_a101');
			INSERT INTO silver.erp_loc_a101(
				cid,
				cntry
			)

			SELECT 
				REPLACE(CID, '-', '') as cid,
				CASE
					WHEN UPPER(TRIM(CNTRY)) IN ('DE', 'de')         THEN 'Germany'
					WHEN UPPER(TRIM(CNTRY)) IN ('USA', 'usa', 'US') THEN 'United States'
					WHEN UPPER(TRIM(CNTRY)) IS NULL                 THEN 'n/a'
					WHEN UPPER(TRIM(CNTRY)) = ''                    THEN 'n/a'
					ELSE TRIM(CNTRY)
				END as cntry
			FROM bronze.erp_loc_a101;
			PRINT('Data Loaded in silver.erp_loc_a101');
			SET @EndTime = GETDATE()
			PRINT('Total time taken  to process table silver.erp_loc_a101 ' + CAST(DATEDIFF(SECOND, @StartTime,@EndTime) as VARCHAR) + ' Seconds');
			PRINT('-----------*****-------------');



			--silver.erp_px_cat_g1v2------------------------------------------
			SET @StartTime = GETDATE()
			PRINT('Truncating Table: silver.erp_px_cat_g1v2');
			TRUNCATE TABLE silver.erp_px_cat_g1v2;
			PRINT('Inserting Data into silver.erp_px_cat_g1v2');
			INSERT INTO silver.erp_px_cat_g1v2(
				id,
				cat,
				subcat,
				maintenance
			)

			SELECT
				ID as id,
				CAT as cat,
				SUBCAT as subcat,
				MAINTENANCE as maintenance
			FROM bronze.erp_px_cat_g1v2;
			PRINT('Data Loaded in silver.erp_px_cat_g1v2');
			SET @EndTime = GETDATE()
			PRINT('Total time taken  to process table silver.erp_px_cat_g1v2 ' + CAST(DATEDIFF(SECOND, @StartTime,@EndTime) as VARCHAR) + ' Seconds');
			PRINT('-----------*****-------------');

			SET @BatchEndTime = GETDATE()
			PRINT('Total time taken by silver.load ' + CAST(DATEDIFF(Second, @BatchStartTime, @BatchEndTime) as VARCHAR) + ' Seconds');

		END TRY 
	
	BEGIN CATCH
	PRINT('Error message: ' + ERROR_MESSAGE());
	PRINT('Error Number: ' + CAST(ERROR_NUMBER() as NVARCHAR));
	PRINT('Error Line: '  + CAST(ERROR_LINE() as NVARCHAR));
	END CATCH

END  
