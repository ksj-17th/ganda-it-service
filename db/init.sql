CREATE DATABASE IF NOT EXISTS mft CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE mft;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(64) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('user','admin') NOT NULL DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sessions (
  session_id VARCHAR(64) PRIMARY KEY,
  user_id INT NOT NULL,
  expires_at DATETIME NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE files (
  id INT AUTO_INCREMENT PRIMARY KEY,
  owner_id INT NOT NULL,
  original_name VARCHAR(255) NOT NULL,
  storage_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (owner_id) REFERENCES users(id)
);

CREATE TABLE audit_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  event_time TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  request_id VARCHAR(64),
  username VARCHAR(64),
  event_type VARCHAR(64) NOT NULL,
  target VARCHAR(255),
  remote_ip VARCHAR(45),
  success TINYINT(1) NOT NULL,
  detail TEXT,
  INDEX idx_audit_time(event_time),
  INDEX idx_audit_event(event_type),
  INDEX idx_audit_user(username)
);

CREATE TABLE shares (
  id INT AUTO_INCREMENT PRIMARY KEY,
  file_id INT NOT NULL,
  token VARCHAR(128) NOT NULL,
  active TINYINT(1) NOT NULL DEFAULT 1,
  FOREIGN KEY (file_id) REFERENCES files(id)
);

-- bcrypt hash for the shared demo password: 1234
INSERT INTO users(username,password_hash,role) VALUES
('admin', '$2y$12$SKxzyTSUSEnaWH8MfVGs9OUdPWGglfLwBS.WbWTRuYIwGAviZyPR.', 'admin'),
('test', '$2y$12$SKxzyTSUSEnaWH8MfVGs9OUdPWGglfLwBS.WbWTRuYIwGAviZyPR.', 'user'),
('deployer', '$2y$12$SKxzyTSUSEnaWH8MfVGs9OUdPWGglfLwBS.WbWTRuYIwGAviZyPR.', 'user'),
('hospital', '$2y$12$SKxzyTSUSEnaWH8MfVGs9OUdPWGglfLwBS.WbWTRuYIwGAviZyPR.', 'user');

INSERT INTO files(owner_id,original_name,storage_name) VALUES
(2,'Q3_contract.pdf','f_841d26962eca7b5a.bin'),
(3,'partner_price.xlsx','f_b7f1dbf150f2081b.bin'),
(1,'incident_contacts.txt','f_a5b3bb76a2a2c305.bin'),
(3,'MyApp_Setup_1.0.exe','f_e21aa6441ced5c11.bin');

INSERT INTO shares(file_id,token,active) VALUES
(1,'7f7f00fc1ae7bb71950a80f335b227f40777db1effba6375',1),
(2,'ba906adcd8ed6394b264b6ee41ce887630ed6be4c4c3c3f6',1),
(3,'7c6d2408b6f178a5a90569d9ea6829b2812ff3b4659c40be',1),
(4,'4e9a6d58c3f27b1a80d4e7c2fa9136b85d0c42ab71fe9934',1);

-- Pre-existing admin web session so the SQLi can demonstrate session disclosure/hijacking.
INSERT INTO sessions(session_id,user_id,expires_at) VALUES
('8c3f6a1d9e42b750c4d2816fa037be95',1,'2030-01-01 00:00:00');
