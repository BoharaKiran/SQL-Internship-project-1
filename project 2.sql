-- Create Database
CREATE DATABASE employee_tracker;
USE employee_tracker;


-- 1. Departments Table

CREATE TABLE departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,  
    dept_name VARCHAR(50)                    
);


-- 2. Roles Table

CREATE TABLE roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,  
    role_name VARCHAR(50),                   
    salary DECIMAL(10,2)                     
);


-- 3. Employees Table

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,   
    emp_name VARCHAR(100),                   
    dept_id INT,                             
    role_id INT,                            
    join_date DATE,                          
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);


-- 4. Attendance Table

CREATE TABLE attendance (
    att_id INT PRIMARY KEY AUTO_INCREMENT,   
    emp_id INT,                              
    att_date DATE,                           
    check_in TIME,                           
    check_out TIME,                          
    status VARCHAR(20),                      
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);


-- 5. Insert Dummy Data

INSERT INTO departments (dept_name)
VALUES ('HR'), ('IT'), ('Sales'), ('Finance');

INSERT INTO roles (role_name, salary)
VALUES 
('Manager', 60000),
('Developer', 40000),
('Analyst', 35000),
('Clerk', 20000);

INSERT INTO employees (emp_name, dept_id, role_id, join_date)
VALUES 
('Rahul', 1, 1, '2023-01-10'),
('Priya', 2, 2, '2023-03-15'),
('Amit', 3, 3, '2023-05-20');


-- 6. Insert Attendance

INSERT INTO attendance (emp_id, att_date, check_in, check_out, status)
VALUES 
(1, '2026-03-01', '09:10:00', '18:00:00', 'Present'),
(2, '2026-03-01', '09:45:00', '18:00:00', 'Late'),
(3, '2026-03-01', '09:00:00', '17:30:00', 'Present');


-- 7. Queries


-- Monthly attendance count
SELECT emp_id, COUNT(*) AS total_days
FROM attendance
WHERE status = 'Present'
GROUP BY emp_id;

-- Late arrivals
SELECT * FROM attendance
WHERE check_in > '09:30:00';


-- 8. Trigger (Auto status)

DELIMITER $$

CREATE TRIGGER trg_late_check
BEFORE INSERT ON attendance
FOR EACH ROW
BEGIN
    IF NEW.check_in > '09:30:00' THEN
        SET NEW.status = 'Late';
    ELSE
        SET NEW.status = 'Present';
    END IF;
END$$

DELIMITER ;


-- 9. Function (Work Hours)

DELIMITER $$

CREATE FUNCTION work_hours(in_time TIME, out_time TIME)
RETURNS TIME
DETERMINISTIC
BEGIN
    RETURN TIMEDIFF(out_time, in_time);
END$$

DELIMITER ;

-- Use function
SELECT emp_id, work_hours(check_in, check_out) AS hours
FROM attendance;


-- 10. Report Query

SELECT e.emp_name, COUNT(a.att_id) AS days_present
FROM employees e
JOIN attendance a ON e.emp_id = a.emp_id
WHERE a.status = 'Present'
GROUP BY e.emp_name;


