-- Add total_days column to challenges table
ALTER TABLE `challenges`
ADD COLUMN `total_days` INT UNSIGNED NOT NULL DEFAULT 1 AFTER `reward`;
