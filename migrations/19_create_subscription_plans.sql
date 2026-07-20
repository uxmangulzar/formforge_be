-- Subscription plans for in-app purchases (manual IDs or platform-created later).
-- Run: npm run migrate:file -- 19_create_subscription_plans.sql

CREATE TABLE IF NOT EXISTS subscription_plans (
    id CHAR(36) NOT NULL PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    description TEXT NULL,
    status ENUM('draft', 'active', 'inactive', 'archived') NOT NULL DEFAULT 'draft',
    free_trials INT NOT NULL DEFAULT 0 COMMENT 'Free trial length in days; 0 = no trial',
    price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    features JSON NULL COMMENT 'Plan feature list for admin/app display',
    play_store_sub_id VARCHAR(255) NULL COMMENT 'Google Play subscription product ID',
    app_store_sub_id VARCHAR(255) NULL COMMENT 'Apple App Store subscription product ID',
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    INDEX idx_subscription_plans_status (status),
    INDEX idx_subscription_plans_name (name),
    UNIQUE KEY uq_subscription_plans_play_store_sub_id (play_store_sub_id),
    UNIQUE KEY uq_subscription_plans_app_store_sub_id (app_store_sub_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
