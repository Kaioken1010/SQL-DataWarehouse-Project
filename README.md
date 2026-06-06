# SQL Data WareHouse Project

## 📊 Project Overview

A comprehensive **SQL Server (T-SQL) Data Warehouse** implementation following the **Medallion Architecture** (Bronze-Silver-Gold layers). This project demonstrates a complete ETL pipeline that extracts data from multiple sources (CRM and ERP systems), transforms and cleanses it through progressive layers, and prepares it for analytics and business intelligence.

## 🎯 Project Goals

This project showcases:
- **Multi-layer Data Architecture**: Implementing the Medallion pattern for scalable data transformation
- **ETL Pipeline Development**: Building robust data extraction, transformation, and loading processes
- **Data Quality & Cleaning**: Implementing validation rules and data standardization techniques
- **Multi-source Integration**: Combining data from CRM and ERP systems into a unified warehouse
- **Performance Monitoring**: Tracking execution times and optimization of data loading processes

## 🏗️ Architecture Overview

The project follows a **3-layer Medallion Architecture**:

### 🔵 **Bronze Layer** - Raw Data Ingestion
- **Purpose**: Stores raw, untouched data exactly as received from source systems
- **Data Sources**:
  - **CRM Source**: Customer information, product details, sales transactions
  - **ERP Source**: Customer master data, location information, product categories
- **Process**: BULK INSERT from CSV files with error handling and performance tracking

### 🟢 **Silver Layer** - Data Cleaning & Transformation
- **Purpose**: Cleaned, standardized, and deduplicated data ready for analytics
- **Transformations Applied**:
  - **Text Cleaning**: TRIM() function to remove leading/trailing spaces
  - **Data Standardization**: Converting abbreviations to meaningful values
    - Gender: M → Male, F → Female
    - Marital Status: M → Married, S → Single
  - **Duplicate Removal**: Using ROW_NUMBER() to identify and keep only the latest records
  - **Data Quality Validation**: Handling NULL values and inconsistent data formats

### 🟡 **Gold Layer** - Analytics Ready (Planned/TBD)
- **Purpose**: Aggregated, business-ready data for reporting and analysis
- **Status**: Reserved for future development and dimensional modeling
