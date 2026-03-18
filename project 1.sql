CREATE DATABASE online_retail;
USE online_retail;

CREATE TABLE Customers (
    customer_id   INT PRIMARY KEY AUTO_INCREMENT,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    phone         VARCHAR(15),
    city          VARCHAR(50),
    created_at    DATE
);

CREATE TABLE Products (
    product_id    INT PRIMARY KEY AUTO_INCREMENT,
    product_name  VARCHAR(100) NOT NULL,
    category      VARCHAR(50),
    price         DECIMAL(10, 2) NOT NULL,
    stock_qty     INT DEFAULT 0
);

CREATE TABLE Orders (
    order_id      INT PRIMARY KEY AUTO_INCREMENT,
    customer_id   INT,
    order_date    DATE NOT NULL,
    status        VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Order_Items (
    item_id       INT PRIMARY KEY AUTO_INCREMENT,
    order_id      INT,
    product_id    INT,
    quantity      INT NOT NULL,
    unit_price    DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Payments (
    payment_id    INT PRIMARY KEY AUTO_INCREMENT,
    order_id      INT,
    payment_date  DATE,
    amount        DECIMAL(10, 2),
    method        VARCHAR(30),   -- 'UPI', 'Card', 'COD'
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

INSERT INTO Customers (full_name, email, phone, city, created_at) VALUES
('Raj Sharma',  'raj@gmail.com',  '9876543210', 'Mumbai',    '2024-01-10'),
('Vashu Mehta',   'vashu@gmail.com',  '9123456780', 'Delhi',     '2024-02-15'),
('Amisha Patel',    'amisha@gmail.com',   '9988776655', 'Ahmedabad', '2024-03-01'),
('Suraj Rao',     'suraj@gmail.com',  '9001122334', 'Bangalore', '2024-03-20'),
('Vani Gupta',   'vani@gmail.com',  '9870001122', 'Pune',      '2024-04-05');

INSERT INTO Products (product_name, category, price, stock_qty) VALUES
('iPhone 15',        'Electronics',  79000.00, 50),
('Nike Shoes',       'Footwear',      4500.00, 200),
('Sony Headphones',  'Electronics',   3200.00, 80),
('Levis Jeans',      'Clothing',      2500.00, 150),
('Dell Laptop',        'Electronics', 55000.00, 30);

INSERT INTO Orders (customer_id, order_date, status) VALUES
(1, '2024-04-01', 'Delivered'),
(2, '2024-04-03', 'Delivered'),
(3, '2024-04-05', 'Shipped'),
(1, '2024-04-10', 'Pending'),
(4, '2024-04-12', 'Delivered');

INSERT INTO Order_Items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 79000.00),
(1, 3, 2,  3200.00),
(2, 2, 1,  4500.00),
(3, 5, 1, 55000.00),
(4, 4, 2,  2500.00),
(5, 2, 3,  4500.00);

INSERT INTO Payments (order_id, payment_date, amount, method) VALUES
(1, '2024-04-01', 85400.00, 'Card'),
(2, '2024-04-03',  4500.00, 'UPI'),
(3, '2024-04-05', 55000.00, 'Card'),
(5, '2024-04-12', 13500.00, 'COD');

-- Q1: Total sales revenue
SELECT SUM(amount) AS total_revenue
FROM Payments;

-- Q2: Top selling products
SELECT p.product_name,
       SUM(oi.quantity) AS total_sold
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC;

-- Q3: Orders per customer
SELECT c.full_name,
       COUNT(o.order_id) AS total_orders
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.full_name
ORDER BY total_orders DESC;

-- Q4: Revenue by category
SELECT p.category,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- Q5: Monthly sales trend
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       COUNT(order_id) AS total_orders
FROM Orders
GROUP BY month
ORDER BY month;

CREATE VIEW Sales_Report AS
SELECT
    o.order_id,
    c.full_name        AS customer,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS total_amount,
    pay.method         AS payment_method,
    o.status
FROM Orders o
JOIN Customers c    ON o.customer_id   = c.customer_id
JOIN Order_Items oi ON o.order_id      = oi.order_id
JOIN Products p     ON oi.product_id   = p.product_id
LEFT JOIN Payments pay ON o.order_id   = pay.order_id;

-- Use the view
SELECT * FROM Sales_Report;