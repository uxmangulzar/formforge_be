-- Workout streak tracking fields on profiles.

ALTER TABLE profiles
    ADD COLUMN longest_streak INT NOT NULL DEFAULT 0 AFTER current_streak,
    ADD COLUMN last_streak_date DATE NULL COMMENT 'Last calendar day counted for workout streak' AFTER longest_streak;
