-- SQL ETL Pipeline Simulation
-- STEP 1: Create Database
CREATE DATABASE etl_project;
USE etl_project;

-- CREATE TABLE staging_sales
CREATE TABLE staging_sales (
    order_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    quantity INT,
    price DECIMAL(10,2),
    order_date DATE
);
DESCRIBE staging_sales;
-- STEP 3: IMPORT CSV FILE
SELECT * FROM staging_sales;

-- STEP 4: DATA CLEANING
SET SQL_SAFE_UPDATES = 0;

-- Remove NULL values
DELETE FROM staging_sales
WHERE order_id IS NULL OR product_name IS NULL;

-- Remove duplicates
DELETE s1 FROM staging_sales s1
JOIN staging_sales s2 
ON s1.order_id = s2.order_id
AND s1.product_name = s2.product_name
AND s1.quantity = s2.quantity
AND s1.price = s2.price
AND s1.order_date = s2.order_date
AND s1.order_id > s2.order_id;


-- STEP 5: CREATE PRODUCTION TABLE
CREATE TABLE sales1 (
    order_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    quantity INT,
    total_amount DECIMAL(10,2),
    order_date DATE
);

-- STEP 6: TRANSFORM + LOAD DATA
INSERT INTO sales1 (order_id, product_name, category, quantity, total_amount, order_date)
SELECT 
    order_id,
    product_name,
    category,
    quantity,
    quantity * price AS total_amount,
    order_date
FROM staging_sales;

-- STEP 7: CREATE AUDIT TABLE
CREATE TABLE etl_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    action VARCHAR(50),
    record_count INT,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- STEP 8: INSERT LOG ENTRY
INSERT INTO etl_logs (action, record_count)
SELECT 'Data Loaded', COUNT(*) FROM sales;

-- STEP 9: CREATE TRIGGER
CREATE TRIGGER after_sales_insert
AFTER INSERT ON sales
FOR EACH ROW
INSERT INTO etl_logs (action, record_count)
VALUES ('New Record Inserted', 1);

-- STEP 10: CLEANUP STAGING TABLE
TRUNCATE TABLE staging_sales;

-- STEP 11: EXPORT DATA
SELECT * FROM sales1;
