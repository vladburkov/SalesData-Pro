DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales (
transactions_id	INT PRIMARY KEY,
sale_date DATE,	
sale_time	TIME,
customer_id	INT,
gender	VARCHAR(15),
age	INT,
category VARCHAR(15),	
quantiy	INT,
price_per_unit	FLOAT,
cogs	FLOAT,
total_sale FLOAT
);

SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantiy IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL;

-- Disable safe update mode for this operation
SET SQL_SAFE_UPDATES = 0;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantiy IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL;

-- Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;


SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

SELECT 
  *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND 
    DATE_FORMAT(sale_date, '%Y-%m') = '2022-11'
    AND
    quantiy >= 4;

SELECT 
    category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM retail_sales
GROUP BY category;

SELECT
    ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty';

SELECT * FROM retail_sales
WHERE total_sale > 1000;

SELECT 
    category,
    gender,
    COUNT(*) as total_trans
FROM retail_sales
GROUP BY 
    category,
    gender
ORDER BY category;

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

SELECT 
    customer_id,
    SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

SELECT 
    category,    
    COUNT(DISTINCT customer_id) as cnt_unique_cs
FROM retail_sales
GROUP BY category;

WITH hourly_sale
AS
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
