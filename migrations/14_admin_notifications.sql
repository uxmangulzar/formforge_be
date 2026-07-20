-- In-app notifications for admin users (users.role = 'admin').
-- Application inserts one row per recipient when fan-out is needed.

CREATE TABLE IF NOT EXISTS notifications (
    id CHAR(36) NOT NULL PRIMARY KEY,
    recipient_user_id CHAR(36) NOT NULL COMMENT 'Admin user who sees this row',
    type VARCHAR(64) NOT NULL COMMENT 'e.g. waitlist_signup, user_registered, system',
    title VARCHAR(255) NOT NULL,
    body TEXT NULL,
    metadata JSON NULL COMMENT 'Optional payload: urls, entity ids, etc.',
    read_at DATETIME NULL COMMENT 'NULL = unread',
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    CONSTRAINT fk_notifications_recipient
        FOREIGN KEY (recipient_user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_notifications_recipient_unread (recipient_user_id, read_at),
    INDEX idx_notifications_recipient_created (recipient_user_id, createdAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Per-admin toggles (in-app / email later, which event types fire).
CREATE TABLE IF NOT EXISTS admin_notification_settings (
    user_id CHAR(36) NOT NULL PRIMARY KEY,
    in_app_enabled TINYINT(1) NOT NULL DEFAULT 1,
    email_enabled TINYINT(1) NOT NULL DEFAULT 0,
    allowed_types JSON NULL COMMENT 'NULL = all types on; else {"waitlist":true,...}',
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    CONSTRAINT fk_admin_notification_settings_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
