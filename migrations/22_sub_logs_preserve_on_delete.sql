-- Keep audit logs when a user_subscription row is deleted.
-- Run: npm run migrate:file -- 22_sub_logs_preserve_on_delete.sql

SET @fk_name = (
    SELECT CONSTRAINT_NAME
    FROM information_schema.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'user_subscription_logs'
      AND REFERENCED_TABLE_NAME = 'user_subscriptions'
    LIMIT 1
);

SET @drop_fk = IF(
    @fk_name IS NOT NULL,
    CONCAT('ALTER TABLE user_subscription_logs DROP FOREIGN KEY `', @fk_name, '`'),
    'SELECT 1'
);
PREPARE stmt FROM @drop_fk;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

ALTER TABLE user_subscription_logs
    MODIFY user_subscription_id CHAR(36) NULL;

ALTER TABLE user_subscription_logs
    ADD CONSTRAINT fk_sub_logs_subscription
        FOREIGN KEY (user_subscription_id) REFERENCES user_subscriptions(id) ON DELETE SET NULL;
