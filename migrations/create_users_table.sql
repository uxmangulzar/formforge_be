CREATE TABLE IF NOT EXISTS Users (
    id CHAR(36) NOT NULL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    device VARCHAR(100),
    interest VARCHAR(100),
    referralCode VARCHAR(20) UNIQUE,
    referredBy VARCHAR(20),
    referralCount INT DEFAULT 0,
    waitlistPosition INT,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
