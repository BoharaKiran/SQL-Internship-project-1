-- 5. Library Management System

-- step 1: Create Database
CREATE DATABASE library_db;
use library_db;

-- step 2: create table Books, Authors, Members, Loans
-- 1. Book table
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(150),
    genre VARCHAR(50),
    published_year INT
);

-- 2. Authers table
CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    author_name VARCHAR(100)
);

-- Bridge Table: Book-Authors (Many-to-Many)
CREATE TABLE book_authors (
    book_id BIGINT UNSIGNED,
    author_id BIGINT UNSIGNED,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);
-- 3. Members table
CREATE TABLE members (
    member_id SERIAL PRIMARY KEY,
    member_name VARCHAR(100),
    email VARCHAR(100),
    join_date DATE
);

-- 4. Loan table
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id BIGINT UNSIGNED,
    member_id BIGINT UNSIGNED,
    issue_date DATE,
    due_date DATE,
    return_date DATE,

    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

-- STEP 3: Insert Sample Data
-- 1.authers
INSERT INTO authors (author_name) VALUES
('J.K. Rowling'),
('George Orwell'),
('Chetan Bhagat');

-- Book-Authors Mapping
INSERT INTO book_authors VALUES
(1, 1),
(2, 2),
(3, 3);

-- 2. books
INSERT INTO books (title, genre, published_year) VALUES
('Harry Potter', 'Fantasy', 1997),
('1984', 'Dystopian', 1949),
('Half Girlfriend', 'Romance', 2014);

-- 3.Members
INSERT INTO members (member_name, email, join_date) VALUES
('Kiran', 'kiran@gmail.com', '2024-01-01'),
('Rahul', 'rahul@gmail.com', '2024-02-10');

-- 4.Loas
INSERT INTO loans (book_id, member_id, issue_date, due_date, return_date) VALUES
(1, 1, '2026-03-01', '2026-03-10', NULL),
(2, 2, '2026-03-05', '2026-03-12', '2026-03-11'),
(3, 1, '2026-03-01', '2026-03-05', NULL);

-- STEP 4: Views
CREATE VIEW borrowed_books AS
SELECT b.title, m.member_name, l.issue_date, l.due_date
FROM loans l
JOIN books b ON l.book_id = b.book_id
JOIN members m ON l.member_id = m.member_id
WHERE l.return_date IS NULL;

CREATE VIEW overdue_books AS
SELECT b.title, m.member_name, l.due_date
FROM loans l
JOIN books b ON l.book_id = b.book_id
JOIN members m ON l.member_id = m.member_id
WHERE l.return_date IS NULL AND l.due_date < CURRENT_DATE;

-- step 5: Trigger (Due Date notifications)
CREATE TABLE due_alerts (
    alert_id SERIAL PRIMARY KEY,
    loan_id INT,
    message TEXT,
    alert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger Function
DELIMITER $$

CREATE TRIGGER due_date_trigger
AFTER INSERT ON loans
FOR EACH ROW
BEGIN
    IF NEW.due_date < CURDATE() THEN
        INSERT INTO due_alerts (loan_id, message)
        VALUES (NEW.loan_id, 'Book is overdue!');
    END IF;
END$$

DELIMITER ;

INSERT INTO loans (book_id, member_id, issue_date, due_date, return_date)
VALUES (1, 1, '2026-03-01', '2026-03-05', NULL);

SELECT * FROM due_alerts;

-- step 6: Reports (Aggregation + JOINs)
-- Total Books Borrowed by Each Member
SELECT m.member_name, COUNT(l.loan_id) AS total_books
FROM loans l
JOIN members m ON l.member_id = m.member_id
GROUP BY m.member_name;

-- Most Borrowed Books
SELECT b.title, COUNT(l.loan_id) AS times_borrowed
FROM loans l
JOIN books b ON l.book_id = b.book_id
GROUP BY b.title
ORDER BY times_borrowed DESC;

SELECT * FROM overdue_books;