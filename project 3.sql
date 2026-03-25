CREATE DATABASE covid_analysis;
USE covid_analysis;

-- Create Table
CREATE TABLE covid_data (
    id INT PRIMARY KEY AUTO_INCREMENT,
    country VARCHAR(100),
    date DATE,
    confirmed INT,
    deaths INT,
    recovered INT
);

-- Insert Sample Data
INSERT INTO covid_data (country, date, confirmed, deaths, recovered)
VALUES
('India', '2020-05-01', 35000, 1200, 9000),
('India', '2020-05-02', 37000, 1300, 10000),
('USA', '2020-05-01', 1000000, 60000, 150000),
('USA', '2020-05-02', 1050000, 65000, 160000),
('Brazil', '2020-05-01', 90000, 6000, 40000);

-- Data Cleaning
SELECT * FROM covid_data
WHERE confirmed IS NULL;

-- Basic Queries
SELECT country, SUM(confirmed) AS total_cases
FROM covid_data
GROUP BY country;

SELECT country, SUM(deaths) AS total_deaths
FROM covid_data
GROUP BY country;

-- Top Countries
SELECT country, SUM(confirmed) AS total_cases
FROM covid_data
GROUP BY country
ORDER BY total_cases DESC
LIMIT 5;

-- Daily Trends

SELECT date, SUM(confirmed) AS daily_cases
FROM covid_data
GROUP BY date
ORDER BY date;

-- Recovery Rate
SELECT country,
       (SUM(recovered) / SUM(confirmed)) * 100 AS recovery_rate
FROM covid_data
GROUP BY country;

-- Active Cases
SELECT country,
       SUM(confirmed - deaths - recovered) AS active_cases
FROM covid_data
GROUP BY country;

-- WINDOW FUNCTION
SELECT country, date, confirmed,
       LAG(confirmed) OVER (PARTITION BY country ORDER BY date) AS prev_day,
       confirmed - LAG(confirmed) OVER (PARTITION BY country ORDER BY date) AS daily_increase
FROM covid_data;

USE covid_analysis;
SELECT * FROM covid_raw LIMIT 5;

SELECT * FROM covid_raw LIMIT 10;