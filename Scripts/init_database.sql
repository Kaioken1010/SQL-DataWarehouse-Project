USE master:
GO

--DROP AND RECREATE DATABASE 'DataWareHouse'--
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DataWareHouse') 
BEGIN
  ALTER DATABASE DataWareHouse


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

