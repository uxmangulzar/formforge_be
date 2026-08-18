-- Add type column to challenge_stage_exercises table
ALTER TABLE `challenge_stage_exercises`
ADD COLUMN `type` VARCHAR(50) NOT NULL DEFAULT 'all' AFTER `exercise_id`;
