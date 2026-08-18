-- Add joining_fee and reward to challenges table
ALTER TABLE `challenges`
ADD COLUMN `joining_fee` DECIMAL(10, 2) NOT NULL DEFAULT 0.00 AFTER `status`,
ADD COLUMN `reward` DECIMAL(10, 2) NOT NULL DEFAULT 0.00 AFTER `joining_fee`;

-- Add payment_status and is_winner to user_challenges table
ALTER TABLE `user_challenges`
ADD COLUMN `payment_status` ENUM('free', 'pending', 'paid') NOT NULL DEFAULT 'free' AFTER `status`,
ADD COLUMN `is_winner` TINYINT(1) NOT NULL DEFAULT 0 AFTER `payment_status`;
