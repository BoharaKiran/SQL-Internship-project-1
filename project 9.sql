-- STEP 1: CREATE DATABASE
CREATE DATABASE finance_tracker_db;
USE finance_tracker_db;

-- STEP 2: CREATE TABLES (SCHEMA)
-- Users Table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

-- Income Table
CREATE TABLE income (
    income_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(10,2),
    source VARCHAR(100),
    income_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Categories Table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50)
);

-- Expenses Table
CREATE TABLE expenses (
    expense_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    category_id INT,
    amount DECIMAL(10,2),
    expense_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- STEP 3: INSERT DUMMY DATA
-- Users
INSERT INTO users (name, email) VALUES
('Kiran', 'kiran@gmail.com'),
('Rahul', 'rahul@gmail.com');

-- Categories
INSERT INTO categories (category_name) VALUES
('Food'),
('Transport'),
('Shopping'),
('Bills');

-- Income
INSERT INTO income (user_id, amount, source, income_date) VALUES
(1, 30000, 'Salary', '2024-01-01'),
(1, 5000, 'Freelance', '2024-01-10'),
(2, 25000, 'Salary', '2024-01-01');

-- Expenses
INSERT INTO expenses (user_id, category_id, amount, expense_date) VALUES
(1, 1, 2000, '2024-01-02'),
(1, 2, 1000, '2024-01-03'),
(1, 3, 3000, '2024-01-05'),
(2, 1, 1500, '2024-01-04');

-- STEP 4: MONTHLY EXPENSE SUMMARY
SELECT 
    user_id,
    MONTH(expense_date) AS month,
    SUM(amount) AS total_expense
FROM expenses
GROUP BY user_id, MONTH(expense_date);

-- STEP 5: CATEGORY-WISE SPENDING
SELECT 
    c.category_name,
    SUM(e.amount) AS total_spent
FROM expenses e
JOIN categories c ON e.category_id = c.category_id
GROUP BY c.category_name;

-- STEP 6: CREATE VIEW (BALANCE TRACKING)
CREATE VIEW balance_view AS
SELECT 
    u.user_id,
    u.name,
    IFNULL(SUM(i.amount),0) AS total_income,
    IFNULL(SUM(e.amount),0) AS total_expense,
    (IFNULL(SUM(i.amount),0) - IFNULL(SUM(e.amount),0)) AS balance
FROM users u
LEFT JOIN income i ON u.user_id = i.user_id
LEFT JOIN expenses e ON u.user_id = e.user_id
GROUP BY u.user_id, u.name;

SELECT * FROM balance_view;

-- STEP 7: MONTHLY REPORT
SELECT 
    u.name,
    MONTH(e.expense_date) AS month,
    SUM(e.amount) AS monthly_expense
FROM expenses e
JOIN users u ON e.user_id = u.user_id
GROUP BY u.name, MONTH(e.expense_date);

SELECT * FROM balance_view;