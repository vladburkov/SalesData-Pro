# Fix CSV Encoding Error in MySQL Workbench

## Error: 'ascii' codec can't decode byte 0xef

This error occurs when MySQL Workbench tries to read a UTF-8 encoded file (possibly with BOM) as ASCII.

## Solution 1: Re-save CSV as UTF-8 (Recommended)

### Using Excel:
1. Open `RetailSalesAnalysisData.csv` in Excel
2. Go to **File** → **Save As**
3. Choose **CSV UTF-8 (Comma delimited) (*.csv)**
4. Save the file (you can overwrite the original)
5. Try importing again in MySQL Workbench

### Using TextEdit (Mac):
1. Open `RetailSalesAnalysisData.csv` in TextEdit
2. Go to **Format** → **Make Plain Text** (if needed)
3. Go to **File** → **Save**
4. In the save dialog, click **Advanced Options**
5. Select **UTF-8** encoding
6. Uncheck "Add .txt extension"
7. Save
8. Try importing again

### Using VS Code or Cursor:
1. Open `RetailSalesAnalysisData.csv`
2. Click on encoding in bottom right (might say "UTF-8" or "UTF-8 with BOM")
3. Select **Save with Encoding** → **UTF-8**
4. Try importing again

## Solution 2: Use LOAD DATA INFILE Instead

If the wizard still fails, use SQL directly:

```sql
USE retail_sales_db;

-- First, make sure local_infile is enabled
SET GLOBAL local_infile = 1;

-- Then load the data (adjust path to your actual file location)
LOAD DATA LOCAL INFILE '/Users/vladburkov/SalesData-Pro/RetailSalesAnalysisData.csv'
INTO TABLE retail_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(transactions_id, sale_date, sale_time, customer_id, gender, age, category, quantity, price_per_unit, cogs, total_sale);
```

**Note:** Replace `/Users/vladburkov/SalesData-Pro/RetailSalesAnalysisData.csv` with your actual file path.

## Solution 3: Remove BOM (Byte Order Mark)

If your file has a BOM (the 0xef byte), remove it:

### Using Python:
```python
import codecs

# Read file
with open('RetailSalesAnalysisData.csv', 'rb') as f:
    content = f.read()

# Remove BOM if present
if content.startswith(codecs.BOM_UTF8):
    content = content[3:]

# Write back without BOM
with open('RetailSalesAnalysisData.csv', 'wb') as f:
    f.write(content)
```

### Using command line (Mac):
```bash
# Remove BOM
sed -i '' '1s/^\xEF\xBB\xBF//' RetailSalesAnalysisData.csv
```

## Solution 4: Use MySQL Command Line Instead

If MySQL Workbench continues to have issues:

```bash
mysql -u root -p retail_sales_db

# Then in MySQL:
LOAD DATA LOCAL INFILE '/Users/vladburkov/SalesData-Pro/RetailSalesAnalysisData.csv'
INTO TABLE retail_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

## Solution 5: Import via Python Script

Create a Python script to import:

```python
import pandas as pd
import mysql.connector
from sqlalchemy import create_engine

# Read CSV
df = pd.read_csv('RetailSalesAnalysisData.csv', encoding='utf-8')

# Remove BOM if present in column names
df.columns = df.columns.str.replace('\ufeff', '')

# Connect to MySQL
engine = create_engine('mysql+mysqlconnector://root:yourpassword@localhost/retail_sales_db')

# Import to database
df.to_sql('retail_sales', engine, if_exists='replace', index=False)

print("Import complete!")
```

## Quick Fix Checklist

1. ✅ Re-save CSV as UTF-8 (without BOM)
2. ✅ Try MySQL Workbench import wizard again
3. ✅ If still fails, use LOAD DATA INFILE SQL command
4. ✅ Verify data imported correctly: `SELECT COUNT(*) FROM retail_sales;`

## Verify Import Success

After importing, check:
```sql
SELECT COUNT(*) as total_records FROM retail_sales;
SELECT * FROM retail_sales LIMIT 5;
```

You should see your data!
