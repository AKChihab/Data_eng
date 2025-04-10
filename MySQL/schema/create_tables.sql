CREATE DATABASE IF NOT EXISTS social_app;
USE social_app;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  email VARCHAR(100) UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS posts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  content TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS followers (
  follower_id INT,
  followed_id INT,
  PRIMARY KEY (follower_id, followed_id),
  FOREIGN KEY (follower_id) REFERENCES users(id),
FOREIGN KEY (followed_id) REFERENCES users(id)
);

CREATE USER IF NOT EXISTS 'appuser'@'localhost' IDENTIFIED WITH mysql_native_password BY 'securepassword';
GRANT SELECT, INSERT, UPDATE ON social_app.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;

DROP INDEX IF EXISTS idx_user_id ON posts;
CREATE INDEX idx_user_id ON posts(user_id);


DROP INDEX IF EXISTS idx_follower ON followers;
CREATE INDEX idx_follower ON followers(follower_id);

