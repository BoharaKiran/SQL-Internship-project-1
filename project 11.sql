-- HOSPITAL MANAGEMENT SYSTEM DATABASE
-- Step 1: Create Database
CREATE DATABASE hospital_db;
USE hospital_db;

-- Step 2: Create Tables
-- 1. Patients Table
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    phone VARCHAR(15),
    address VARCHAR(255)
);

-- 2. Doctors Table
CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    specialization VARCHAR(100),
    phone VARCHAR(15)
);

-- 3. Visits Table (Appointments)
CREATE TABLE visits (
    visit_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    visit_date DATE,
    diagnosis VARCHAR(255),
    status VARCHAR(20) DEFAULT 'Admitted',
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

-- 4. Bills Table
CREATE TABLE bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    visit_id INT,
    consultation_fee DECIMAL(10,2),
    medicine_charges DECIMAL(10,2),
    room_charges DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    payment_status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (visit_id) REFERENCES visits(visit_id)
);

-- Step 3: Insert Sample Data
-- Patients
INSERT INTO patients (name, age, gender, phone, address) VALUES
('Amit Sharma', 30, 'Male', '9876543210', 'Delhi'),
('Priya Patel', 25, 'Female', '9123456780', 'Ahmedabad'),
('Rahul Verma', 40, 'Male', '9988776655', 'Mumbai');

-- Doctors
INSERT INTO doctors (name, specialization, phone) VALUES
('Dr. Mehta', 'Cardiologist', '9001112233'),
('Dr. Singh', 'Orthopedic', '9011122233'),
('Dr. Shah', 'General Physician', '9022233344');

-- Visits
INSERT INTO visits (patient_id, doctor_id, visit_date, diagnosis) VALUES
(1, 1, '2026-03-20', 'Heart Checkup'),
(2, 3, '2026-03-21', 'Fever'),
(3, 2, '2026-03-22', 'Fracture');

-- Bills
INSERT INTO bills (visit_id, consultation_fee, medicine_charges, room_charges)
VALUES
(1, 500, 300, 1000),
(2, 300, 150, 0),
(3, 700, 500, 2000);

-- Step 4: Stored Procedure (Billing Calculation)
DELIMITER $$

CREATE PROCEDURE calculate_total_bill(IN v_id INT)
BEGIN
    UPDATE bills
    SET total_amount = consultation_fee + medicine_charges + room_charges
    WHERE visit_id = v_id;
END $$

DELIMITER ;

-- Execute Procedure
CALL calculate_total_bill(1);
CALL calculate_total_bill(2);
CALL calculate_total_bill(3);

-- Step 5: Trigger (Auto Update Status on Discharge)
DELIMITER $$

CREATE TRIGGER discharge_patient
BEFORE UPDATE ON visits
FOR EACH ROW
BEGIN
    IF NEW.status = 'Discharged' THEN
        UPDATE bills
        SET payment_status = 'Paid'
        WHERE visit_id = NEW.visit_id;
    END IF;
END $$

DELIMITER ;

-- Example Update (Trigger Test)
UPDATE visits
SET status = 'Discharged'
WHERE visit_id = 1;

-- Step 6: Queries (Appointments & Payments)
-- 1. View All Appointments
SELECT 
    v.visit_id,
    p.name AS patient_name,
    d.name AS doctor_name,
    v.visit_date,
    v.diagnosis,
    v.status
FROM visits v
JOIN patients p ON v.patient_id = p.patient_id
JOIN doctors d ON v.doctor_id = d.doctor_id;

-- 2. View Billing Details
SELECT 
    b.bill_id,
    p.name AS patient_name,
    b.total_amount,
    b.payment_status
FROM bills b
JOIN visits v ON b.visit_id = v.visit_id
JOIN patients p ON v.patient_id = p.patient_id;

-- 3. Pending Payments
SELECT * FROM bills
WHERE payment_status = 'Pending';

-- Step 7: Reports
-- 1. Patient Visit Report
SELECT 
    p.name,
    COUNT(v.visit_id) AS total_visits
FROM patients p
LEFT JOIN visits v ON p.patient_id = v.patient_id
GROUP BY p.name;

-- 2. Doctor Performance Report
SELECT 
    d.name,
    COUNT(v.visit_id) AS total_patients
FROM doctors d
LEFT JOIN visits v ON d.doctor_id = v.doctor_id
GROUP BY d.name;

-- 3. Revenue Report
SELECT 
    SUM(total_amount) AS total_revenue
FROM bills;