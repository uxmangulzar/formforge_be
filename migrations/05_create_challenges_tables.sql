-- Challenges: multi-stage definitions, exercises (sets/reps/points), user progress.
-- Depends on: users (03), exercises (04). Does not alter existing tables.

CREATE TABLE IF NOT EXISTS challenges (
    id CHAR(36) NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    starts_at DATETIME NOT NULL,
    ends_at DATETIME NOT NULL,
    status ENUM('draft', 'published', 'archived') NOT NULL DEFAULT 'draft',
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    INDEX idx_challenges_status (status),
    INDEX idx_challenges_dates (starts_at, ends_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS challenge_stages (
    id CHAR(36) NOT NULL PRIMARY KEY,
    challenge_id CHAR(36) NOT NULL,
    stage_order INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    points_bonus INT NOT NULL DEFAULT 0,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    UNIQUE KEY uq_challenge_stage_order (challenge_id, stage_order),
    INDEX idx_challenge_stages_challenge (challenge_id),
    CONSTRAINT fk_challenge_stages_challenge
        FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS challenge_stage_exercises (
    id CHAR(36) NOT NULL PRIMARY KEY,
    challenge_stage_id CHAR(36) NOT NULL,
    exercise_id CHAR(36) NOT NULL,
    sequence_order INT NOT NULL,
    target_sets INT NOT NULL DEFAULT 1,
    target_reps INT NOT NULL DEFAULT 1,
    points_on_complete INT NOT NULL DEFAULT 0,
    optional BOOLEAN NOT NULL DEFAULT FALSE,
    notes VARCHAR(500),
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    UNIQUE KEY uq_stage_exercise_order (challenge_stage_id, sequence_order),
    INDEX idx_cse_stage (challenge_stage_id),
    INDEX idx_cse_exercise (exercise_id),
    CONSTRAINT fk_cse_stage
        FOREIGN KEY (challenge_stage_id) REFERENCES challenge_stages(id) ON DELETE CASCADE,
    CONSTRAINT fk_cse_exercise
        FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS user_challenges (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    challenge_id CHAR(36) NOT NULL,
    status ENUM('joined', 'in_progress', 'completed', 'failed', 'expired') NOT NULL DEFAULT 'joined',
    total_points_earned INT NOT NULL DEFAULT 0,
    joined_at DATETIME NOT NULL,
    completed_at DATETIME,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    UNIQUE KEY uq_user_challenge (user_id, challenge_id),
    INDEX idx_user_challenges_user (user_id),
    INDEX idx_user_challenges_challenge (challenge_id),
    CONSTRAINT fk_user_challenges_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_challenges_challenge
        FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS user_challenge_stage_progress (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_challenge_id CHAR(36) NOT NULL,
    challenge_stage_id CHAR(36) NOT NULL,
    status ENUM('locked', 'active', 'completed') NOT NULL DEFAULT 'locked',
    completed_at DATETIME,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    UNIQUE KEY uq_ucsp_stage (user_challenge_id, challenge_stage_id),
    INDEX idx_ucsp_user_challenge (user_challenge_id),
    INDEX idx_ucsp_stage (challenge_stage_id),
    CONSTRAINT fk_ucsp_user_challenge
        FOREIGN KEY (user_challenge_id) REFERENCES user_challenges(id) ON DELETE CASCADE,
    CONSTRAINT fk_ucsp_stage
        FOREIGN KEY (challenge_stage_id) REFERENCES challenge_stages(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS user_challenge_exercise_progress (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_challenge_id CHAR(36) NOT NULL,
    challenge_stage_exercise_id CHAR(36) NOT NULL,
    sets_completed INT NOT NULL DEFAULT 0,
    reps_logged INT NOT NULL DEFAULT 0,
    status ENUM('not_started', 'in_progress', 'completed') NOT NULL DEFAULT 'not_started',
    points_awarded INT NOT NULL DEFAULT 0,
    completed_at DATETIME,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    UNIQUE KEY uq_ucep_mapping (user_challenge_id, challenge_stage_exercise_id),
    INDEX idx_ucep_user_challenge (user_challenge_id),
    INDEX idx_ucep_cse (challenge_stage_exercise_id),
    CONSTRAINT fk_ucep_user_challenge
        FOREIGN KEY (user_challenge_id) REFERENCES user_challenges(id) ON DELETE CASCADE,
    CONSTRAINT fk_ucep_cse
        FOREIGN KEY (challenge_stage_exercise_id) REFERENCES challenge_stage_exercises(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
