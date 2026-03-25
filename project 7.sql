-- Real Estate Listings and Analytics
-- step 1: Create Database
CREATE DATABASE Real_Estate_db;
use Real_Estate_db;

-- step 2: create table Properties, Agents, Buyers, Transactions
-- 1.Properties table
CREATE TABLE properties (
    property_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    location VARCHAR(100),
    price DECIMAL(12,2),
    listing_date DATE,
    agent_id INT,
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

-- 2.Agents table
CREATE TABLE agents (
    agent_id INT AUTO_INCREMENT PRIMARY KEY,
    agent_name VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100)
);

-- 3.Buyers table
CREATE TABLE buyers (
    buyer_id INT AUTO_INCREMENT PRIMARY KEY,
    buyer_name VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100)
);

-- 4.Transactions table
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    property_id INT,
    buyer_id INT,
    transaction_date DATE,
    sale_price DECIMAL(12,2),
    FOREIGN KEY (property_id) REFERENCES properties(property_id),
    FOREIGN KEY (buyer_id) REFERENCES buyers(buyer_id)
);

-- Step 3: Insert Sample Data
-- Properties
INSERT INTO properties (title, location, price, listing_date, agent_id) VALUES
('2BHK Apartment', 'Rajkot', 2500000, '2025-01-10', 1),
('3BHK Villa', 'Ahmedabad', 7500000, '2025-02-15', 2),
('Office Space', 'Surat', 5000000, '2025-03-01', 1),
('1BHK Flat', 'Rajkot', 1800000, '2025-03-10', 2);

-- Agents
INSERT INTO agents (agent_name, phone, email) VALUES
('Raj Patel', '9876543210', 'raj@gmail.com'),
('Neha Shah', '9123456780', 'neha@gmail.com');

-- buyers
INSERT INTO buyers (buyer_name, phone, email) VALUES
('Amit Kumar', '9999999999', 'amit@gmail.com'),
('Priya Mehta', '8888888888', 'priya@gmail.com');

-- transactions
INSERT INTO transactions (property_id, buyer_id, transaction_date, sale_price) VALUES
(1, 1, '2025-02-01', 2450000),
(2, 2, '2025-03-01', 7400000),
(3, 1, '2025-03-20', 5100000);

-- Step 4: Queries
SELECT location, AVG(price) AS avg_price
FROM properties
GROUP BY location;

-- STEP 5:views for high-demand areas
CREATE VIEW high_demand_areas AS
SELECT location, AVG(price) AS avg_price
FROM properties
GROUP BY location
HAVING AVG(price) > 3000000;

SELECT * FROM high_demand_areas;

-- STEP 6: price trend reports using window functions
SELECT 
    location,
    listing_date,
    price,
    AVG(price) OVER (PARTITION BY location ORDER BY listing_date) AS running_avg_price
FROM properties;

-- STEP 7: Monthly Trend Report
SELECT 
    DATE_FORMAT(listing_date, '%Y-%m') AS month,
    AVG(price) AS avg_price
FROM properties
GROUP BY month
ORDER BY month;

SELECT * FROM properties;

-- STEP 8: Export Data to CSV
SELECT * FROM properties
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/properties.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';