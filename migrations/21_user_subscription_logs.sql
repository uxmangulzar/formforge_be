-- Subscription audit log + refund/deactivate timestamps.
-- Run: npm run migrate:file -- 21_user_subscription_logs.sql

ALTER TABLE user_subscriptions
    ADD COLUMN refunded_at DATETIME NULL AFTER cancelled_at,
    ADD COLUMN deactivated_at DATETIME NULL AFTER refunded_at;

CREATE TABLE IF NOT EXISTS user_subscription_logs (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_subscription_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    action ENUM(
        'created',
        'expiry_updated',
        'deactivated',
        'cancelled',
        'refunded',
        'deleted',
        'reactivated'
    ) NOT NULL,
    performed_by CHAR(36) NULL,
    note TEXT NULL,
    metadata JSON NULL,
    createdAt DATETIME NOT NULL,
    INDEX idx_sub_logs_subscription (user_subscription_id),
    INDEX idx_sub_logs_user (user_id),
    INDEX idx_sub_logs_action (action),
    CONSTRAINT fk_sub_logs_subscription
        FOREIGN KEY (user_subscription_id) REFERENCES user_subscriptions(id) ON DELETE CASCADE,
    CONSTRAINT fk_sub_logs_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
