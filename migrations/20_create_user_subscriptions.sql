-- Links app users to subscription plans (purchase / trial / admin grant).
-- Run: npm run migrate:file -- 20_create_user_subscriptions.sql

CREATE TABLE IF NOT EXISTS user_subscriptions (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    subscription_plan_id CHAR(36) NOT NULL,
    status ENUM('trialing', 'active', 'expired', 'cancelled', 'paused') NOT NULL DEFAULT 'active',
    platform ENUM('google_play', 'app_store', 'manual', 'admin') NOT NULL DEFAULT 'manual',
    store_purchase_token VARCHAR(512) NULL,
    started_at DATETIME NOT NULL,
    expires_at DATETIME NULL,
    cancelled_at DATETIME NULL,
    auto_renew TINYINT(1) NOT NULL DEFAULT 1,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    INDEX idx_user_subscriptions_user (user_id),
    INDEX idx_user_subscriptions_plan (subscription_plan_id),
    INDEX idx_user_subscriptions_status (status),
    CONSTRAINT fk_user_subscriptions_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_subscriptions_plan
        FOREIGN KEY (subscription_plan_id) REFERENCES subscription_plans(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
