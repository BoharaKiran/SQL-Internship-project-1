-- Student Result Processing System
-- step 1:create database
CREATE DATABASE student_results;
USE student_results;

-- step 2:create table Students, Courses, Grades, Semesters
-- Students table
CREATE TABLE students(
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    enrollment_year YEAR
);

-- Courses table
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    credits INT NOT NULL
);

-- Semesters table
CREATE TABLE semesters (
    semester_id INT AUTO_INCREMENT PRIMARY KEY,
    semester_name VARCHAR(50) NOT NULL,
    year YEAR NOT NULL
);

-- Grades table
CREATE TABLE grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    semester_id INT NOT NULL,
    marks INT CHECK (marks BETWEEN 0 AND 100),
    grade CHAR(2),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (semester_id) REFERENCES semesters(semester_id)
);

-- step 3:Insert Sample Data
INSERT INTO students (student_name, email, enrollment_year) VALUES
('Alice Johnson', 'alice@example.com', 2023),
('Bob Kumar', 'bob@example.com', 2022);

INSERT INTO courses (course_name, credits) VALUES
('Mathematics', 4),
('Physics', 3),
('Computer Science', 3);

INSERT INTO semesters (semester_name, year) VALUES
('Semester 1', 2023),
('Semester 2', 2024);

INSERT INTO grades (student_id, course_id, semester_id, marks) VALUES
(1, 1, 1, 85),
(1, 2, 1, 78),
(1, 3, 1, 92),
(2, 1, 1, 60),
(2, 2, 1, 55),
(2, 3, 1, 70);

-- stepv 4:GPA Calculation & Grade Assignment
-- Assign Grades:
SET SQL_SAFE_UPDATES = 0;

UPDATE grades
SET grade = CASE
    WHEN marks >= 90 THEN 'A+'
    WHEN marks >= 80 THEN 'A'
    WHEN marks >= 70 THEN 'B+'
    WHEN marks >= 60 THEN 'B'
    WHEN marks >= 50 THEN 'C'
    ELSE 'F'
END;

-- GPA Query
SELECT g.student_id, s.student_name, SUM(c.credits * 
    CASE g.grade
        WHEN 'A+' THEN 4.0
        WHEN 'A' THEN 3.7
        WHEN 'B+' THEN 3.3
        WHEN 'B' THEN 3.0
        WHEN 'C' THEN 2.0
        ELSE 0
    END) / SUM(c.credits) AS GPA
FROM grades g
JOIN courses c ON g.course_id = c.course_id
JOIN students s ON g.student_id = s.student_id
GROUP BY g.student_id;

-- step 5:Rank List Using Window Function
SELECT 
    g.student_id, 
    s.student_name,
    SUM(c.credits * 
        CASE g.grade
            WHEN 'A+' THEN 4.0
            WHEN 'A' THEN 3.7
            WHEN 'B+' THEN 3.3
            WHEN 'B' THEN 3.0
            WHEN 'C' THEN 2.0
            ELSE 0
        END
    ) / SUM(c.credits) AS GPA
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN courses c ON g.course_id = c.course_id
GROUP BY g.student_id;

SELECT 
    student_id, 
    student_name, 
    GPA,
    RANK() OVER (ORDER BY GPA DESC) AS `rank`
FROM (
    SELECT 
        g.student_id, 
        s.student_name,
        SUM(c.credits * 
            CASE g.grade
                WHEN 'A+' THEN 4.0
                WHEN 'A' THEN 3.7
                WHEN 'B+' THEN 3.3
                WHEN 'B' THEN 3.0
                WHEN 'C' THEN 2.0
                ELSE 0
            END
        ) / SUM(c.credits) AS GPA
    FROM grades g
    JOIN students s ON g.student_id = s.student_id
    JOIN courses c ON g.course_id = c.course_id
    GROUP BY g.student_id, s.student_name
) AS semester_gpa;

-- step 6: for Automatic GPA Update
-- Change delimiter
DELIMITER $$

-- Create trigger
CREATE TRIGGER update_grade_after_insert
AFTER INSERT ON grades
FOR EACH ROW
BEGIN
    DECLARE g CHAR(2);
    SET g = CASE
        WHEN NEW.marks >= 90 THEN 'A+'
        WHEN NEW.marks >= 80 THEN 'A'
        WHEN NEW.marks >= 70 THEN 'B+'
        WHEN NEW.marks >= 60 THEN 'B'
        WHEN NEW.marks >= 50 THEN 'C'
        ELSE 'F'
    END;
    
    UPDATE grades SET grade = g WHERE grade_id = NEW.grade_id;
END $$

-- Reset delimiter
DELIMITER ;

-- step 7:Export Semester-wise Summary
SELECT s.student_name, c.course_name, g.marks, g.grade
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN courses c ON g.course_id = c.course_id
WHERE g.semester_id = 1;