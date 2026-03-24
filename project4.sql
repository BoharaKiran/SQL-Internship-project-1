-- 4.Inventory and Warehouse Management System

-- step 1: Create Database
CREATE DATABASE warehouse_db;
USE warehouse_db;

-- step 2: schema for Products, Warehouses, Suppliers, Stock
-- 1.products table
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

-- warehouses table
CREATE TABLE warehouses (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_name VARCHAR(100),
    location VARCHAR(100)
);

-- suppliers table
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100),
    contact_email VARCHAR(100)
);

-- stock table
CREATE TABLE stock (
    stock_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    warehouse_id INT,
    supplier_id INT,
    quantity INT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- step 2: Insert sample inventory records
-- Insert products
INSERT INTO products (product_name, category, price) VALUES
('Laptop', 'Electronics', 50000),
('Mobile', 'Electronics', 20000),
('Chair', 'Furniture', 3000);

-- Insert warehouses
INSERT INTO warehouses (warehouse_name, location) VALUES
('Main Warehouse', 'Ahmedabad'),
('Backup Warehouse', 'Rajkot');

-- Insert suppliers
INSERT INTO suppliers (supplier_name, contact_email) VALUES
('Tech Supplier', 'tech@gmail.com'),
('Furniture Supplier', 'furniture@gmail.com');

-- Insert stock data
INSERT INTO stock (product_id, warehouse_id, supplier_id, quantity) VALUES
(1, 1, 1, 50),
(2, 1, 1, 20),
(3, 2, 2, 10);

-- step 3: queries to check stock levels and reorder alerts
-- 1. Check Stock Levels
-- Displays products with quantity less than 15
SELECT p.product_name, w.warehouse_name, s.quantity
FROM stock s
JOIN products p ON s.product_id = p.product_id
JOIN warehouses w ON s.warehouse_id = w.warehouse_id;

-- 2. Low Stock Alert (Less than 15)
SELECT p.product_name, s.quantity
FROM stock s
JOIN products p ON s.product_id = p.product_id
WHERE s.quantity < 15;

-- 3. Total Stock per Product
SELECT p.product_name, SUM(s.quantity) AS total_stock
FROM stock s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name;

-- step 4: triggers for low-stock notification
CREATE TABLE low_stock_alert (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    quantity INT,
    alert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE TRIGGER low_stock_trigger
AFTER INSERT ON stock
FOR EACH ROW
BEGIN
    IF NEW.quantity < 15 THEN
        INSERT INTO low_stock_alert (product_id, quantity)
        VALUES (NEW.product_id, NEW.quantity);
    END IF;
END$$

DELIMITER ;

-- step 5: Create stored procedure to transfer stock
DELIMITER $$

CREATE PROCEDURE transfer_stock(
    IN p_product_id INT,
    IN from_warehouse INT,
    IN to_warehouse INT,
    IN qty INT
)
BEGIN
    -- Reduce stock
    UPDATE stock
    SET quantity = quantity - qty
    WHERE product_id = p_product_id AND warehouse_id = from_warehouse;

    -- Add stock
    UPDATE stock
    SET quantity = quantity + qty
    WHERE product_id = p_product_id AND warehouse_id = to_warehouse;
END$$

DELIMITER ;

CALL transfer_stock(1, 1, 2, 5);

-- step 6:VIEW: Stock Summary
CREATE VIEW stock_summary AS
SELECT p.product_name, SUM(s.quantity) AS total_stock
FROM stock s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name;
