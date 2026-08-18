-- Add tags column to challenges table
ALTER TABLE `challenges`
ADD COLUMN `tags` JSON NULL AFTER `reward`;
