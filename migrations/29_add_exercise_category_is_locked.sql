ALTER TABLE exercise_categories
    ADD COLUMN is_locked BOOLEAN NOT NULL DEFAULT FALSE AFTER is_active;
