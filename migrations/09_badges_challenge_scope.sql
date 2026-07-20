-- Scope badges to a challenge (NULL = legacy / unscoped rows)
ALTER TABLE badges ADD COLUMN challenge_id CHAR(36) NULL AFTER id;
CREATE INDEX idx_badges_challenge_id ON badges (challenge_id);
ALTER TABLE badges
    ADD CONSTRAINT fk_badges_challenge_id
    FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE CASCADE;
