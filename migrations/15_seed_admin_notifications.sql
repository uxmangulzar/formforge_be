-- Sample notifications for every admin user (for GET / list testing).
-- Requires: 14_admin_notifications.sql already applied.

INSERT INTO notifications (id, recipient_user_id, type, title, body, metadata, read_at, createdAt, updatedAt)
SELECT UUID(), a.id, v.type, v.title, v.body, v.metadata, v.read_at, v.createdAt, v.createdAt
FROM users a
CROSS JOIN (
    SELECT
        'system' AS type,
        'Notifications live' AS title,
        'Sample in-app message. Bell + GET list can use this row.' AS body,
        JSON_OBJECT('path', '/settings') AS metadata,
        CAST(NULL AS DATETIME) AS read_at,
        DATE_SUB(NOW(), INTERVAL 2 MINUTE) AS createdAt
    UNION ALL
    SELECT
        'waitlist',
        'Waitlist activity (sample)',
        'Placeholder text — replace with real inserts from waitlist flow.',
        JSON_OBJECT('path', '/waitlist'),
        NULL,
        DATE_SUB(NOW(), INTERVAL 15 MINUTE)
    UNION ALL
    SELECT
        'user_registered',
        'New user (sample)',
        'Sample registration alert for API testing.',
        JSON_OBJECT('path', '/users'),
        NULL,
        DATE_SUB(NOW(), INTERVAL 1 HOUR)
    UNION ALL
    SELECT
        'system',
        'Already read (sample)',
        'This row has read_at set — use for unread-count vs read tests.',
        NULL,
        NOW(),
        DATE_SUB(NOW(), INTERVAL 2 HOUR)
) AS v
WHERE a.role = 'admin'
  AND NOT EXISTS (
    SELECT 1 FROM notifications n
    WHERE n.recipient_user_id = a.id AND n.title = 'Notifications live'
  );
