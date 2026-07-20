-- Store sync history (pull / cancel / refund) per user subscription.
-- Run: npm run migrate:file -- 24_user_subscription_store_syncs.sql

CREATE TABLE IF NOT EXISTS user_subscription_store_syncs (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_subscription_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    platform ENUM('google_play', 'app_store') NOT NULL,
    sync_type ENUM('pull', 'cancel', 'refund') NOT NULL DEFAULT 'pull',
    status ENUM('success', 'no_change', 'failed', 'manual_required') NOT NULL,
    message VARCHAR(500) NULL,
    store_status VARCHAR(64) NULL,
    store_expires_at DATETIME NULL,
    store_auto_renew BOOLEAN NULL,
    store_product_id VARCHAR(255) NULL,
    user_updated BOOLEAN NOT NULL DEFAULT FALSE,
    previous_data JSON NULL,
    store_snapshot JSON NULL,
    applied_updates JSON NULL,
    error_detail TEXT NULL,
    performed_by CHAR(36) NULL,
    createdAt DATETIME NOT NULL,
    INDEX idx_store_syncs_subscription (user_subscription_id),
    INDEX idx_store_syncs_user (user_id),
    INDEX idx_store_syncs_created (createdAt),
    CONSTRAINT fk_store_syncs_subscription
        FOREIGN KEY (user_subscription_id) REFERENCES user_subscriptions(id) ON DELETE CASCADE,
    CONSTRAINT fk_store_syncs_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
