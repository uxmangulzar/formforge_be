-- Create Users Table
CREATE TABLE IF NOT EXISTS users (
    id CHAR(36) NOT NULL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    referral_code VARCHAR(20) UNIQUE,
    is_verified BOOLEAN DEFAULT FALSE,
    is_profile_completed BOOLEAN DEFAULT FALSE,
    role ENUM('user', 'admin') DEFAULT 'user',
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    resetPasswordToken VARCHAR(255),
    resetPasswordExpire DATETIME,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Profiles Table
CREATE TABLE IF NOT EXISTS profiles (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    full_name VARCHAR(255),
    avatar_url VARCHAR(255),
    age INT,
    fitness_level ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'beginner',
    goal TEXT,
    injury_history TEXT,
    total_xp INT DEFAULT 0,
    level INT DEFAULT 1,
    current_streak INT DEFAULT 0,
    preferred_language VARCHAR(10) DEFAULT 'en',
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
