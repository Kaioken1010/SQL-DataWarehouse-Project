/*
====================================
CREATE DATABASE AND SCHEMAS 
====================================
1. This script creates a new database 'DataWareHouse' after checking if it already exists.
the schemas are also created in the database- 'bronze' , 'silver', 'gold' (Medallian structure)

2. --SCHEMA CHECK-- SHOULD BE EXECUTED AFTER CREATING DATABASE AND SCHEMAS 

**BE CAUTIUOS RUNNNIG THIS SCRIPT AS IT WILL DROP THE EXISTING DATABASE(IF PRESENT) ALONG 
WITH DATA IN IT.
*/
USE master:
GO

--DROP AND RECREATE DATABASE 'DataWareHouse'--
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DataWareHouse') 
BEGIN
  ALTER DATABASE DataWareHouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DataWareHouse;
  END
GO


  --CREATING DATABASE 'DataWareHouse'--
CREATE DATABASE DataWareHouse; 
GO

  --CONNECTING TO DataWareHouse--
USE DataWareHouse; 
GO

  --CREATING SCHEMAS--
CREATE SCHEMA bronze; --raw and untouched data
GO 

CREATE SCHEMA silver; --data cleaning and managing
GO 

CREATE SCHEMA silver; --final data structure for analysis and business
GO 


--SCHEMA CHECK--
SELECT * FROM sys.schemas;
