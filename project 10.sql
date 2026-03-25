-- 📱 Social Media Analytics Backend Project
-- STEP 1: CREATE DATABASE
CREATE DATABASE social_media_db;
USE social_media_db;

-- STEP 2: CREATE TABLES
-- USERS TABLE
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- POSTS TABLE
CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    like_count INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- LIKES TABLE
CREATE TABLE likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    post_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id)
);

-- COMMENTS TABLE
CREATE TABLE comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    post_id INT,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id)
);


-- STEP 3: INSERT SAMPLE DATA
-- USERS
INSERT INTO users (username, email) VALUES
('kiran', 'kiran@gmail.com'),
('rahul', 'rahul@gmail.com'),
('priya', 'priya@gmail.com');

-- POSTS
INSERT INTO posts (user_id, content) VALUES
(1, 'My first post'),
(2, 'Hello world!'),
(3, 'Learning SQL is fun');

-- LIKES
INSERT INTO likes (user_id, post_id) VALUES
(2,1), (3,1),
(1,2), (3,2),
(1,3);

-- COMMENTS
INSERT INTO comments (user_id, post_id, comment) VALUES
(2,1,'Nice post!'),
(3,1,'Great!'),
(1,2,'Welcome!'),
(2,3,'Good job!');


-- STEP 4: CREATE TRIGGER (LIKE COUNT AUTO UPDATE)
DELIMITER $$

CREATE TRIGGER after_like_insert
AFTER INSERT ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = like_count + 1
    WHERE post_id = NEW.post_id;
END$$

DELIMITER ;


-- STEP 5: CREATE VIEWS
-- TOP POSTS VIEW
CREATE VIEW top_posts AS
SELECT 
    p.post_id,
    u.username,
    p.content,
    p.like_count
FROM posts p
JOIN users u ON p.user_id = u.user_id
ORDER BY p.like_count DESC;

-- ENGAGEMENT VIEW
CREATE VIEW engagement_view AS
SELECT 
    p.post_id,
    p.content,
    COUNT(DISTINCT l.like_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    (COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id)) AS engagement_score
FROM posts p
LEFT JOIN likes l ON p.post_id = l.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
GROUP BY p.post_id, p.content;


-- STEP 6: RANKING (WINDOW FUNCTION)
SELECT 
    post_id,
    content,
    engagement_score,
    RANK() OVER (ORDER BY engagement_score DESC) AS rank_position
FROM engagement_view;


-- STEP 7: REPORT QUERY
SELECT 
    u.username,
    COUNT(DISTINCT p.post_id) AS total_posts,
    COUNT(DISTINCT l.like_id) AS total_likes_received,
    COUNT(DISTINCT c.comment_id) AS total_comments_received
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
LEFT JOIN likes l ON p.post_id = l.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
GROUP BY u.username;

-- STEP 8: CHECK OUTPUT
-- View Top Posts
SELECT * FROM top_posts;

-- View Engagement
SELECT * FROM engagement_view;


-- BONUS QUERIES (EXTRA MARKS)
-- Most Active User
SELECT 
    u.username,
    COUNT(p.post_id) AS post_count
FROM users u
JOIN posts p ON u.user_id = p.user_id
GROUP BY u.username
ORDER BY post_count DESC
LIMIT 1;

-- Most Liked Post
SELECT * FROM posts
ORDER BY like_count DESC
LIMIT 1;