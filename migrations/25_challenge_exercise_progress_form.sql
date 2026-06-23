-- Optional form analytics on challenge exercise progress (mobile workout sync).

ALTER TABLE user_challenge_exercise_progress
    ADD COLUMN form_score INT NULL COMMENT 'Latest form score 0-100' AFTER reps_logged,
    ADD COLUMN mistakes JSON NULL COMMENT 'Form mistakes from AI session' AFTER form_score;
