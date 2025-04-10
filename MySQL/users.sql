DROP USER IF EXISTS 'newuser'@'localhost';

CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'newpassword';
GRANT ALL PRIVILEGES ON social_app.* TO 'newuser'@'localhost';
FLUSH PRIVILEGES;

-- ALTER USER 'appuser'@'localhost' IDENTIFIED BY 'new_secure_password';

-- SELECT user, host FROM mysql.user;