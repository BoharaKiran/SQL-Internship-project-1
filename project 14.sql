-- Crime Record & Investigation Database
-- step 1:create database
CREATE DATABASE crime_db;
use crime_db;

-- step 2:create table Cases, Suspects, Officers, Evidence
-- Officers Table
CREATE TABLE officers (
    officer_id INT AUTO_INCREMENT PRIMARY KEY,
    officer_name VARCHAR(100) NOT NULL,
    `rank` VARCHAR(50),
    assigned_cases INT DEFAULT 0
);
-- Cases Table
CREATE TABLE cases (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    case_name VARCHAR(100) NOT NULL,
    case_type VARCHAR(50),
    status ENUM('Open', 'Closed', 'Under Investigation') DEFAULT 'Open',
    lead_officer_id INT,
    date_reported DATE,
    FOREIGN KEY (lead_officer_id) REFERENCES officers(officer_id)
);

-- Suspects Table
CREATE TABLE suspects (
    suspect_id INT AUTO_INCREMENT PRIMARY KEY,
    suspect_name VARCHAR(100) NOT NULL,
    age INT,
    gender ENUM('Male','Female','Other'),
    case_id INT,
    FOREIGN KEY (case_id) REFERENCES cases(case_id)
);

-- Evidence Table
CREATE TABLE evidence (
    evidence_id INT AUTO_INCREMENT PRIMARY KEY,
    evidence_name VARCHAR(100),
    evidence_type VARCHAR(50),
    case_id INT,
    date_collected DATE,
    status ENUM('Collected', 'Submitted', 'Verified') DEFAULT 'Collected',
    FOREIGN KEY (case_id) REFERENCES cases(case_id)
);

-- step 3:Indexing
CREATE INDEX idx_case_id ON cases(case_id);
CREATE INDEX idx_suspect_name ON suspects(suspect_name);
CREATE INDEX idx_officer_name ON officers(officer_name);

-- step 4:Sample Data Insertion
-- Officers
INSERT INTO officers (officer_name, `rank`) VALUES
('John Smith', 'Inspector'),
('Alice Brown', 'Detective'),
('Michael Johnson', 'Sergeant');

-- Cases
INSERT INTO cases (case_name, case_type, status, lead_officer_id, date_reported) VALUES
('Burglary at Elm Street', 'Burglary', 'Open', 1, '2026-03-01'),
('Homicide in Downtown', 'Homicide', 'Under Investigation', 2, '2026-03-10'),
('Cyber Fraud Case', 'Cyber Crime', 'Closed', 3, '2026-02-20');

-- Suspects
INSERT INTO suspects (suspect_name, age, gender, case_id) VALUES
('Tom Hardy', 34, 'Male', 1),
('Sarah Connor', 28, 'Female', 2),
('Rick Sanchez', 45, 'Male', 3);

-- Evidence
INSERT INTO evidence (evidence_name, evidence_type, case_id, date_collected, status) VALUES
('Fingerprint Sample', 'Forensic', 1, '2026-03-02', 'Submitted'),
('CCTV Footage', 'Video', 2, '2026-03-11', 'Collected'),
('Hard Drive', 'Digital', 3, '2026-02-21', 'Verified');

-- step 5:Queries for Analysis
-- List all open cases
SELECT case_id, case_name, status
FROM cases
WHERE status = 'Open';

-- Suspects in a specific case
SELECT s.suspect_name, s.age, s.gender, c.case_name
FROM suspects s
JOIN cases c ON s.case_id = c.case_id
WHERE c.case_id = 1;

-- Officer workload
SELECT o.officer_name, COUNT(c.case_id) AS total_cases
FROM officers o
LEFT JOIN cases c ON o.officer_id = c.lead_officer_id
GROUP BY o.officer_name;

-- Evidence chain status
SELECT e.evidence_name, e.status, c.case_name
FROM evidence e
JOIN cases c ON e.case_id = c.case_id;

-- step 6:Views
-- Officer Workload View
CREATE OR REPLACE VIEW officer_workload AS
SELECT o.officer_name, o.rank, COUNT(c.case_id) AS total_cases
FROM officers o
LEFT JOIN cases c ON o.officer_id = c.lead_officer_id
GROUP BY o.officer_name, o.rank;

-- Solved Cases View
CREATE OR REPLACE VIEW solved_cases AS
SELECT case_id, case_name, status, date_reported
FROM cases
WHERE status = 'Closed';

-- step 7:Trigger Example
DELIMITER $$

CREATE TRIGGER update_officer_cases
AFTER INSERT ON cases
FOR EACH ROW
BEGIN
    UPDATE officers
    SET assigned_cases = assigned_cases + 1
    WHERE officer_id = NEW.lead_officer_id;
END$$

DELIMITER ;

-- step 8:Export Investigation Summary
-- Summary: Case, Lead Officer, Number of Suspects, Evidence Collected
SELECT 
    c.case_id, 
    c.case_name, 
    o.officer_name AS lead_officer,
    COUNT(DISTINCT s.suspect_id) AS num_suspects,
    COUNT(DISTINCT e.evidence_id) AS num_evidence
FROM cases c
LEFT JOIN officers o ON c.lead_officer_id = o.officer_id
LEFT JOIN suspects s ON c.case_id = s.case_id
LEFT JOIN evidence e ON c.case_id = e.case_id
GROUP BY c.case_id, c.case_name, o.officer_name;
