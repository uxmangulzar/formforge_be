-- Allow store_synced in subscription audit log.
-- Run: npm run migrate:file -- 22_user_subscription_store_synced_log.sql

ALTER TABLE user_subscription_logs
    MODIFY COLUMN action ENUM(
        'created',
        'expiry_updated',
        'deactivated',
        'cancelled',
        'refunded',
        'deleted',
        'reactivated',
        'store_synced'
    ) NOT NULL;
