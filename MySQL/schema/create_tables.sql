CREATE DATABASE social_app;
USE social_app;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  email VARCHAR(100) UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  content TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE followers (
  follower_id INT,
  followed_id INT,
  PRIMARY KEY (follower_id, followed_id),
  FOREIGN KEY (follower_id) REFERENCES users(id),
  FOREIGN KEY (followed_id) REFERENCES users(id)
);

CREATE INDEX idx_user_id ON posts(user_id);
CREATE INDEX idx_follower ON followers(follower_id);

CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'securepassword';
GRANT SELECT, INSERT, UPDATE ON social_app.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;