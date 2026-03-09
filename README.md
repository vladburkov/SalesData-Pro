# Retail Sales Analysis

## OBJECTIVES

1. **Establish a Retail Sales Database**: Create and populate a database with the provided retail sales information.

2. **Data Cleaning**: Detect and eliminate any records containing missing or null values.

3. **Exploratory Data Analysis (EDA)**: Conduct preliminary data analysis to gain an understanding of the dataset.

4. **Business Analysis**: Use SQL to address key business questions and extract insights from the sales data.

## FINDINGS

1. **Customer Demographics**: The dataset contains customers from a wide range of age groups, with sales spanning multiple categories like Clothing and Beauty.

2. **High-Value Transactions**: A number of transactions exceeded 1000 in total, suggesting a focus on high-end purchases.

3. **Sales Trends**: Monthly evaluations reveal fluctuations in sales, highlighting periods of peak demand.

4. **Customer Insights**: The analysis highlights the highest-spending customers and the most frequently purchased product categories.

---

## SETUP AND RUN INSTRUCTIONS

### Prerequisites

- A database system installed (PostgreSQL, MySQL, or SQLite)
- CSV file: `RetailSalesAnalysisData.csv`
- SQL script: `retailsalesanalysis.sql`

### Option 1: PostgreSQL (Recommended)

The SQL script uses PostgreSQL syntax (`TO_CHAR`, `EXTRACT` functions).

#### Installation (if needed):
```bash
# macOS
brew install postgresql
brew services start postgresql

# Ubuntu/Debian
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql

# Windows
# Download from https://www.postgresql.org/download/windows/
```

#### Steps to Run:

1. **Create a database:**
```bash
createdb retail_sales_db
```

2. **Connect to PostgreSQL:**
```bash
psql retail_sales_db
```

3. **Import the CSV data:**
```sql
-- Create the table first
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(15),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);

-- Import CSV (adjust path as needed)
\copy retail_sales FROM 'RetailSalesAnalysisData.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
```

4. **Run the analysis script:**
```bash
# From command line (outside psql)
psql retail_sales_db -f retailsalesanalysis.sql

# OR copy and paste the SQL commands directly in psql
```

### Option 2: MySQL

**Note:** The SQL script uses PostgreSQL-specific functions. For MySQL, you'll need to modify:
- `TO_CHAR(sale_date, 'YYYY-MM')` → `DATE_FORMAT(sale_date, '%Y-%m')`
- `EXTRACT(YEAR FROM sale_date)` → `YEAR(sale_date)`
- `EXTRACT(MONTH FROM sale_date)` → `MONTH(sale_date)`
- `EXTRACT(HOUR FROM sale_time)` → `HOUR(sale_time)`

#### Steps to Run:

1. **Create a database:**
```bash
mysql -u root -p
```

```sql
CREATE DATABASE retail_sales_db;
USE retail_sales_db;
```

2. **Create table and import CSV:**
```sql
-- Create table
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(15),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);

-- Import CSV (adjust path and use LOAD DATA INFILE)
LOAD DATA INFILE '/path/to/RetailSalesAnalysisData.csv'
INTO TABLE retail_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

3. **Run the analysis** (after modifying PostgreSQL-specific functions)

### Option 3: SQLite

**Note:** SQLite has limited support for some functions. You'll need to modify:
- `TO_CHAR(sale_date, 'YYYY-MM')` → `strftime('%Y-%m', sale_date)`
- `EXTRACT(YEAR FROM sale_date)` → `strftime('%Y', sale_date)`
- `EXTRACT(MONTH FROM sale_date)` → `strftime('%m', sale_date)`
- `EXTRACT(HOUR FROM sale_time)` → `strftime('%H', sale_time)`
- `RANK() OVER(...)` → Use a subquery or CTE

#### Steps to Run:

1. **Create database and import CSV:**
```bash
sqlite3 retail_sales.db
```

```sql
-- Create table
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(15),
    quantity INT,
    price_per_unit REAL,
    cogs REAL,
    total_sale REAL
);

-- Import CSV
.mode csv
.import RetailSalesAnalysisData.csv retail_sales
```

2. **Run the analysis** (after modifying PostgreSQL-specific functions)

### Option 4: Using Python with pandas and SQLite (Easy Alternative)

If you prefer Python, you can use this approach:

```python
import pandas as pd
import sqlite3

# Read CSV
df = pd.read_csv('RetailSalesAnalysisData.csv')

# Create SQLite database
conn = sqlite3.connect('retail_sales.db')

# Write to database
df.to_sql('retail_sales', conn, if_exists='replace', index=False)

# Read SQL file and execute (with modifications for SQLite syntax)
with open('retailsalesanalysis.sql', 'r') as f:
    sql_script = f.read()
    # Modify PostgreSQL-specific functions for SQLite
    # Then execute queries as needed

conn.close()
```

---

## FIXED ISSUES

The following issues have been corrected:

1. ✅ Fixed typo: `quantiy` → `quantity` in both SQL table definition and CSV header
2. ✅ Added missing semicolons to all SQL statements
3. ✅ Added `total_sale IS NULL` check to data cleaning queries

---

## FILE STRUCTURE

```
SalesData-Pro/
├── README.md                      # This file
├── retailsalesanalysis.sql        # SQL analysis script
└── RetailSalesAnalysisData.csv     # Retail sales dataset
```

---

## QUERY DESCRIPTIONS

The SQL script contains the following analyses:

1. **Basic Statistics**: Total records, unique customers, categories
2. **Data Quality Check**: Identifies records with NULL values
3. **Data Cleaning**: Removes records with NULL values
4. **Date Filtering**: Sales on specific dates
5. **Category Analysis**: Sales by category with filters
6. **Average Age**: Average customer age by category
7. **High-Value Transactions**: Transactions over $1000
8. **Gender Analysis**: Transaction counts by category and gender
9. **Monthly Trends**: Highest average sales month per year
10. **Top Customers**: Top 5 customers by total sales
11. **Customer Engagement**: Unique customers per category
12. **Time-Based Analysis**: Sales by time of day (Morning/Afternoon/Evening)

---

## TROUBLESHOOTING

### Common Issues:

1. **CSV Import Errors**: Ensure the CSV file path is correct and accessible
2. **Permission Errors**: Make sure you have read/write permissions for the database
3. **Syntax Errors**: If using MySQL or SQLite, modify PostgreSQL-specific functions as noted above
4. **NULL Values**: The script will identify and remove records with NULL values automatically

### Getting Help:

- Check database logs for specific error messages
- Verify CSV file encoding (should be UTF-8)
- Ensure all required columns are present in the CSV
