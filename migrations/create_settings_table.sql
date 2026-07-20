CREATE TABLE IF NOT EXISTS Settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    description VARCHAR(255),
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Initial Settings Data (Optional)
INSERT IGNORE INTO Settings (setting_key, setting_value, description, createdAt, updatedAt)
VALUES 
('maintenance_mode', 'false', 'Enable or disable landing page maintenance mode', NOW(), NOW()),
('max_waitlist_spots', '10000', 'Maximum number of users allowed in waitlist', NOW(), NOW()),
('beta_launch_date', '2026-06-01', 'Scheduled date for beta launch', NOW(), NOW());
