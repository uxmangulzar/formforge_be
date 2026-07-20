-- Many-to-many: which modes each exercise is available in.
-- Backfill: every existing exercise linked to all three modes (adjust per exercise later via admin/API).

CREATE TABLE IF NOT EXISTS exercise_training_modes (
    exercise_id CHAR(36) NOT NULL,
    mode_id CHAR(36) NOT NULL,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    PRIMARY KEY (exercise_id, mode_id),
    CONSTRAINT fk_exercise_training_modes_exercise
        FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE,
    CONSTRAINT fk_exercise_training_modes_mode
        FOREIGN KEY (mode_id) REFERENCES training_modes(id) ON DELETE CASCADE,
    INDEX idx_exercise_training_modes_mode (mode_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO exercise_training_modes (exercise_id, mode_id, createdAt, updatedAt)
SELECT e.id, m.id, NOW(), NOW()
FROM exercises e
CROSS JOIN training_modes m
WHERE m.is_active = TRUE;
