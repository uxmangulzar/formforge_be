-- Badges: definitions, configurable rules (settings), user awards.
-- Depends on: users (03), challenges (05). Does not alter existing tables.

CREATE TABLE IF NOT EXISTS badges (
    id CHAR(36) NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon_url VARCHAR(500),
    rarity ENUM('common', 'rare', 'epic', 'legendary') NOT NULL DEFAULT 'common',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    INDEX idx_badges_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS badge_rules (
    id CHAR(36) NOT NULL PRIMARY KEY,
    badge_id CHAR(36) NOT NULL,
    challenge_id CHAR(36),
    trigger_type ENUM(
        'points_threshold',
        'challenge_complete',
        'challenge_all_stages',
        'custom'
    ) NOT NULL,
    trigger_config JSON,
    priority INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    INDEX idx_badge_rules_badge (badge_id),
    INDEX idx_badge_rules_challenge (challenge_id),
    INDEX idx_badge_rules_active (is_active),
    CONSTRAINT fk_badge_rules_badge
        FOREIGN KEY (badge_id) REFERENCES badges(id) ON DELETE CASCADE,
    CONSTRAINT fk_badge_rules_challenge
        FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS user_badges (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    badge_id CHAR(36) NOT NULL,
    earned_at DATETIME NOT NULL,
    context JSON,
    createdAt DATETIME NOT NULL,
    updatedAt DATETIME NOT NULL,
    UNIQUE KEY uq_user_badge (user_id, badge_id),
    INDEX idx_user_badges_user (user_id),
    INDEX idx_user_badges_badge (badge_id),
    CONSTRAINT fk_user_badges_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_badges_badge
        FOREIGN KEY (badge_id) REFERENCES badges(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
