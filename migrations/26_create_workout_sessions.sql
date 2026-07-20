-- Standalone workout session logs (Train / Play / Recover), separate from challenge progress.

CREATE TABLE IF NOT EXISTS workout_sessions (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    exercise_id CHAR(36) NOT NULL,
    mode ENUM('train', 'play', 'recover') NOT NULL,
    challenge_id CHAR(36) NULL COMMENT 'Optional link when workout done during a challenge',
    form_score INT NULL COMMENT 'Form score 0-100',
    reps INT NOT NULL DEFAULT 0,
    sets INT NOT NULL DEFAULT 0,
    duration_sec INT NOT NULL DEFAULT 0,
    calories INT NULL,
    xp_earned INT NOT NULL DEFAULT 0,
    mistakes JSON NULL,
    notes TEXT NULL,
    completed_at DATETIME NOT NULL,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    INDEX idx_workout_sessions_user (user_id),
    INDEX idx_workout_sessions_exercise (exercise_id),
    INDEX idx_workout_sessions_user_exercise (user_id, exercise_id),
    INDEX idx_workout_sessions_completed (user_id, completed_at),
    INDEX idx_workout_sessions_mode (user_id, mode),
    CONSTRAINT fk_workout_sessions_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_workout_sessions_exercise
        FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE RESTRICT,
    CONSTRAINT fk_workout_sessions_challenge
        FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
