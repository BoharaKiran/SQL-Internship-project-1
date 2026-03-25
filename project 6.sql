-- Airline Reservation System
-- step 1: Create Database
CREATE DATABASE Airline_db;
use Airline_db;

-- step 2: create table Flights, Customers, Bookings, Seats
-- 1.Flights table
CREATE TABLE flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_name VARCHAR(50),
    source VARCHAR(50),
    destination VARCHAR(50),
    departure_time DATETIME,
    arrival_time DATETIME,
    total_seats INT
);

-- 2.Customers Table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(15)
);

-- 3.Seats Table
CREATE TABLE seats (
    seat_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT,
    seat_number VARCHAR(5),
    status VARCHAR(20) DEFAULT 'Available',
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

-- 4.Bookings Table
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    flight_id INT,
    seat_id INT,
    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Confirmed',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    FOREIGN KEY (seat_id) REFERENCES seats(seat_id)
);

-- Step 3: Insert Sample Data
INSERT INTO flights (flight_name, source, destination, departure_time, arrival_time, total_seats)
VALUES ('Air India 101', 'Delhi', 'Mumbai', '2026-04-01 10:00:00', '2026-04-01 12:00:00', 100);

INSERT INTO customers (name, email, phone)
VALUES ('Kiran', 'kiran@email.com', '9876543210');

INSERT INTO seats (flight_id, seat_number)
VALUES (1, 'A1'), (1, 'A2'), (1, 'A3');

-- Step 4: Queries
-- Available Seats
SELECT * FROM seats
WHERE flight_id = 1 AND status = 'Available';

-- Flight Search
SELECT * FROM flights
WHERE source = 'Delhi' AND destination = 'Mumbai';

-- Step 5: Trigger (Seat Booking)
DELIMITER //

CREATE TRIGGER after_booking
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
    UPDATE seats
    SET status = 'Booked'
    WHERE seat_id = NEW.seat_id;
END //

DELIMITER ;

-- Trigger: After Cancellation → mark seat as Available
DELIMITER //

CREATE TRIGGER after_cancel
AFTER UPDATE ON bookings
FOR EACH ROW
BEGIN
    IF NEW.status = 'Cancelled' THEN
        UPDATE seats
        SET status = 'Available'
        WHERE seat_id = NEW.seat_id;
    END IF;
END //

DELIMITER ;

-- Step 6: Test Booking 
-- Book Seat A1
INSERT INTO bookings (customer_id, flight_id, seat_id)
VALUES (1, 1, 1);

-- Check seats after booking
SELECT * FROM seats;

-- Step 7: Test Cancellation
UPDATE bookings
SET status = 'Cancelled'
WHERE booking_id = 1;

-- Check seats after cancellation
SELECT * FROM seats;

-- Step 8: Views
-- Booking Summary View
CREATE VIEW booking_summary AS
SELECT b.booking_id, c.name, f.flight_name, s.seat_number, b.status
FROM bookings b
JOIN customers c ON b.customer_id = c.customer_id
JOIN flights f ON b.flight_id = f.flight_id
JOIN seats s ON b.seat_id = s.seat_id;

-- Flight Availability View
CREATE VIEW flight_availability AS
SELECT 
    f.flight_name,
    COUNT(s.seat_id) AS available_seats
FROM flights f
JOIN seats s ON f.flight_id = s.flight_id
WHERE s.status = 'Available'
GROUP BY f.flight_name;

-- Step 9: View Data
SELECT * FROM booking_summary;
SELECT * FROM flight_availability;
