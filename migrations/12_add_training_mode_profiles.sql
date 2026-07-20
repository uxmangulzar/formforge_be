-- Training modes as first-class rows (not challenges).
-- If you ever applied an older draft that added profiles.training_mode (ENUM), drop it first:
--   ALTER TABLE profiles DROP COLUMN training_mode;
-- If exercises.training_modes (JSON) existed, drop it before running 13:
--   ALTER TABLE exercises DROP COLUMN training_modes;

CREATE TABLE IF NOT EXISTS training_modes (
    id CHAR(36) NOT NULL PRIMARY KEY,
    slug VARCHAR(50) NOT NULL UNIQUE COMMENT 'Stable key for API/app: training, rehab, gaming',
    display_name VARCHAR(100) NOT NULL,
    description VARCHAR(500) NULL,
    sort_order INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    INDEX idx_training_modes_active (is_active),
    INDEX idx_training_modes_sort (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO training_modes (id, slug, display_name, description, sort_order, is_active, createdAt, updatedAt)
VALUES
    ('a0000001-0001-4001-8001-000000000001', 'training', 'Training', 'Standard strength and conditioning style work.', 0, TRUE, NOW(), NOW()),
    ('a0000001-0001-4001-8001-000000000002', 'rehab', 'Rehab', 'Recovery-oriented, controlled load and range.', 1, TRUE, NOW(), NOW()),
    ('a0000001-0001-4001-8001-000000000003', 'gaming', 'Gaming', 'Playful, score and streak friendly sessions.', 2, TRUE, NOW(), NOW())
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    description = VALUES(description),
    sort_order = VALUES(sort_order),
    is_active = VALUES(is_active),
    updatedAt = VALUES(updatedAt);

ALTER TABLE profiles
    ADD COLUMN training_mode_id CHAR(36) NOT NULL DEFAULT 'a0000001-0001-4001-8001-000000000001'
    COMMENT 'Preferred experience mode, FK to training_modes.id'
    AFTER preferred_language;

ALTER TABLE profiles
    ADD CONSTRAINT fk_profiles_training_mode_id
    FOREIGN KEY (training_mode_id) REFERENCES training_modes(id) ON DELETE RESTRICT;

CREATE INDEX idx_profiles_training_mode_id ON profiles (training_mode_id);
