# Setting Up Retail Sales Analysis in MySQL Workbench

This guide will walk you through setting up and running the retail sales analysis project in MySQL Workbench.

## Prerequisites

- MySQL Server installed and running
- MySQL Workbench installed
- CSV file: `RetailSalesAnalysisData.csv`
- MySQL-compatible SQL script: `retailsalesanalysis_mysql.sql`

---

## Step-by-Step Instructions

### Step 1: Open MySQL Workbench

1. Launch MySQL Workbench
2. Connect to your MySQL server (click on your connection or create a new one)
3. Enter your password if prompted

### Step 2: Create the Database

**Option A: Database doesn't exist yet**
```sql
CREATE DATABASE retail_sales_db;
USE retail_sales_db;
```

**Option B: Database already exists (you'll see Error 1007)**
Simply use the existing database:
```sql
USE retail_sales_db;
```

**Option C: Drop and recreate (if you want a fresh start)**
```sql
DROP DATABASE IF EXISTS retail_sales_db;
CREATE DATABASE retail_sales_db;
USE retail_sales_db;
```

Click the ⚡ (Execute) button or press `Ctrl+Enter` (Windows/Linux) or `Cmd+Enter` (Mac)

### Step 3: Create the Table

**IMPORTANT:** You MUST create the table before importing data!

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
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);
```

Click Execute (⚡).

**Verify the table was created:**
```sql
SHOW TABLES;
```
You should see `retail_sales` in the list.

### Step 4: Import CSV Data

MySQL Workbench has a built-in CSV import wizard:

#### Method 1: Using Table Data Import Wizard (Recommended)

1. In the left sidebar (SCHEMAS), expand `retail_sales_db`
2. Right-click on `Tables` → `Table Data Import Wizard`
3. Click "..." and navigate to `RetailSalesAnalysisData.csv`
4. Click "Next"
5. Select "Use existing table" → `retail_sales`
6. Click "Next"
7. Map the columns (should auto-detect):
   - `transactions_id` → `transactions_id`
   - `sale_date` → `sale_date`
   - `sale_time` → `sale_time`
   - `customer_id` → `customer_id`
   - `gender` → `gender`
   - `age` → `age`
   - `category` → `category`
   - `quantity` → `quantity`
   - `price_per_unit` → `price_per_unit`
   - `cogs` → `cogs`
   - `total_sale` → `total_sale`
8. Click "Next" → "Next" → "Next"
9. Click "Execute" to import
10. Wait for import to complete

#### Method 2: Using LOAD DATA INFILE (Alternative - Fixes Encoding Issues!)

If the wizard doesn't work or gives encoding errors, use this SQL command:

**Step 1:** Enable local file loading:
```sql
SET GLOBAL local_infile = 1;
```

**Step 2:** Make sure you've created the table first (see Step 3)!

**Step 3:** Load the data (adjust path to your actual file location):
```sql
USE retail_sales_db;

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '/Users/vladburkov/Downloads/RetailSaleAnalysisData.csv'
INTO TABLE retail_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(transactions_id, sale_date, sale_time, customer_id, gender, age, category, quantity, price_per_unit, cogs, total_sale);
```

**Note:** I noticed your file is named `RetailSaleAnalysisData.csv` (not `RetailSalesAnalysisData.csv`) and it's in `/Users/vladburkov/Downloads/`. Make sure the path matches your actual file location exactly!

**Note:** 
- Replace `/Users/vladburkov/SalesData-Pro/RetailSalesAnalysisData.csv` with your actual file path
- Use forward slashes `/` even on Windows (or use `\\` for Windows paths)
- This method handles UTF-8 encoding better than the wizard

#### Method 3: Manual Import via SQL (If above methods fail)

1. Open `RetailSalesAnalysisData.csv` in Excel or a text editor
2. Copy the data (skip header row)
3. Use INSERT statements (not recommended for large datasets)

### Step 5: Verify Data Import

Run this query to check:

```sql
SELECT COUNT(*) as total_records FROM retail_sales;
SELECT * FROM retail_sales LIMIT 10;
```

You should see your data!

### Step 6: Run the Analysis Script

#### Option A: Run the entire script at once

1. In MySQL Workbench, go to **File** → **Open SQL Script**
2. Navigate to and select `retailsalesanalysis_mysql.sql`
3. Make sure `retail_sales_db` is selected in the schema dropdown (top left)
4. Click Execute (⚡) or press `Ctrl+Shift+Enter` to execute all statements

#### Option B: Run queries one by one

1. Open `retailsalesanalysis_mysql.sql` in MySQL Workbench
2. Select each query individually
3. Click Execute (⚡) or press `Ctrl+Enter`

### Step 7: View Results

Each query will display results in the Result Grid below the SQL Editor. You can:
- Export results to CSV
- Copy results
- View in different formats

---

## Troubleshooting

### Issue: "Can't create database 'retail_sales_db'; database exists" (Error 1007)
**Solution:** The database already exists! Just use it:
```sql
USE retail_sales_db;
```
Or drop it first if you want a fresh start:
```sql
DROP DATABASE IF EXISTS retail_sales_db;
CREATE DATABASE retail_sales_db;
USE retail_sales_db;
```

### Issue: "Table doesn't exist"
**Solution:** Make sure you've run `USE retail_sales_db;` and created the table first.

### Issue: "'ascii' codec can't decode byte 0xef" (Encoding Error)
**Solution:** The CSV file has encoding issues. Try these fixes:
1. **Re-save CSV as UTF-8**: Open in Excel → Save As → CSV UTF-8 (Comma delimited)
2. **Or use LOAD DATA INFILE** instead of the wizard (see Method 2 in Step 4)
3. **Or remove BOM**: The file might have a Byte Order Mark. Re-save without BOM.

### Issue: "LOAD DATA LOCAL INFILE file request rejected due to restrictions on access" (Error 2068)
**Solution:** MySQL Workbench restricts local file loading by default. Try these:

**Option 1: Enable in Connection Settings (Recommended)**
1. In MySQL Workbench, go to **Database** → **Manage Connections**
2. Select your connection
3. Click **Advanced** tab
4. Under **Others**, add: `OPT_LOCAL_INFILE=1`
5. Click **OK** and reconnect

**Option 2: Use Table Data Import Wizard Instead**
1. Right-click on `retail_sales` table → **Table Data Import Wizard**
2. Select your CSV file
3. Follow the wizard (this bypasses the restriction)

**Option 3: Use MySQL Command Line**
```bash
mysql -u root -p --local-infile=1 retail_sales_db
```
Then run the LOAD DATA command.

**Option 4: Use Python Script** (See Solution 5 in fix_csv_encoding.md)

### Issue: "Access denied for LOAD DATA"
**Solution:** 
1. Enable local file loading: `SET GLOBAL local_infile = 1;`
2. Or use the Table Data Import Wizard instead

### Issue: "File not found" when importing CSV
**Solution:** 
- Use the full absolute path to your CSV file
- Or use the Table Data Import Wizard (it has a file browser)

### Issue: "RANK() function not recognized"
**Solution:** Make sure you're using MySQL 8.0 or later. Check version:
```sql
SELECT VERSION();
```

### Issue: Import shows wrong number of rows
**Solution:** 
- Check if the CSV has empty rows at the end
- Verify the CSV encoding is UTF-8
- Check for NULL values that might be filtered

### Issue: Date format errors
**Solution:** MySQL expects dates in `YYYY-MM-DD` format. Your CSV should already be in this format.

---

## Quick Reference: MySQL vs PostgreSQL Differences

The MySQL version (`retailsalesanalysis_mysql.sql`) has been converted from PostgreSQL:

| PostgreSQL | MySQL |
|------------|-------|
| `TO_CHAR(sale_date, 'YYYY-MM')` | `DATE_FORMAT(sale_date, '%Y-%m')` |
| `EXTRACT(YEAR FROM sale_date)` | `YEAR(sale_date)` |
| `EXTRACT(MONTH FROM sale_date)` | `MONTH(sale_date)` |
| `EXTRACT(HOUR FROM sale_time)` | `HOUR(sale_time)` |
| `GROUP BY 1` | `GROUP BY category` |
| `\copy` command | `LOAD DATA INFILE` or Import Wizard |

---

## What Each Query Does

1. **Basic Statistics**: Counts total records, unique customers, and categories
2. **Data Quality Check**: Finds records with NULL values
3. **Data Cleaning**: Removes NULL records
4. **Date Filtering**: Shows sales on November 5, 2022
5. **Category Analysis**: Clothing sales in November 2022 with quantity >= 4
6. **Average Age**: Average customer age for Beauty category
7. **High-Value Transactions**: All transactions over $1000
8. **Gender Analysis**: Transaction counts by category and gender
9. **Monthly Trends**: Highest average sales month per year
10. **Top Customers**: Top 5 customers by total sales
11. **Customer Engagement**: Unique customers per category
12. **Time-Based Analysis**: Sales by time of day (Morning/Afternoon/Evening)

---

## Tips for MySQL Workbench

- **Execute Selected**: Highlight a query and press `Ctrl+Enter` to run just that query
- **Execute All**: Press `Ctrl+Shift+Enter` to run all queries
- **Format SQL**: Right-click → Format SQL (or `Ctrl+B`)
- **Export Results**: Right-click on result grid → Export Recordset
- **Save Results**: Results can be exported to CSV, JSON, or Excel

---

## Next Steps

After running all queries successfully:
1. Review the results in each query tab
2. Export any interesting results for further analysis
3. Create visualizations in Excel, Tableau, or Power BI
4. Document your findings

Happy analyzing! 📊
