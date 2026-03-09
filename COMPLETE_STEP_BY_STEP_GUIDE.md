# Complete Step-by-Step Guide: Retail Sales Analysis in MySQL Workbench

Follow these steps in order to set up and run the complete analysis.

---

## Prerequisites Checklist

- ✅ MySQL Server installed and running
- ✅ MySQL Workbench installed
- ✅ CSV file: `/Users/vladburkov/Downloads/RetailSaleAnalysisData.csv`
- ✅ Python 3 installed (for CSV import)

---

## STEP 1: Open MySQL Workbench and Connect

1. **Open MySQL Workbench**
2. **Click on your MySQL connection** (or create a new one if needed)
3. **Enter your MySQL password** when prompted
4. You should now see the SQL Editor open

---

## STEP 2: Create the Database

In the SQL Editor, copy and paste this:

```sql
CREATE DATABASE IF NOT EXISTS retail_sales_db;
USE retail_sales_db;
```

**Click Execute (⚡)** or press `Ctrl+Enter` (Mac: `Cmd+Enter`)

You should see "Query OK" messages.

---

## STEP 3: Create the Table

Copy and paste this into the SQL Editor:

```sql
USE retail_sales_db;

DROP TABLE IF EXISTS retail_sales;

CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(15),
    quantiy INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);
```

**Click Execute (⚡)**

**Verify the table was created:**
```sql
SHOW TABLES;
DESCRIBE retail_sales;
```

You should see `retail_sales` in the tables list.

---

## STEP 4: Import CSV Data

You have two options:

### Option A: Using Python Script (Recommended - Handles Encoding Issues)

1. **Open Terminal**
2. **Navigate to project directory:**
   ```bash
   cd /Users/vladburkov/SalesData-Pro
   ```

3. **Install required packages (if not already installed):**
   ```bash
   pip3 install pandas mysql-connector-python sqlalchemy
   ```

4. **Edit the Python script:**
   - Open `import_csv_python.py` in your editor
   - Find line 16: `DB_PASSWORD = ''`
   - Add your MySQL password: `DB_PASSWORD = 'your_password'`
   - Save the file

5. **Run the import script:**
   ```bash
   python3 import_csv_python.py
   ```

6. **Verify import:**
   ```sql
   SELECT COUNT(*) as total_records FROM retail_sales;
   SELECT * FROM retail_sales LIMIT 5;
   ```

### Option B: Using MySQL Workbench Import Wizard

1. In MySQL Workbench, expand `retail_sales_db` → `Tables`
2. **Right-click on `retail_sales`** → **Table Data Import Wizard**
3. Click **"..."** next to "Import from File"
4. Navigate to `/Users/vladburkov/Downloads/RetailSaleAnalysisData.csv`
5. Select the file and click **Open**
6. Click **Next** through the wizard
7. Verify column mapping (should auto-detect)
8. Click **Next** → **Next** → **Next**
9. Click **Execute**
10. Wait for "Import completed successfully"

**Note:** If you get encoding errors, use Option A (Python script) instead.

---

## STEP 5: Run the Analysis Queries

### Option A: Run All Queries at Once

1. **Open the SQL script:**
   - In MySQL Workbench: **File** → **Open SQL Script**
   - Navigate to `/Users/vladburkov/SalesData-Pro/retailsalesanalysis_mysql.sql`
   - Open it

2. **Skip the table creation part (lines 1-14)** - you already created the table

3. **Select all queries from line 16 to the end**

4. **Click Execute (⚡)** or press `Ctrl+Shift+Enter` to run all

### Option B: Run Queries One by One (Recommended for First Time)

Copy and paste each section below into MySQL Workbench and run them one at a time:

#### 5.1: Basic Statistics
```sql
USE retail_sales_db;

SELECT COUNT(*) as total_records FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) as unique_customers FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;
```

#### 5.2: Data Quality Check
```sql
SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantiy IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL;
```

#### 5.3: Data Cleaning (Remove NULL Records)
```sql
SET SQL_SAFE_UPDATES = 0;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantiy IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL;

SET SQL_SAFE_UPDATES = 1;

SELECT COUNT(*) as remaining_records FROM retail_sales;
```

#### 5.4: Sales on Specific Date
```sql
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';
```

#### 5.5: Category Analysis with Filters
```sql
SELECT * FROM retail_sales
WHERE 
    category = 'Clothing'
    AND DATE_FORMAT(sale_date, '%Y-%m') = '2022-11'
    AND quantiy >= 4;
```

#### 5.6: Sales by Category
```sql
SELECT 
    category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM retail_sales
GROUP BY category;
```

#### 5.7: Average Age by Category
```sql
SELECT
    ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty';
```

#### 5.8: High-Value Transactions
```sql
SELECT * FROM retail_sales
WHERE total_sale > 1000;
```

#### 5.9: Gender Analysis by Category
```sql
SELECT 
    category,
    gender,
    COUNT(*) as total_trans
FROM retail_sales
GROUP BY category, gender
ORDER BY category;
```

#### 5.10: Monthly Trends (Highest Average Sales Month per Year)
```sql
SELECT 
    year,
    month,
    avg_sale
FROM 
(    
    SELECT 
        YEAR(sale_date) as year,
        MONTH(sale_date) as month,
        AVG(total_sale) as avg_sale,
        RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) as `rank`
    FROM retail_sales
    GROUP BY YEAR(sale_date), MONTH(sale_date)
) as t1
WHERE `rank` = 1;
```

#### 5.11: Top 5 Customers
```sql
SELECT 
    customer_id,
    SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

#### 5.12: Unique Customers per Category
```sql
SELECT 
    category,    
    COUNT(DISTINCT customer_id) as cnt_unique_customers
FROM retail_sales
GROUP BY category;
```

#### 5.13: Time-Based Analysis (Sales by Time of Day)
```sql
WITH hourly_sale AS
(
    SELECT *,
        CASE
            WHEN HOUR(sale_time) < 12 THEN 'Morning'
            WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END as shift
    FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift;
```

---

## STEP 6: Review Results

After running all queries, you'll have:

1. ✅ Total records and unique customers
2. ✅ List of product categories
3. ✅ Records with NULL values (if any)
4. ✅ Cleaned dataset (NULL records removed)
5. ✅ Sales on November 5, 2022
6. ✅ Clothing sales analysis for November 2022
7. ✅ Sales summary by category
8. ✅ Average customer age for Beauty products
9. ✅ High-value transactions (>$1000)
10. ✅ Gender breakdown by category
11. ✅ Best performing month per year
12. ✅ Top 5 customers
13. ✅ Customer engagement by category
14. ✅ Sales distribution by time of day

---

## Troubleshooting

### Issue: "Table doesn't exist"
**Solution:** Make sure you completed Step 3 (Create the Table)

### Issue: "Column 'quantity' doesn't exist"
**Solution:** Your CSV uses `quantiy` (typo). The SQL file is already updated to use `quantiy`. If you still get errors, check:
```sql
DESCRIBE retail_sales;
```
And verify the column name matches.

### Issue: "Safe update mode" error
**Solution:** The SQL file already includes `SET SQL_SAFE_UPDATES = 0;` before the DELETE statement. Make sure you're running that line.

### Issue: Encoding error when importing CSV
**Solution:** Use the Python script (Option A in Step 4) - it handles encoding automatically.

### Issue: "LOAD DATA LOCAL INFILE" restriction
**Solution:** Use the Python script or Table Data Import Wizard instead.

---

## Quick Reference Commands

```sql
-- Check database
SHOW DATABASES;
USE retail_sales_db;

-- Check table
SHOW TABLES;
DESCRIBE retail_sales;

-- Check data
SELECT COUNT(*) FROM retail_sales;
SELECT * FROM retail_sales LIMIT 10;
```

---

## Next Steps After Analysis

1. **Export Results:** Right-click on any result grid → Export Recordset
2. **Create Visualizations:** Import results into Excel, Tableau, or Power BI
3. **Document Findings:** Update the README with your insights
4. **Share Results:** Present your analysis findings

---

## Summary Checklist

- [ ] Step 1: Opened MySQL Workbench and connected
- [ ] Step 2: Created database `retail_sales_db`
- [ ] Step 3: Created table `retail_sales`
- [ ] Step 4: Imported CSV data (using Python or Import Wizard)
- [ ] Step 5: Ran all analysis queries
- [ ] Step 6: Reviewed results

**You're done! 🎉**
