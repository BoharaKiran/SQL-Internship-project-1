-- SPORTS TOURNAMENT TRACKER DATABASE
CREATE DATABASE sports_db;
USE sports_db;

-- TABLES
-- Teams
CREATE TABLE teams (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(100),
    coach_name VARCHAR(100)
);

-- Players
CREATE TABLE players (
    player_id INT AUTO_INCREMENT PRIMARY KEY,
    player_name VARCHAR(100),
    team_id INT,
    role VARCHAR(50),
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

-- Matches
CREATE TABLE matches (
    match_id INT AUTO_INCREMENT PRIMARY KEY,
    team1_id INT,
    team2_id INT,
    match_date DATE,
    winner_team_id INT,
    FOREIGN KEY (team1_id) REFERENCES teams(team_id),
    FOREIGN KEY (team2_id) REFERENCES teams(team_id),
    FOREIGN KEY (winner_team_id) REFERENCES teams(team_id)
);

-- Stats
CREATE TABLE stats (
    stat_id INT AUTO_INCREMENT PRIMARY KEY,
    match_id INT,
    player_id INT,
    runs INT,
    wickets INT,
    FOREIGN KEY (match_id) REFERENCES matches(match_id),
    FOREIGN KEY (player_id) REFERENCES players(player_id)
);

-- INSERT DATA

INSERT INTO teams (team_name, coach_name) VALUES
('Mumbai Warriors', 'Ravi Kumar'),
('Delhi Strikers', 'Amit Singh'),
('Chennai Kings', 'Suresh Raina');

INSERT INTO players (player_name, team_id, role) VALUES
('Virat Kohli', 2, 'Batsman'),
('Rohit Sharma', 1, 'Batsman'),
('MS Dhoni', 3, 'Wicketkeeper'),
('Hardik Pandya', 1, 'All-rounder'),
('Jadeja', 3, 'All-rounder');

INSERT INTO matches (team1_id, team2_id, match_date, winner_team_id) VALUES
(1, 2, '2026-03-10', 1),
(2, 3, '2026-03-12', 3),
(1, 3, '2026-03-15', 3);

INSERT INTO stats (match_id, player_id, runs, wickets) VALUES
(1, 2, 80, 0),
(1, 1, 60, 0),
(2, 3, 45, 0),
(2, 5, 30, 2),
(3, 4, 70, 1);

-- QUERIES
-- Match Results
SELECT 
    m.match_id,
    t1.team_name AS team1,
    t2.team_name AS team2,
    t3.team_name AS winner
FROM matches m
JOIN teams t1 ON m.team1_id = t1.team_id
JOIN teams t2 ON m.team2_id = t2.team_id
JOIN teams t3 ON m.winner_team_id = t3.team_id;

-- Player Scores
SELECT 
    p.player_name,
    SUM(s.runs) AS total_runs,
    SUM(s.wickets) AS total_wickets
FROM stats s
JOIN players p ON s.player_id = p.player_id
GROUP BY p.player_name;

-- VIEWS
-- Leaderboard (Top Players)
CREATE VIEW leaderboard AS
SELECT 
    p.player_name,
    SUM(s.runs) AS total_runs
FROM stats s
JOIN players p ON s.player_id = p.player_id
GROUP BY p.player_name
ORDER BY total_runs DESC;

-- Points Table (Team Wins)
CREATE VIEW points_table AS
SELECT 
    t.team_name,
    COUNT(m.match_id) AS wins
FROM teams t
LEFT JOIN matches m ON t.team_id = m.winner_team_id
GROUP BY t.team_name
ORDER BY wins DESC;

-- CTE (Average Performance)
WITH avg_performance AS (
    SELECT 
        p.player_name,
        AVG(s.runs) AS avg_runs
    FROM stats s
    JOIN players p ON s.player_id = p.player_id
    GROUP BY p.player_name
)
SELECT * FROM avg_performance;

-- REPORT
-- Team Performance Report
SELECT 
    t.team_name,
    COUNT(m.match_id) AS matches_won
FROM teams t
LEFT JOIN matches m ON t.team_id = m.winner_team_id
GROUP BY t.team_name;
