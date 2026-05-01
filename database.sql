CREATE DATABASE chatdb;

CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender VARCHAR(50),
    receiver VARCHAR(50),
    message TEXT
);
CREATE DATABASE chatapp;


CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(50),
    role VARCHAR(10)
);

CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender VARCHAR(50),
    receiver VARCHAR(50),
    message TEXT,
    type VARCHAR(20),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users(username, password, role) VALUES
('shivam', '123', 'user'),
('rahul', '123', 'user'),
('admin', 'admin', 'admin');
UPDATE users SET password = MD5('123') WHERE username='shivam';
UPDATE users SET password = MD5('123') WHERE username='rahul';
UPDATE users SET password = MD5('admin') WHERE username='admin';
ALTER TABLE messages ADD status VARCHAR(20) DEFAULT 'SENT';ALTER TABLE users ADD last_seen TIMESTAMP NULL;
CREATE TABLE contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user VARCHAR(50),
    friend VARCHAR(50)
);
-- PROFILE
ALTER TABLE users ADD bio VARCHAR(255);

-- PAGINATION SUPPORT
ALTER TABLE messages ADD created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

