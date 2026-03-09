#!/bin/bash

# Retail Sales Database Setup Script
# This script creates the database, imports the CSV, and runs the analysis

echo "Creating database 'retail_sales_db'..."
createdb retail_sales_db 2>/dev/null || echo "Database may already exist or PostgreSQL not running"

echo "Creating table and importing CSV..."
psql retail_sales_db << EOF
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

\copy retail_sales FROM 'RetailSalesAnalysisData.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
EOF

echo "Running analysis script..."
psql retail_sales_db -f retailsalesanalysis.sql

echo "Done! Check the output above for results."
