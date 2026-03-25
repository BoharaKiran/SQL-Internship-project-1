-- 1. Create database
CREATE DATABASE IF NOT EXISTS movie_db;
USE movie_db;

-- 2. Create tables
-- Users table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    signup_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Movies table
CREATE TABLE movies (
    movie_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    genre VARCHAR(50),
    release_year YEAR,
    duration_minutes INT
);

-- Ratings table
CREATE TABLE ratings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    movie_id INT,
    rating TINYINT CHECK (rating BETWEEN 1 AND 10),
    rating_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE
);


-- Reviews table
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    movie_id INT,
    review_text TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE
);

-- 3. Insert Sample Data
-- Users
INSERT INTO users (username, email)
VALUES 
('alice', 'alice@example.com'),
('bob', 'bob@example.com'),
('charlie', 'charlie@example.com'),
('diana', 'diana@example.com');

-- Movies
INSERT INTO movies (title, genre, release_year, duration_minutes)
VALUES
('Inception', 'Sci-Fi', 2010, 148),
('The Godfather', 'Crime', 1972, 175),
('Avengers: Endgame', 'Action', 2019, 181),
('Parasite', 'Thriller', 2019, 132),
('Interstellar', 'Sci-Fi', 2014, 169);

-- Ratings
INSERT INTO ratings (user_id, movie_id, rating)
VALUES
(1, 1, 9),
(1, 2, 10),
(2, 1, 8),
(2, 3, 9),
(3, 4, 10),
(3, 5, 9),
(4, 2, 8),
(4, 3, 10);

-- Reviews
INSERT INTO reviews (user_id, movie_id, review_text)
VALUES
(1, 1, 'Amazing concept and visuals!'),
(1, 2, 'Classic mafia story, timeless.'),
(2, 3, 'Epic finale to the series.'),
(3, 4, 'Suspenseful and brilliantly directed.'),
(3, 5, 'Mind-bending and emotional journey.'),
(4, 3, 'Loved every action sequence.');

-- 4. Queries for Average Ratings and Rankings
-- Average rating per movie
SELECT 
    m.movie_id,
    m.title,
    ROUND(AVG(r.rating),2) AS avg_rating,
    COUNT(r.rating) AS total_ratings
FROM movies m
JOIN ratings r ON m.movie_id = r.movie_id
GROUP BY m.movie_id, m.title
ORDER BY avg_rating DESC;

-- Top 3 highest-rated movies
SELECT *
FROM (
    SELECT 
        m.movie_id,
        m.title,
        ROUND(AVG(r.rating),2) AS avg_rating,
        COUNT(r.rating) AS total_ratings,
        RANK() OVER (ORDER BY AVG(r.rating) DESC) AS rank_order
    FROM movies m
    JOIN ratings r ON m.movie_id = r.movie_id
    GROUP BY m.movie_id, m.title
) ranked
WHERE rank_order <= 3;


-- 5. Create Views for Recommended Movies
-- View: Average Ratings
CREATE OR REPLACE VIEW avg_movie_ratings AS
SELECT 
    m.movie_id,
    m.title,
    ROUND(AVG(r.rating),2) AS avg_rating,
    COUNT(r.rating) AS rating_count
FROM movies m
JOIN ratings r ON m.movie_id = r.movie_id
GROUP BY m.movie_id, m.title;

-- View: Recommended Movies (rating >= 9)
CREATE OR REPLACE VIEW recommended_movies AS
SELECT movie_id, title, avg_rating
FROM avg_movie_ratings
WHERE avg_rating >= 9
ORDER BY avg_rating DESC;

-- 6. Sample Recommendation Query for a User
SELECT m.movie_id, m.title, r.avg_rating
FROM movies m
JOIN recommended_movies r ON m.movie_id = r.movie_id
WHERE m.movie_id NOT IN (
    SELECT movie_id FROM ratings WHERE user_id = 1
)
ORDER BY r.avg_rating DESC;

-- 7. Export Movie Recommendation Results
SELECT * FROM recommended_movies;
