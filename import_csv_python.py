#!/usr/bin/env python3
"""
Python script to import RetailSalesAnalysisData.csv into MySQL
This bypasses MySQL Workbench's LOAD DATA LOCAL restrictions
"""

import pandas as pd
import mysql.connector
from sqlalchemy import create_engine, text
import sys

# Configuration
CSV_FILE = '/Users/vladburkov/Downloads/RetailSaleAnalysisData.csv'
DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = 'Vl4dvlad'  # Enter your MySQL password here
DB_NAME = 'retail_sales_db'
TABLE_NAME = 'retail_sales'

def import_csv_to_mysql():
    """Import CSV file to MySQL database"""
    
    print("📖 Reading CSV file...")
    try:
        # Read CSV file
        df = pd.read_csv(CSV_FILE, encoding='utf-8')
        print(f"✅ Read {len(df)} rows from CSV")
        
        # Remove BOM if present in column names
        df.columns = df.columns.str.replace('\ufeff', '')
        
        # Display first few rows
        print("\nFirst 5 rows:")
        print(df.head())
        
    except FileNotFoundError:
        print(f"❌ Error: File not found at {CSV_FILE}")
        print("Please update CSV_FILE path in the script")
        return False
    except Exception as e:
        print(f"❌ Error reading CSV: {e}")
        return False
    
    print("\n🔌 Connecting to MySQL...")
    try:
        # Create connection string
        connection_string = f'mysql+mysqlconnector://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}'
        engine = create_engine(connection_string)
        
        # Test connection
        with engine.connect() as conn:
            print("✅ Connected to MySQL")
        
    except Exception as e:
        print(f"❌ Error connecting to MySQL: {e}")
        print("\nMake sure:")
        print("1. MySQL server is running")
        print("2. Database 'retail_sales_db' exists")
        print("3. Table 'retail_sales' exists")
        print("4. MySQL password is correct")
        return False
    
    print("\n📊 Importing data to MySQL...")
    try:
        # Import to database (replace existing data)
        df.to_sql(TABLE_NAME, engine, if_exists='replace', index=False, method='multi', chunksize=1000)
        print(f"✅ Successfully imported {len(df)} rows to {DB_NAME}.{TABLE_NAME}")
        
        # Verify import
        with engine.connect() as conn:
            result = conn.execute(text(f"SELECT COUNT(*) as count FROM {TABLE_NAME}"))
            count = result.fetchone()[0]
            print(f"✅ Verified: {count} rows in database")
        
        return True
        
    except Exception as e:
        print(f"❌ Error importing data: {e}")
        return False

if __name__ == "__main__":
    print("=" * 60)
    print("Retail Sales Data Import Script")
    print("=" * 60)
    
    # Check if password is set
    if DB_PASSWORD == '':
        print("\n⚠️  Warning: MySQL password not set!")
        print("Please edit this script and set DB_PASSWORD")
        print("Or enter password when prompted:")
        DB_PASSWORD = input("MySQL password: ")
    
    success = import_csv_to_mysql()
    
    if success:
        print("\n" + "=" * 60)
        print("✅ Import completed successfully!")
        print("=" * 60)
        print("\nNext steps:")
        print("1. Open MySQL Workbench")
        print("2. Run: SELECT COUNT(*) FROM retail_sales;")
        print("3. Run the analysis script: retailsalesanalysis_mysql.sql")
    else:
        print("\n" + "=" * 60)
        print("❌ Import failed. Please check the errors above.")
        print("=" * 60)
        sys.exit(1)
