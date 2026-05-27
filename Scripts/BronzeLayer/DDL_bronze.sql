/* We are inserting all the data from the source files into the bronze layer tables. We are using the BULK INSERT statement to load the data from 
the CSV files into the respective tables. The FirstRow option is set to 2 to skip the header row in the CSV files, 
and the FieldTerminator is set to ',' to specify that the fields in the CSV files are separated by commas. 
The TABLOCK option is used to improve performance by locking the entire table during the bulk insert operation. Further more we are using some 
cosmetics like error code handling and total time execution in order to make our process more clean and organized. */

CREATE OR ALTER PROCEDURE bronze.load AS

BEGIN
	DECLARE @StartTime DATETIME, @EndTime DATETIME;
	BEGIN TRY
	
		PRINT '===========================';
		PRINT 'Loading Bronze Layer';
		PRINT '===========================';
		------------------------------------
		--CRM TABLES--
		------------------------------------
		PRINT '---------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '---------------------------';

		SET @StartTime = GETDATE();
		PRINT 'Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT 'Inserting data into Table: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'D:\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH(
			FirstRow = 2,
			FieldTerminator = ',',
			TABLOCK
		);
		SET @EndTime = GETDATE();
		PRINT 'Time taken to load CRM Customer Info: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';

		SET @StartTime = GETDATE();
		PRINT 'Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT 'Inserting data into Table: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'D:\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH(
			FirstRow = 2,
			FieldTerminator = ',',
			TABLOCK
		);
		SET @EndTime = GETDATE();
		PRINT 'Time taken to load CRM Product Info: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
		
		SET @StartTime = GETDATE();
		PRINT 'Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT 'Inserting data into Table: bronze.crm_sales_details';
		BULK INSERT [bronze].[crm_sales_details]
		FROM 'D:\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH(
			FirstRow = 2,
			FieldTerminator = ',',
			TABLOCK
		);
		SET @EndTime = GETDATE();
		PRINT 'Time taken to load CRM Sales Details: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
		--SELECT * FROM bronze.crm_sales_details;


		------------------------------
		--ERP TABLES--
		------------------------------
		PRINT '---------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '---------------------------';

		SET @StartTime = GETDATE();
		PRINT 'Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT 'Inserting data into Table: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'D:\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		SET @EndTime = GETDATE();
		PRINT 'Time taken to load ERP Customer AZ12: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';

		SET @StartTime = GETDATE();
		PRINT 'Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT 'Inserting data into Table: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'D:\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FirstRow = 2,
			FieldTerminator = ',',
			tablock
		);
		SET @EndTime = GETDATE();
		PRINT 'Time taken to load ERP Location A101: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';
	
		SET @StartTime = GETDATE();
		PRINT 'Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT 'Inserting data into Table: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'D:\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FirstRow = 2,
			FieldTerminator = ',',
			tablock
		);
		SET	@EndTime = GETDATE();
		PRINT 'Time taken to load ERP Price Category G1V2: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS NVARCHAR) + ' seconds';

	END TRY
	BEGIN CATCH
		PRINT 'Error occurred while loading data into bronze layer: ' + ERROR_MESSAGE();
		PRINT 'Error number ' + CAST(ERROR_NUMBER() as NVARCHAR);
		PRINT 'Error Line ' + ERROR_LINE();
	END CATCH
END;
