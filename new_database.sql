-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.4.3 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.8.0.6908
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for formforge_db
CREATE DATABASE IF NOT EXISTS `formforge_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `formforge_db`;

-- Dumping structure for table formforge_db.admin_notification_settings
CREATE TABLE IF NOT EXISTS `admin_notification_settings` (
  `user_id` char(36) NOT NULL,
  `in_app_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `email_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `allowed_types` json DEFAULT NULL COMMENT 'NULL = all types on; else {"waitlist":true,...}',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_admin_notification_settings_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.admin_notification_settings: ~0 rows (approximately)

-- Dumping structure for table formforge_db.badges
CREATE TABLE IF NOT EXISTS `badges` (
  `id` char(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `icon_url` varchar(500) DEFAULT NULL,
  `rarity` enum('common','rare','epic','legendary') NOT NULL DEFAULT 'common',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `challenge_id` char(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_badges_active` (`is_active`),
  KEY `challenge_id` (`challenge_id`),
  CONSTRAINT `badges_ibfk_1` FOREIGN KEY (`challenge_id`) REFERENCES `challenges` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.badges: ~3 rows (approximately)
INSERT INTO `badges` (`id`, `name`, `description`, `icon_url`, `rarity`, `is_active`, `createdAt`, `updatedAt`, `challenge_id`) VALUES
	('06e81903-8274-4da7-be26-c4636ac115f1', 'golden', NULL, NULL, 'common', 1, '2026-05-13 14:27:18', '2026-05-13 14:27:18', NULL),
	('3163180f-23e9-4e9f-9b5b-74164b133b2f', 'silver', NULL, NULL, 'common', 1, '2026-05-13 14:43:12', '2026-05-13 14:43:12', 'c286a95c-b236-442f-b7a2-3682f4d17b29'),
	('7bfb3b5f-d9b8-4ff8-af9f-debe37b2cb74', 'silver', NULL, NULL, 'common', 1, '2026-05-13 14:26:05', '2026-05-13 14:26:05', NULL);

-- Dumping structure for table formforge_db.badge_rules
CREATE TABLE IF NOT EXISTS `badge_rules` (
  `id` char(36) NOT NULL,
  `badge_id` char(36) NOT NULL,
  `challenge_id` char(36) DEFAULT NULL,
  `trigger_type` enum('points_threshold','challenge_complete','challenge_all_stages','custom') NOT NULL,
  `trigger_config` json DEFAULT NULL,
  `priority` int NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_badge_rules_badge` (`badge_id`),
  KEY `idx_badge_rules_challenge` (`challenge_id`),
  KEY `idx_badge_rules_active` (`is_active`),
  CONSTRAINT `badge_rules_ibfk_37` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `badge_rules_ibfk_38` FOREIGN KEY (`challenge_id`) REFERENCES `challenges` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.badge_rules: ~1 rows (approximately)
INSERT INTO `badge_rules` (`id`, `badge_id`, `challenge_id`, `trigger_type`, `trigger_config`, `priority`, `is_active`, `createdAt`, `updatedAt`) VALUES
	('df3309e6-59d9-4f2a-9502-6196fd98f6f4', '3163180f-23e9-4e9f-9b5b-74164b133b2f', 'c286a95c-b236-442f-b7a2-3682f4d17b29', 'points_threshold', '{"min_points": 100}', 0, 1, '2026-06-22 07:00:51', '2026-06-22 07:00:51');

-- Dumping structure for table formforge_db.challenges
CREATE TABLE IF NOT EXISTS `challenges` (
  `id` char(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `image_urls` json DEFAULT NULL COMMENT 'Array of image URLs (strings)',
  `video_urls` json DEFAULT NULL COMMENT 'Array of video URLs (strings)',
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `starts_at` datetime NOT NULL,
  `ends_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.challenges: ~1 rows (approximately)
INSERT INTO `challenges` (`id`, `name`, `description`, `image_urls`, `video_urls`, `status`, `createdAt`, `updatedAt`, `starts_at`, `ends_at`) VALUES
	('c286a95c-b236-442f-b7a2-3682f4d17b29', 'qwerth', 'sdgsddfs', '[]', '[]', 'published', '2026-05-13 14:10:09', '2026-06-22 07:00:51', '2026-05-13 14:03:00', '2034-06-20 14:03:00');

-- Dumping structure for table formforge_db.challenge_stages
CREATE TABLE IF NOT EXISTS `challenge_stages` (
  `id` char(36) NOT NULL,
  `challenge_id` char(36) NOT NULL,
  `stage_order` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text,
  `points_bonus` int NOT NULL DEFAULT '0',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_challenge_stage_order` (`challenge_id`,`stage_order`),
  KEY `idx_challenge_stages_challenge` (`challenge_id`),
  CONSTRAINT `challenge_stages_ibfk_1` FOREIGN KEY (`challenge_id`) REFERENCES `challenges` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.challenge_stages: ~1 rows (approximately)
INSERT INTO `challenge_stages` (`id`, `challenge_id`, `stage_order`, `title`, `description`, `points_bonus`, `createdAt`, `updatedAt`) VALUES
	('68acec2e-903d-4c26-a0e2-61b6c9b397b6', 'c286a95c-b236-442f-b7a2-3682f4d17b29', 1, 'qwerw', 'dfsfsfsdf', 210, '2026-06-22 07:00:51', '2026-06-22 07:00:51');

-- Dumping structure for table formforge_db.challenge_stage_exercises
CREATE TABLE IF NOT EXISTS `challenge_stage_exercises` (
  `id` char(36) NOT NULL,
  `challenge_stage_id` char(36) NOT NULL,
  `exercise_id` char(36) NOT NULL,
  `sequence_order` int NOT NULL,
  `target_sets` int NOT NULL DEFAULT '1',
  `target_reps` int NOT NULL DEFAULT '1',
  `points_on_complete` int NOT NULL DEFAULT '0',
  `optional` tinyint(1) NOT NULL DEFAULT '0',
  `notes` varchar(500) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_stage_exercise_order` (`challenge_stage_id`,`sequence_order`),
  KEY `idx_cse_stage` (`challenge_stage_id`),
  KEY `idx_cse_exercise` (`exercise_id`),
  CONSTRAINT `challenge_stage_exercises_ibfk_39` FOREIGN KEY (`challenge_stage_id`) REFERENCES `challenge_stages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `challenge_stage_exercises_ibfk_40` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.challenge_stage_exercises: ~3 rows (approximately)
INSERT INTO `challenge_stage_exercises` (`id`, `challenge_stage_id`, `exercise_id`, `sequence_order`, `target_sets`, `target_reps`, `points_on_complete`, `optional`, `notes`, `createdAt`, `updatedAt`) VALUES
	('53889100-9595-4568-9de4-28a406594413', '68acec2e-903d-4c26-a0e2-61b6c9b397b6', '86dc75ba-4bb2-446a-a9aa-27d044209d19', 1, 3, 12, 50, 0, NULL, '2026-06-22 07:00:51', '2026-06-22 07:00:51'),
	('ca82b18c-de17-403e-9f99-16a7d92bc346', '68acec2e-903d-4c26-a0e2-61b6c9b397b6', '845ad01f-4873-11f1-b0b5-c8f7503f9a48', 2, 3, 12, 50, 0, NULL, '2026-06-22 07:00:51', '2026-06-22 07:00:51'),
	('f4506f77-7ea9-4f35-95fd-188dc75d245c', '68acec2e-903d-4c26-a0e2-61b6c9b397b6', '845ac8f8-4873-11f1-b0b5-c8f7503f9a48', 3, 3, 12, 50, 0, NULL, '2026-06-22 07:00:51', '2026-06-22 07:00:51');

-- Dumping structure for table formforge_db.exercises
CREATE TABLE IF NOT EXISTS `exercises` (
  `id` char(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `type` enum('train','play','recover') NOT NULL,
  `category_id` char(36) NOT NULL,
  `description` text,
  `demo_url` varchar(255) DEFAULT NULL,
  `gif_url` varchar(512) DEFAULT NULL,
  `data_url` varchar(255) DEFAULT NULL,
  `difficulty` enum('beginner','intermediate','advanced') DEFAULT 'beginner',
  `target_muscles` json DEFAULT NULL,
  `logic_config` json DEFAULT NULL,
  `rep_counting_logic` json DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_exercises_exercise_category` (`category_id`),
  CONSTRAINT `fk_exercises_exercise_category` FOREIGN KEY (`category_id`) REFERENCES `exercise_categories` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.exercises: ~33 rows (approximately)
INSERT INTO `exercises` (`id`, `name`, `type`, `category_id`, `description`, `demo_url`, `gif_url`, `data_url`, `difficulty`, `target_muscles`, `logic_config`, `rep_counting_logic`, `is_active`, `createdAt`, `updatedAt`) VALUES
	('04e9fc10-eed2-413a-bcc1-eb4140486ad8', 'Sits Ups', 'train', 'a1111111-1111-4111-8111-111111111102', 'Lie on your back.\nBend your knees and place your feet flat on the floor.\nCross your arms over your chest or place fingertips lightly behind your ears.\nTighten your core.\nMovement\nLift your upper body toward your knees.\nKeep the movement controlled.\nExhale as you sit up.\nSlowly lower yourself back to the starting position.\nInhale as you lower down.', '', '', '/uploads/file-1782134096953-630396085.csv', 'beginner', '[]', '{}', '{}', 0, '2026-06-22 13:20:51', '2026-06-22 13:50:05'),
	('095408ef-b323-4549-b7ec-e4092669cea2', 'Standard Squat', 'train', 'a1111111-1111-4111-8111-111111111102', 'Keep your feet shoulder-width apart. Lower your hips as if sitting in a chair, keeping your chest up and back straight.', 'https://assets.formforge.ai/exercises/squat.mp4', '', '', 'beginner', '["Quads", "Glutes", "Hamstrings"]', '{"heel_contact": true, "max_back_lean": 30, "min_knee_angle": 90}', '{"state_a": "standing", "state_b": "descending", "state_c": "squat_point", "threshold": 100}', 0, '2026-05-15 19:07:05', '2026-06-22 11:28:09'),
	('0a9e0ed6-81d9-4395-a0ed-8454af7792df', 'Set Up High Box', 'train', 'a1111111-1111-4111-8111-111111111102', 'Description:\nThe Setup High Box exercise is a lower-body movement that involves stepping onto a high box or platform. It primarily targets the quadriceps, glutes, and hamstrings while also improving balance, coordination, and single-leg strength. The increased box height places greater demand on the working leg compared to a standard step-up.\n\nInstructions:\n\nStand facing a sturdy high box or platform with your feet hip-width apart.\nPlace one foot firmly on top of the box.\nEngage your core and keep your chest lifted.\nPush through the heel of the elevated foot to lift your body onto the box.\nBring the opposite foot onto the box and stand tall at the top.\nStep down carefully, leading with the non-working leg.\nReturn to the starting position with control.\nRepeat for the desired number of repetitions, then switch the leading leg if performing single-leg sets.\n\nTips:\n\nUse a box height that allows proper form without excessive strain.\nDrive through the heel of the working leg rather than pushing off the ground leg.\nKeep your knee aligned with your toes throughout the movement.\nAvoid leaning forward excessively or using momentum.\nMove slowly and maintain balance during both the ascent and descent.', '', '/uploads/gif-1782199192778-685474122.gif', '/uploads/file-1782197387482-972147277.csv', 'beginner', '["Quadriceps", "Gluteus Maximus", "Hamstrings", "Calves,"]', '{}', '{}', 1, '2026-06-23 06:49:49', '2026-06-23 07:19:55'),
	('0eafe471-1d5c-4b5e-a513-e03d39e3d46f', 'Single Leg DeadLift', 'train', 'a1111111-1111-4111-8111-111111111101', 'Instructions:\n\nStand upright with your feet hip-width apart, holding a dumbbell or kettlebell in one or both hands (optional).\nShift your weight onto one leg and slightly bend the knee of the standing leg.\nEngage your core and keep your back straight.\nHinge at the hips while extending the non-working leg straight behind you.\nLower your torso until it is nearly parallel to the floor or until you feel a stretch in your hamstrings.\nKeep your hips square and shoulders level throughout the movement.\nDrive through the heel of the standing leg and squeeze your glute to return to the starting position.\nComplete the desired number of repetitions, then switch legs.\n\nTips:\n\nMaintain a neutral spine and avoid rounding your back.\nKeep a slight bend in the standing knee throughout the exercise.\nMove slowly and with control to improve balance and stability.\nFocus on hinging at the hips rather than bending at the waist.\nIf balance is challenging, perform the movement near a wall or support.', '', '/uploads/gif-1782203468664-406432382.gif', '/uploads/file-1782203450202-161290629.csv', 'beginner', '["Hamstrings", "Gluteus Maximus", "Lower Back,"]', '{}', '{}', 1, '2026-06-23 08:31:12', '2026-06-23 08:31:12'),
	('10043d9d-5467-41b6-8928-426027e92cd0', 'Plank', 'train', 'a1111111-1111-4111-8111-111111111103', 'Isometric core exercise for stability and endurance.', 'https://assets.formforge.ai/exercises/plank.mp4', '', '', 'intermediate', '["Abs", "Lower Back", "Shoulders"]', '{"time_based": true, "back_flatness": 0.9, "hip_height_threshold": 0.2}', '{"type": "duration", "unit": "seconds", "min_hold": 30}', 0, '2026-05-15 15:35:28', '2026-06-22 11:25:45'),
	('1c3cf316-8330-4f67-bf56-b366c61eb85c', 'Warrior Yoga', 'train', 'a1111111-1111-4111-8111-111111111104', 'Instructions\nStand tall with feet together.\nStep one foot back about 3–4 feet.\nTurn the back foot outward about 45°.\nBend the front knee to roughly 90°.\nRaise both arms overhead.\nKeep your chest facing forward.\nHold for 20–30 seconds.\nMuscles Worked\nQuadriceps\nGlutes\nHamstrings\nCore\nShoulders', '', '/uploads/gif-1782143632655-890378430.gif', '/uploads/file-1782134524808-454429574.csv', 'beginner', '["Glutes", "Quadriceps", "Hip Flexors", "Core", "Shoulders", "Inner Thighs"]', '{}', '{}', 1, '2026-06-22 13:24:09', '2026-06-22 15:53:55'),
	('1c98c98d-e943-489d-b792-7e7b20394e36', 'CONCENTRATION CURL', 'train', 'a1111111-1111-4111-8111-111111111101', 'The Concentration Curl is an isolation exercise that targets the biceps brachii. It is performed while seated, with the working arm braced against the inner thigh to minimize body movement and focus tension directly on the biceps. This exercise helps improve arm strength, muscle definition, and peak bicep development.\n\nInstructions:\n\nSit on a bench with your feet flat on the floor and knees apart.\nHold a dumbbell in one hand with your palm facing upward.\nRest the back of your upper arm against the inside of the same-side thigh.\nExtend your arm downward until it is almost fully straight.\nCurl the dumbbell upward toward your shoulder while keeping your upper arm stationary.\nSqueeze your bicep at the top of the movement.\nSlowly lower the dumbbell back to the starting position in a controlled manner.\nComplete the desired number of repetitions, then switch arms.\n\nTips:\n\nKeep your elbow fixed against your thigh throughout the movement.\nAvoid swinging the weight or using momentum.\nFocus on a full range of motion and controlled tempo.\nExhale while curling up and inhale while lowering the weight.\n\nPrimary Muscle: Biceps Brachii\nSecondary Muscles: Brachialis, Brachioradialis\nEquipment: Dumbbell\nDifficulty Level: Beginner to Intermediate', '', '/uploads/gif-1782193316720-247629714.gif', '/uploads/file-1782193296977-667957888.csv', 'beginner', '[]', '{}', '{}', 1, '2026-06-23 05:42:42', '2026-06-23 05:42:42'),
	('20b6556a-873e-472e-9348-eda5097f1dd6', 'Pushups', 'train', 'a1111111-1111-4111-8111-111111111101', 'A classic upper body exercise for chest, triceps, and shoulders.', '', '', '/uploads/file-1782127623927-361078430.csv', 'intermediate', '["Chest", "Triceps", "Shoulders"]', '{"body_straight": true, "hand_placement": "shoulder_width", "min_elbow_angle": 70}', '{"state_a": "high_plank", "state_b": "low_plank", "threshold": 0.5}', 0, '2026-05-15 19:07:05', '2026-06-22 15:41:26'),
	('32d3d42f-e926-4904-a550-d49fa7bdaf62', 'Chest Press', 'train', 'a1111111-1111-4111-8111-111111111101', 'Starting Position\nLie flat on a bench.\nHold a dumbbell in each hand.\nPosition the dumbbells at chest level.\nKeep your feet flat on the floor.\nEngage your core.\nMovement\nPress the dumbbells upward until your arms are almost straight.\nSqueeze your chest at the top.\nSlowly lower the weights back to chest level.\nRepeat.', '', '/uploads/gif-1782142263361-221652714.gif', '/uploads/file-1782134471794-355134312.csv', 'beginner', '[]', '{}', '{}', 1, '2026-06-22 13:21:50', '2026-06-22 15:31:05'),
	('36977cbc-7ae7-4d27-beb0-e2d2889126c1', 'Squats', 'train', 'a1111111-1111-4111-8111-111111111102', 'A fundamental lower body exercise that targets the quads, glutes, and hamstrings.', '', '/uploads/gif-1782143283548-595003656.gif', '/uploads/file-1782127672702-307990092.csv', 'beginner', '["Quads", "Glutes", "Hamstrings"]', '{"heel_contact": true, "max_back_lean": 30, "knee_alignment": "toes"}', '{"state_a": "standing", "state_b": "deep_squat", "min_depth": 90}', 1, '2026-05-15 19:07:05', '2026-06-22 15:48:06'),
	('3a52c682-5111-4698-8ffa-45d70b004522', 'Plank', 'train', 'a1111111-1111-4111-8111-111111111103', 'Isometric core exercise for stability and endurance.', 'https://assets.formforge.ai/exercises/plank.mp4', '/uploads/gif-1782141744671-987963904.gif', '/uploads/file-1782127470160-60515610.csv', 'intermediate', '["Abs", "Lower Back", "Shoulders"]', '{"time_based": true, "back_flatness": 0.9, "hip_height_threshold": 0.2}', '{"type": "duration", "unit": "seconds", "min_hold": 30}', 1, '2026-05-15 19:07:05', '2026-06-22 15:22:28'),
	('4ad754fd-05c7-448c-8c33-9d089ad454ad', 'Single Leg Squat', 'train', 'a1111111-1111-4111-8111-111111111103', 'Instructions:\n\nStand upright with your feet hip-width apart.\nShift your weight onto one leg and lift the opposite foot slightly off the ground in front of you.\nEngage your core and keep your chest up.\nSlowly bend the knee of the standing leg and push your hips back as you lower into a squat.\nLower as far as you can while maintaining balance and proper form.\nKeep the standing knee aligned with your toes throughout the movement.\nPush through the heel of the working leg to return to the starting position.\nComplete the desired number of repetitions, then switch legs.\n\nTips:\n\nKeep your chest lifted and back neutral throughout the exercise.\nAvoid letting the knee collapse inward.\nUse a controlled tempo and focus on balance.\nExtend your arms forward for additional stability if needed.\nReduce the depth or use a support if you are new to the movement.', '', '/uploads/gif-1782206065875-442888218.gif', '/uploads/file-1782206043804-738160371.csv', 'beginner', '["Quadriceps", "Gluteus Maximus", "Hamstrings", "Gluteus Medius,", "Core Stabilizers"]', '{}', '{}', 1, '2026-06-23 09:15:42', '2026-06-23 09:15:42'),
	('509880db-396c-428e-908c-59e76e79152b', 'Triceps', 'play', 'a1111111-1111-4111-8111-111111111101', 'Stand facing a cable machine.\nGrab the rope or straight bar.\nKeep elbows close to your sides.\nPush the handle down until arms are fully extended.\nSlowly return to the starting position.\n\nSets/Reps: 3–4 sets × 10–15 reps', '', '/uploads/gif-1782141668413-496017896.gif', '/uploads/file-1782131944826-240611510.csv', 'beginner', '["Triceps"]', '{}', '{}', 1, '2026-06-22 12:40:49', '2026-06-22 15:21:10'),
	('559bfc32-4d6b-4a8e-aad3-c465f89d13e0', 'Lunges', 'train', 'a1111111-1111-4111-8111-111111111102', 'Unilateral lower body exercise for balance and strength.', '', '/uploads/gif-1782127080318-48138396.gif', '/uploads/file-1782126754822-722704296.csv', 'beginner', '["Quads", "Glutes", "Hip Flexors"]', '{"torso_upright": true, "knee_angle_front": 90, "balance_stability": 0.8}', '{"alternating": true, "count_per_leg": true}', 1, '2026-05-15 19:07:05', '2026-06-22 11:20:09'),
	('578b3dbd-dad4-40f2-a363-ae50b52cdd52', 'Lunges', 'train', 'a1111111-1111-4111-8111-111111111102', 'Unilateral lower body exercise for balance and strength.', NULL, NULL, NULL, 'beginner', '["Quads", "Glutes", "Hip Flexors"]', '{"torso_upright": true, "knee_angle_front": 90, "balance_stability": 0.8}', '{"alternating": true, "count_per_leg": true}', 0, '2026-05-12 08:20:03', '2026-06-22 11:25:21'),
	('58134982-b74b-4599-87b0-31e28dbe5996', 'Biseps curl', 'train', 'a1111111-1111-4111-8111-111111111101', 'Starting Position\nStand with feet shoulder-width apart.\nHold a dumbbell in each hand.\nLet your arms hang at your sides.\nKeep palms facing forward.\nMovement\nKeep your elbows close to your body.\nCurl the dumbbells toward your shoulders.\nSqueeze your biceps at the top.\nSlowly lower the weights back down.\nRepeat.', '', '/uploads/gif-1782198971545-353974622.gif', '/uploads/file-1782136312845-186440230.csv', 'beginner', '[]', '{}', '{}', 1, '2026-06-22 13:52:49', '2026-06-23 07:16:15'),
	('6387ae2e-1272-4a17-b263-475dd4f8e562', 'Biseps', 'train', 'a1111111-1111-4111-8111-111111111101', 'Stand upright holding dumbbells at your sides.\nKeep elbows close to your body.\nCurl the weights toward your shoulders.\nSqueeze your biceps at the top.\nLower slowly.\n\n3–4 sets × 10–12 reps', '', '/uploads/gif-1782142574741-406175671.gif', '/uploads/file-1782136228623-353341038.csv', 'beginner', '["muscles"]', '{}', '{}', 1, '2026-06-22 13:51:38', '2026-06-22 16:07:39'),
	('7e0ae5f4-75c3-4ba0-8224-5472d9667281', 'Glute Activation', 'train', 'a1111111-1111-4111-8111-111111111102', 'Quick Standing Glute Activation Routine (3–5 Minutes)\nStanding Kickbacks – 15 reps/leg\nStanding Hip Abductions – 15 reps/leg\nBanded Lateral Walks – 10 steps each way\nDiagonal Kickbacks – 15 reps/leg\n\nRepeat 2 rounds before squats, lunges, or lower-body workouts.', '', '/uploads/gif-1782142303484-212172025.gif', '/uploads/file-1782133892419-498106602.csv', 'beginner', '[]', '{}', '{}', 1, '2026-06-22 13:13:04', '2026-06-22 15:31:44'),
	('8459a4e2-4873-11f1-b0b5-c8f7503f9a48', 'Standard Squat', 'train', 'a1111111-1111-4111-8111-111111111102', 'Keep your feet shoulder-width apart. Lower your hips as if sitting in a chair, keeping your chest up and back straight.', 'https://assets.formforge.ai/exercises/squat.mp4', NULL, NULL, 'beginner', '["Quads", "Glutes", "Hamstrings"]', '{"heel_contact": true, "max_back_lean": 30, "min_knee_angle": 90}', '{"state_a": "standing", "state_b": "descending", "state_c": "squat_point", "threshold": 100}', 0, '2026-05-05 11:14:00', '2026-06-22 11:28:10'),
	('845ac1ed-4873-11f1-b0b5-c8f7503f9a48', 'Push-up', 'train', 'a1111111-1111-4111-8111-111111111101', 'Start in a plank position. Lower your body until your chest nearly touches the floor, then push back up.', 'https://assets.formforge.ai/exercises/pushup.mp4', NULL, '/uploads/file-1778576693395-205117979.xlsx', 'beginner', '["Chest", "Triceps", "Shoulders"]', '{"min_elbow_angle": 70, "body_straightness_threshold": 165}', '{"state_a": "high_plank", "state_b": "lowering", "state_c": "bottom_point"}', 0, '2026-05-05 11:14:00', '2026-06-22 11:25:54'),
	('845ac8f8-4873-11f1-b0b5-c8f7503f9a48', 'Walking Lunge', 'train', 'a1111111-1111-4111-8111-111111111102', 'Step forward with one leg and lower your hips until both knees are bent at a 90-degree angle.', 'https://assets.formforge.ai/exercises/lunge.mp4', NULL, NULL, 'intermediate', '["Quads", "Glutes", "Hip Flexors"]', '{"balance_stability": 0.8, "knee_angle_target": 90}', '{"count_per_leg": true}', 0, '2026-05-05 11:14:00', '2026-06-22 11:28:12'),
	('845ad01f-4873-11f1-b0b5-c8f7503f9a48', 'Plank', 'train', 'a1111111-1111-4111-8111-111111111103', 'Isometric core exercise for stability and endurance.', 'https://assets.formforge.ai/exercises/plank.mp4', NULL, NULL, 'intermediate', '["Abs", "Lower Back", "Shoulders"]', '{"time_based": true, "back_flatness": 0.9, "hip_height_threshold": 0.2}', '{"type": "duration", "unit": "seconds", "min_hold": 30}', 0, '2026-05-05 11:14:00', '2026-06-22 11:25:46'),
	('86dc75ba-4bb2-446a-a9aa-27d044209d19', 'Squats', 'train', 'a1111111-1111-4111-8111-111111111102', 'A fundamental lower body exercise that targets the quads, glutes, and hamstrings.', NULL, NULL, NULL, 'beginner', '["Quads", "Glutes", "Hamstrings"]', '{"heel_contact": true, "max_back_lean": 30, "knee_alignment": "toes"}', '{"state_a": "standing", "state_b": "deep_squat", "min_depth": 90}', 0, '2026-05-12 08:20:02', '2026-06-22 11:28:08'),
	('888594f4-f2ca-4038-b088-d8b4da1212e8', 'Dead Lift ', 'train', 'a1111111-1111-4111-8111-111111111103', 'Stand with feet hip-width apart.\nPosition the bar over the middle of your feet.\nBend at the hips and knees to grip the bar.\nKeep your chest up and back neutral.\nEngage your core and lats.\nLift\nPush through your heels.\nExtend your knees and hips together.\nKeep the bar close to your body.\nStand tall and squeeze your glutes at the top.\nLowering\nPush your hips back first.\nLower the bar along your legs.\nBend your knees once the bar passes them.\nReturn the bar to the floor under control.', '', '/uploads/gif-1782142468340-143550773.gif', '/uploads/file-1782134005870-489885602.csv', 'beginner', '["Back"]', '{}', '{}', 1, '2026-06-22 13:14:37', '2026-06-22 15:34:31'),
	('94f19831-9b37-40ac-8129-5aa2ce7ec0aa', 'Push-up', 'train', 'a1111111-1111-4111-8111-111111111101', 'Start in a plank position. Lower your body until your chest nearly touches the floor, then push back up.', 'https://assets.formforge.ai/exercises/pushup.mp4', '/uploads/gif-1782142895672-914577791.gif', '/uploads/file-1782127569339-204353954.csv', 'beginner', '["Chest", "Triceps", "Shoulders"]', '{"min_elbow_angle": 70, "body_straightness_threshold": 165}', '{"state_a": "high_plank", "state_b": "lowering", "state_c": "bottom_point"}', 1, '2026-05-15 19:07:05', '2026-06-22 15:41:38'),
	('99d8f3fd-9dcb-4a36-b373-62f7b61c1820', 'Single Leg Calf', 'train', 'a1111111-1111-4111-8111-111111111102', 'Stand on one leg on a step or flat floor. Hold a wall or chair for balance.\nLift the other foot off the ground (bend knee, foot behind standing leg).\nLower the heel of your standing foot slowly until you feel a stretch in the calf. Don’t slam the heel down.\nPush up through the ball of your foot and rise onto your toes as high as you can.\nSqueeze the calf at the top for 1–2 seconds.\nLower back down with control.\nDo 15–20 reps, then switch legs.', '', '/uploads/gif-1782129911348-323882838.gif', '/uploads/file-1782131082050-109746432.csv', 'beginner', '["Gastrocnemius", "Soleus", "Tibialis anterior", "Gluteus medius", "Core (abdominals)"]', '{}', '{}', 1, '2026-06-22 12:08:30', '2026-06-22 12:24:45'),
	('9ea6ee94-da2c-4bcf-b586-8e0e8fb781d5', 'Pushups', 'train', 'a1111111-1111-4111-8111-111111111101', 'A classic upper body exercise for chest, triceps, and shoulders.', '', NULL, '/uploads/file-1778576614070-711236569.xlsx', 'intermediate', '["Chest", "Triceps", "Shoulders"]', '{"body_straight": true, "hand_placement": "shoulder_width", "min_elbow_angle": 70}', '{"state_a": "high_plank", "state_b": "low_plank", "threshold": 0.5}', 0, '2026-05-12 08:20:03', '2026-06-22 11:26:54'),
	('ab1a0dfb-77cd-4c2f-93b3-9c10b6aef938', 'Jumping Jack', 'train', 'a1111111-1111-4111-8111-111111111104', 'Instructions:\n\nStand upright with your feet together and arms resting at your sides.\nJump your feet outward to about shoulder-width or wider while simultaneously raising your arms overhead.\nLand softly on the balls of your feet with your knees slightly bent.\nQuickly jump back to the starting position, bringing your feet together and lowering your arms to your sides.\nContinue the movement in a smooth, rhythmic manner for the desired number of repetitions or duration.\n\nTips:\n\nMaintain an upright posture throughout the exercise.\nLand softly to reduce impact on your joints.\nKeep your core engaged to support proper body alignment.\nCoordinate your arm and leg movements for a smooth rhythm.\nBreathe naturally and maintain a steady pace.', '', '/uploads/gif-1782218384850-73331732.gif', '/uploads/file-1782217356958-10780086.csv', 'beginner', '["Quadriceps", "Glutes", "Calves", "Deltoids", "Hamstrings", ", Hip Flexors, Core Stabilizers"]', '{}', '{}', 0, '2026-06-23 12:22:56', '2026-06-23 12:39:48'),
	('c144ba27-8353-4411-b80f-a56747999111', 'Pike Push', 'train', 'a1111111-1111-4111-8111-111111111101', 'Instructions:\n\nStart in a push-up position with your hands slightly wider than shoulder-width apart.\nLift your hips toward the ceiling to form an inverted "V" shape with your body.\nKeep your legs as straight as comfortably possible and your core engaged.\nBend your elbows and lower your head toward the floor between your hands.\nContinue lowering until your head is just above the ground.\nPress through your palms and straighten your arms to return to the starting position.\nRepeat for the desired number of repetitions.\n\nTips:\n\nKeep your core tight and maintain the pike position throughout the movement.\nFocus on lowering your head between your hands rather than forward.\nAvoid flaring your elbows excessively.\nMove slowly and with control to maximize shoulder engagement.\nAdjust your foot position closer to your hands to increase shoulder emphasis.', '', '/uploads/gif-1782214777203-544587844.gif', '/uploads/file-1782214709037-375976969.csv', 'intermediate', '["Anterior Deltoids", "Medial Deltoids", "Triceps", "Upper Chest", "Serratus Anterior,"]', '{}', '{}', 1, '2026-06-23 11:39:43', '2026-06-23 11:39:43'),
	('c421248c-706c-46fe-b73e-d016937bfdfa', 'Dumbell Crunches ', 'train', 'a1111111-1111-4111-8111-111111111101', 'Instructions:\n\nLie on your back on an exercise mat with your knees bent and feet flat on the floor.\nHold a dumbbell securely against your chest or just above your chest with both hands.\nEngage your core and keep your lower back in contact with the floor.\nLift your head, shoulders, and upper back off the ground by contracting your abdominal muscles.\nPause briefly at the top and squeeze your abs.\nSlowly lower your upper body back to the starting position in a controlled manner.\nRepeat for the desired number of repetitions.\n\nTips:\n\nKeep the movement slow and controlled; avoid using momentum.\nFocus on lifting with your abdominal muscles rather than pulling with your neck.\nKeep your chin slightly tucked and your neck relaxed.\nExhale as you crunch upward and inhale as you lower down.\nChoose a weight that allows proper form throughout the set.', '', '/uploads/gif-1782211699197-67269547.gif', '/uploads/file-1782211708472-101393995.csv', 'beginner', '["Rectus Abdominis", "Obliques", "Transverse Abdominis", "Hip Flexors"]', '{}', '{}', 1, '2026-06-23 10:48:32', '2026-06-23 10:49:55'),
	('e27c9e80-2eff-45c5-83df-993abb888df5', 'Shoulder Press', 'train', 'a1111111-1111-4111-8111-111111111101', 'Starting Position\nSit on a bench with back support or stand upright.\nHold a dumbbell in each hand at shoulder level.\nPalms should face forward.\nKeep your chest up and core tight.\nMovement\nPress the dumbbells upward until your arms are almost fully extended.\nDo not lock your elbows aggressively.\nPause briefly at the top.\nSlowly lower the weights back to shoulder level.\nRepeat.', '', '/uploads/gif-1782142856652-124768764.gif', '/uploads/file-1782133772421-272351192.csv', 'beginner', '["shoulder"]', '{}', '{}', 1, '2026-06-22 13:10:31', '2026-06-22 15:40:59'),
	('eeefad65-8dc5-4b90-b29d-3527d4294555', 'Walking Lunge', 'train', 'a1111111-1111-4111-8111-111111111102', 'Step forward with one leg and lower your hips until both knees are bent at a 90-degree angle.', 'https://assets.formforge.ai/exercises/lunge.mp4', '/uploads/gif-1782143386361-891558121.gif', '/uploads/file-1782127701820-768128256.csv', 'intermediate', '["Quads", "Glutes", "Hip Flexors"]', '{"balance_stability": 0.8, "knee_angle_target": 90}', '{"count_per_leg": true}', 1, '2026-05-15 19:07:05', '2026-06-22 15:49:49'),
	('f68763ea-aae8-4a0d-8559-5b3ee922f07b', 'Jumping Jack', 'train', 'a1111111-1111-4111-8111-111111111104', 'Instructions:\n\nStand upright with your feet together and arms resting at your sides.\nJump your feet outward to about shoulder-width or wider while simultaneously raising your arms overhead.\nLand softly on the balls of your feet with your knees slightly bent.\nQuickly jump back to the starting position, bringing your feet together and lowering your arms to your sides.\nContinue the movement in a smooth, rhythmic manner for the desired number of repetitions or duration.\n\nTips:\n\nMaintain an upright posture throughout the exercise.\nLand softly to reduce impact on your joints.\nKeep your core engaged to support proper body alignment.\nCoordinate your arm and leg movements for a smooth rhythm.\nBreathe naturally and maintain a steady pace.', '', '/uploads/gif-1782218620681-211070904.gif', '/uploads/file-1782217356958-10780086.csv', 'beginner', '["Quadriceps", "Glutes", "Calves", "Deltoids", "Hamstrings", ", Hip Flexors, Core Stabilizers"]', '{}', '{}', 1, '2026-06-23 12:22:56', '2026-06-23 12:43:43');

-- Dumping structure for table formforge_db.exercise_categories
CREATE TABLE IF NOT EXISTS `exercise_categories` (
  `id` char(36) NOT NULL,
  `slug` varchar(64) NOT NULL,
  `display_name` varchar(120) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.exercise_categories: ~4 rows (approximately)
INSERT INTO `exercise_categories` (`id`, `slug`, `display_name`, `description`, `sort_order`, `is_active`, `createdAt`, `updatedAt`) VALUES
	('60ebe7d8-09fd-4eb5-a9e7-0489c494690f', 'cardio', 'Cardio', NULL, 50, 1, '2026-05-15 19:07:58', '2026-05-15 19:07:58'),
	('a1111111-1111-4111-8111-111111111101', 'upper_body', 'Upper Body', NULL, 10, 1, '2026-05-14 18:29:41', '2026-05-15 19:07:37'),
	('a1111111-1111-4111-8111-111111111102', 'lower_body', 'Lower Body', NULL, 20, 1, '2026-05-14 18:29:41', '2026-05-14 18:29:41'),
	('a1111111-1111-4111-8111-111111111103', 'core', 'Core', NULL, 30, 1, '2026-05-14 18:29:41', '2026-05-14 18:29:41'),
	('a1111111-1111-4111-8111-111111111104', 'full_body', 'Full Body', NULL, 40, 1, '2026-05-14 18:29:41', '2026-05-14 18:29:41');

-- Dumping structure for table formforge_db.exercise_training_modes
CREATE TABLE IF NOT EXISTS `exercise_training_modes` (
  `exercise_id` char(36) NOT NULL,
  `mode_id` char(36) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`exercise_id`,`mode_id`),
  KEY `idx_exercise_training_modes_mode` (`mode_id`),
  CONSTRAINT `fk_exercise_training_modes_exercise` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_exercise_training_modes_mode` FOREIGN KEY (`mode_id`) REFERENCES `training_modes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.exercise_training_modes: ~20 rows (approximately)
INSERT INTO `exercise_training_modes` (`exercise_id`, `mode_id`, `createdAt`, `updatedAt`) VALUES
	('578b3dbd-dad4-40f2-a363-ae50b52cdd52', 'a0000001-0001-4001-8001-000000000001', '2026-05-14 10:22:19', '2026-05-14 10:22:19'),
	('578b3dbd-dad4-40f2-a363-ae50b52cdd52', 'a0000001-0001-4001-8001-000000000002', '2026-05-14 13:02:32', '2026-05-14 13:02:32'),
	('578b3dbd-dad4-40f2-a363-ae50b52cdd52', 'a0000001-0001-4001-8001-000000000003', '2026-05-14 13:02:32', '2026-05-14 13:02:32'),
	('8459a4e2-4873-11f1-b0b5-c8f7503f9a48', 'a0000001-0001-4001-8001-000000000001', '2026-05-14 10:22:19', '2026-05-14 10:22:19'),
	('8459a4e2-4873-11f1-b0b5-c8f7503f9a48', 'a0000001-0001-4001-8001-000000000002', '2026-05-14 13:02:32', '2026-05-14 13:02:32'),
	('8459a4e2-4873-11f1-b0b5-c8f7503f9a48', 'a0000001-0001-4001-8001-000000000003', '2026-05-14 13:02:32', '2026-05-14 13:02:32'),
	('845ac1ed-4873-11f1-b0b5-c8f7503f9a48', 'a0000001-0001-4001-8001-000000000001', '2026-05-14 10:22:19', '2026-05-14 10:22:19'),
	('845ac1ed-4873-11f1-b0b5-c8f7503f9a48', 'a0000001-0001-4001-8001-000000000002', '2026-05-14 13:02:32', '2026-05-14 13:02:32'),
	('845ac1ed-4873-11f1-b0b5-c8f7503f9a48', 'a0000001-0001-4001-8001-000000000003', '2026-05-14 13:02:32', '2026-05-14 13:02:32'),
	('845ac8f8-4873-11f1-b0b5-c8f7503f9a48', 'a0000001-0001-4001-8001-000000000002', '2026-05-14 13:02:32', '2026-05-14 13:02:32'),
	('845ac8f8-4873-11f1-b0b5-c8f7503f9a48', 'a0000001-0001-4001-8001-000000000003', '2026-05-14 13:02:32', '2026-05-14 13:02:32'),
	('845ad01f-4873-11f1-b0b5-c8f7503f9a48', 'a0000001-0001-4001-8001-000000000001', '2026-05-14 10:22:19', '2026-05-14 10:22:19'),
	('845ad01f-4873-11f1-b0b5-c8f7503f9a48', 'a0000001-0001-4001-8001-000000000002', '2026-05-14 13:02:32', '2026-05-14 13:02:32'),
	('845ad01f-4873-11f1-b0b5-c8f7503f9a48', 'a0000001-0001-4001-8001-000000000003', '2026-05-14 13:02:32', '2026-05-14 13:02:32'),
	('86dc75ba-4bb2-446a-a9aa-27d044209d19', 'a0000001-0001-4001-8001-000000000001', '2026-05-14 10:22:19', '2026-05-14 10:22:19'),
	('86dc75ba-4bb2-446a-a9aa-27d044209d19', 'a0000001-0001-4001-8001-000000000002', '2026-05-14 13:02:32', '2026-05-14 13:02:32'),
	('86dc75ba-4bb2-446a-a9aa-27d044209d19', 'a0000001-0001-4001-8001-000000000003', '2026-05-14 13:02:32', '2026-05-14 13:02:32'),
	('9ea6ee94-da2c-4bcf-b586-8e0e8fb781d5', 'a0000001-0001-4001-8001-000000000001', '2026-05-14 10:22:19', '2026-05-14 10:22:19'),
	('9ea6ee94-da2c-4bcf-b586-8e0e8fb781d5', 'a0000001-0001-4001-8001-000000000002', '2026-05-14 13:02:32', '2026-05-14 13:02:32'),
	('9ea6ee94-da2c-4bcf-b586-8e0e8fb781d5', 'a0000001-0001-4001-8001-000000000003', '2026-05-14 13:02:32', '2026-05-14 13:02:32');

-- Dumping structure for table formforge_db.notifications
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` char(36) NOT NULL,
  `recipient_user_id` char(36) NOT NULL COMMENT 'Admin user who sees this row',
  `type` varchar(64) NOT NULL COMMENT 'e.g. waitlist_signup, user_registered, system',
  `title` varchar(255) NOT NULL,
  `body` text,
  `metadata` json DEFAULT NULL COMMENT 'Optional payload: urls, entity ids, etc.',
  `read_at` datetime DEFAULT NULL COMMENT 'NULL = unread',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_notifications_recipient_unread` (`recipient_user_id`,`read_at`),
  KEY `idx_notifications_recipient_created` (`recipient_user_id`,`createdAt`),
  CONSTRAINT `fk_notifications_recipient` FOREIGN KEY (`recipient_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.notifications: ~4 rows (approximately)
INSERT INTO `notifications` (`id`, `recipient_user_id`, `type`, `title`, `body`, `metadata`, `read_at`, `createdAt`, `updatedAt`) VALUES
	('854b12e4-4f83-11f1-a4c6-c8f7503f9a48', '0f7bc9e7-df4b-4353-b728-28901567e14d', 'system', 'Notifications live', 'Sample in-app message. Bell + GET list can use this row.', '{"path": "/settings"}', '2026-05-14 11:20:37', '2026-05-14 15:54:12', '2026-05-14 11:20:37'),
	('854b1497-4f83-11f1-a4c6-c8f7503f9a48', '0f7bc9e7-df4b-4353-b728-28901567e14d', 'waitlist', 'Waitlist activity (sample)', 'Placeholder text — replace with real inserts from waitlist flow.', '{"path": "/waitlist"}', '2026-05-14 11:20:37', '2026-05-14 15:41:12', '2026-05-14 11:20:37'),
	('854b14be-4f83-11f1-a4c6-c8f7503f9a48', '0f7bc9e7-df4b-4353-b728-28901567e14d', 'user_registered', 'New user (sample)', 'Sample registration alert for API testing.', '{"path": "/users"}', '2026-05-14 11:20:31', '2026-05-14 14:56:12', '2026-05-14 11:20:31'),
	('854b14d2-4f83-11f1-a4c6-c8f7503f9a48', '0f7bc9e7-df4b-4353-b728-28901567e14d', 'system', 'Already read (sample)', 'This row has read_at set — use for unread-count vs read tests.', NULL, '2026-05-14 15:56:12', '2026-05-14 13:56:12', '2026-05-14 13:56:12');

-- Dumping structure for table formforge_db.profiles
CREATE TABLE IF NOT EXISTS `profiles` (
  `id` char(36) NOT NULL,
  `user_id` char(36) NOT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `avatar_url` varchar(255) DEFAULT NULL,
  `age` int DEFAULT NULL,
  `fitness_level` enum('beginner','intermediate','advanced') DEFAULT 'beginner',
  `goal` text,
  `injury_history` text,
  `total_xp` int DEFAULT '0',
  `level` int DEFAULT '1',
  `current_streak` int DEFAULT '0',
  `longest_streak` int NOT NULL DEFAULT '0',
  `last_streak_date` date DEFAULT NULL COMMENT 'Last calendar day counted for workout streak',
  `preferred_language` varchar(10) DEFAULT 'en',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.profiles: ~10 rows (approximately)
INSERT INTO `profiles` (`id`, `user_id`, `full_name`, `avatar_url`, `age`, `fitness_level`, `goal`, `injury_history`, `total_xp`, `level`, `current_streak`, `longest_streak`, `last_streak_date`, `preferred_language`, `createdAt`, `updatedAt`) VALUES
	('0d102ace-d9ea-40e0-a603-ac386c54abd9', 'b586d41f-bd1d-4cd0-b11b-5bad3296f31b', 'g@gmail.com', NULL, NULL, 'intermediate', 'Lose weight', NULL, 0, 1, 0, 0, NULL, 'English', '2026-06-19 13:05:40', '2026-06-19 13:05:44'),
	('19ae9900-1f26-4f57-80d8-58952f9865bd', '2769c2cd-73c0-42ce-aabb-b53814a628fe', NULL, NULL, NULL, 'beginner', NULL, NULL, 0, 1, 0, 0, NULL, 'en', '2026-06-17 12:21:05', '2026-06-17 12:21:05'),
	('270eb612-d969-4b72-924a-c01033c2463d', 'd977d0f2-32ad-49bc-815e-1e8fdd8bd528', 'a@gmail.com', NULL, NULL, 'intermediate', 'Lose weight', NULL, 0, 1, 0, 0, NULL, 'English', '2026-06-19 13:02:31', '2026-06-19 13:02:40'),
	('362b7700-700c-4a75-b9ec-f5fb8bce105b', 'a5709dd8-73e6-4054-9140-d66de8883d4c', 'blingset42@gmail.com', NULL, NULL, 'intermediate', 'Lose weight', NULL, 0, 1, 0, 0, NULL, 'English', '2026-06-22 05:57:53', '2026-06-22 05:57:57'),
	('58b9362e-e0ef-43d9-8332-cbc0ecf22083', '2f09d0b2-4ac5-4461-8114-e89dfd155bc8', 'musmangul99@gmail.com', NULL, NULL, 'intermediate', 'Lose weight', NULL, 0, 1, 0, 0, NULL, 'English', '2026-06-19 14:42:20', '2026-06-19 14:44:23'),
	('70d40c1d-2561-44e8-b900-9b56d6db65b5', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', 'hamdann@gmail.com', NULL, 111, 'intermediate', 'Lose weight', NULL, 2785, 1, 2, 2, '2026-06-23', 'English', '2026-06-19 13:19:07', '2026-06-23 11:21:34'),
	('8791d628-4eb9-4a63-a18c-da64739250a3', '189df97a-adaa-445a-bd74-065c890092dc', 'mohsancode1@gmail.com', NULL, NULL, 'intermediate', 'Lose weight', NULL, 0, 1, 0, 0, NULL, 'English', '2026-06-19 12:47:01', '2026-06-19 14:20:43'),
	('a4b1fbbd-6b20-4b05-87e4-064435d493c9', 'e83c8333-0c43-48dc-b3ca-1d5a046ad49c', 'Mohsan Ali', NULL, 26, 'beginner', 'qwertyu', '', 0, 1, 0, 0, NULL, 'en', '2026-05-12 10:39:10', '2026-05-12 11:31:54'),
	('ce5ff15a-7901-4f6e-ad0b-0fa11027694f', 'a56b6a5f-7d73-41d3-8d82-018600a206a9', 'hamdanmansoor5490@gmail.com', NULL, NULL, 'intermediate', 'Lose weight', NULL, 0, 1, 0, 0, NULL, 'English', '2026-06-19 16:29:36', '2026-06-19 16:29:42'),
	('d44fdafc-5bba-4f87-997d-76afa995065d', '0f7bc9e7-df4b-4353-b728-28901567e14d', 'Admin', NULL, NULL, 'beginner', NULL, NULL, 0, 1, 0, 0, NULL, 'en', '2026-05-05 15:42:57', '2026-05-05 15:42:57');

-- Dumping structure for table formforge_db.settings
CREATE TABLE IF NOT EXISTS `settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(255) NOT NULL,
  `setting_value` text,
  `description` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`),
  UNIQUE KEY `setting_key_2` (`setting_key`),
  UNIQUE KEY `setting_key_3` (`setting_key`),
  UNIQUE KEY `setting_key_4` (`setting_key`),
  UNIQUE KEY `setting_key_5` (`setting_key`),
  UNIQUE KEY `setting_key_6` (`setting_key`),
  UNIQUE KEY `setting_key_7` (`setting_key`),
  UNIQUE KEY `setting_key_8` (`setting_key`),
  UNIQUE KEY `setting_key_9` (`setting_key`),
  UNIQUE KEY `setting_key_10` (`setting_key`),
  UNIQUE KEY `setting_key_11` (`setting_key`),
  UNIQUE KEY `setting_key_12` (`setting_key`),
  UNIQUE KEY `setting_key_13` (`setting_key`),
  UNIQUE KEY `setting_key_14` (`setting_key`),
  UNIQUE KEY `setting_key_15` (`setting_key`),
  UNIQUE KEY `setting_key_16` (`setting_key`),
  UNIQUE KEY `setting_key_17` (`setting_key`),
  UNIQUE KEY `setting_key_18` (`setting_key`),
  UNIQUE KEY `setting_key_19` (`setting_key`),
  UNIQUE KEY `setting_key_20` (`setting_key`),
  UNIQUE KEY `setting_key_21` (`setting_key`),
  UNIQUE KEY `setting_key_22` (`setting_key`),
  UNIQUE KEY `setting_key_23` (`setting_key`),
  UNIQUE KEY `setting_key_24` (`setting_key`),
  UNIQUE KEY `setting_key_25` (`setting_key`),
  UNIQUE KEY `setting_key_26` (`setting_key`),
  UNIQUE KEY `setting_key_27` (`setting_key`),
  UNIQUE KEY `setting_key_28` (`setting_key`),
  UNIQUE KEY `setting_key_29` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.settings: ~3 rows (approximately)
INSERT INTO `settings` (`id`, `setting_key`, `setting_value`, `description`, `createdAt`, `updatedAt`, `is_active`) VALUES
	(1, 'maintenance_mode', 'false', 'Enable or disable landing page maintenance mode', '2026-05-01 12:42:43', '2026-05-01 12:42:43', 1),
	(2, 'max_waitlist_spots', '10000', 'Maximum number of users allowed in waitlist', '2026-05-01 12:42:43', '2026-05-01 12:42:43', 1),
	(3, 'beta_launch_date', '2026-06-01', 'Scheduled date for beta launch', '2026-05-01 12:42:43', '2026-05-14 07:05:13', 1);

-- Dumping structure for table formforge_db.subscription_plans
CREATE TABLE IF NOT EXISTS `subscription_plans` (
  `id` char(36) NOT NULL,
  `name` varchar(120) NOT NULL,
  `description` text,
  `status` enum('draft','active','inactive','archived') NOT NULL DEFAULT 'draft',
  `free_trials` int NOT NULL DEFAULT '0' COMMENT 'Free trial length in days; 0 = no trial',
  `price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `currency` char(3) NOT NULL DEFAULT 'USD',
  `features` json DEFAULT NULL COMMENT 'Plan feature list for admin/app display',
  `play_store_sub_id` varchar(255) DEFAULT NULL COMMENT 'Google Play subscription product ID',
  `app_store_sub_id` varchar(255) DEFAULT NULL COMMENT 'Apple App Store subscription product ID',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_subscription_plans_play_store_sub_id` (`play_store_sub_id`),
  UNIQUE KEY `uq_subscription_plans_app_store_sub_id` (`app_store_sub_id`),
  KEY `idx_subscription_plans_status` (`status`),
  KEY `idx_subscription_plans_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.subscription_plans: ~3 rows (approximately)
INSERT INTO `subscription_plans` (`id`, `name`, `description`, `status`, `free_trials`, `price`, `currency`, `features`, `play_store_sub_id`, `app_store_sub_id`, `createdAt`, `updatedAt`) VALUES
	('8c0ef54d-8957-4e26-81cf-7d3bf77406c2', 'Pro weekly', 'weekly plan', 'active', 0, 10.00, 'USD', '["train mode"]', NULL, 'com.codesteem.repvio.pro.weekly', '2026-05-15 19:11:17', '2026-05-15 19:11:17'),
	('a1906a43-4528-401a-99f7-3b4f6652a4bb', 'Premium', 'testing', 'active', 0, 40.00, 'USD', '["train mode"]', 'premium', 'com.codesteem.repvio.premium', '2026-05-15 14:29:39', '2026-05-15 14:29:39'),
	('d9ae6120-af75-4790-8833-4f781d3a3ad7', 'Pro Weekly', 'weekly', 'active', 0, 10.00, 'USD', '["game mod"]', 'pro_weekly', NULL, '2026-05-15 11:40:01', '2026-05-15 11:40:01');

-- Dumping structure for table formforge_db.training_modes
CREATE TABLE IF NOT EXISTS `training_modes` (
  `id` char(36) NOT NULL,
  `slug` varchar(50) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  UNIQUE KEY `slug_2` (`slug`),
  KEY `idx_training_modes_active` (`is_active`),
  KEY `idx_training_modes_sort` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.training_modes: ~3 rows (approximately)
INSERT INTO `training_modes` (`id`, `slug`, `display_name`, `description`, `sort_order`, `is_active`, `createdAt`, `updatedAt`) VALUES
	('a0000001-0001-4001-8001-000000000001', 'training', 'Training', 'Standard strength and conditioning style work.', 0, 1, '2026-05-14 07:57:45', '2026-05-14 13:02:17'),
	('a0000001-0001-4001-8001-000000000002', 'rehab', 'Rehab', 'Recovery-oriented, controlled load and range.', 1, 1, '2026-05-14 07:57:45', '2026-05-14 13:02:17'),
	('a0000001-0001-4001-8001-000000000003', 'gaming', 'Gaming', 'Playful, score and streak friendly sessions.', 2, 1, '2026-05-14 07:57:45', '2026-05-14 13:02:17');

-- Dumping structure for table formforge_db.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` char(36) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `referral_code` varchar(255) DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT '0',
  `is_profile_completed` tinyint(1) DEFAULT '0',
  `role` enum('user','admin') DEFAULT 'user',
  `status` enum('active','inactive','suspended') DEFAULT 'active',
  `resetPasswordToken` varchar(255) DEFAULT NULL,
  `resetPasswordExpire` datetime DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `email_2` (`email`),
  UNIQUE KEY `email_3` (`email`),
  UNIQUE KEY `email_4` (`email`),
  UNIQUE KEY `email_5` (`email`),
  UNIQUE KEY `email_6` (`email`),
  UNIQUE KEY `email_7` (`email`),
  UNIQUE KEY `email_8` (`email`),
  UNIQUE KEY `email_9` (`email`),
  UNIQUE KEY `email_10` (`email`),
  UNIQUE KEY `email_11` (`email`),
  UNIQUE KEY `email_12` (`email`),
  UNIQUE KEY `email_13` (`email`),
  UNIQUE KEY `email_14` (`email`),
  UNIQUE KEY `email_15` (`email`),
  UNIQUE KEY `email_16` (`email`),
  UNIQUE KEY `email_17` (`email`),
  UNIQUE KEY `email_18` (`email`),
  UNIQUE KEY `email_19` (`email`),
  UNIQUE KEY `email_20` (`email`),
  UNIQUE KEY `email_21` (`email`),
  UNIQUE KEY `email_22` (`email`),
  UNIQUE KEY `email_23` (`email`),
  UNIQUE KEY `email_24` (`email`),
  UNIQUE KEY `email_25` (`email`),
  UNIQUE KEY `email_26` (`email`),
  UNIQUE KEY `email_27` (`email`),
  UNIQUE KEY `referral_code` (`referral_code`),
  UNIQUE KEY `referral_code_2` (`referral_code`),
  UNIQUE KEY `referral_code_3` (`referral_code`),
  UNIQUE KEY `referral_code_4` (`referral_code`),
  UNIQUE KEY `referral_code_5` (`referral_code`),
  UNIQUE KEY `referral_code_6` (`referral_code`),
  UNIQUE KEY `referral_code_7` (`referral_code`),
  UNIQUE KEY `referral_code_8` (`referral_code`),
  UNIQUE KEY `referral_code_9` (`referral_code`),
  UNIQUE KEY `referral_code_10` (`referral_code`),
  UNIQUE KEY `referral_code_11` (`referral_code`),
  UNIQUE KEY `referral_code_12` (`referral_code`),
  UNIQUE KEY `referral_code_13` (`referral_code`),
  UNIQUE KEY `referral_code_14` (`referral_code`),
  UNIQUE KEY `referral_code_15` (`referral_code`),
  UNIQUE KEY `referral_code_16` (`referral_code`),
  UNIQUE KEY `referral_code_17` (`referral_code`),
  UNIQUE KEY `referral_code_18` (`referral_code`),
  UNIQUE KEY `referral_code_19` (`referral_code`),
  UNIQUE KEY `referral_code_20` (`referral_code`),
  UNIQUE KEY `referral_code_21` (`referral_code`),
  UNIQUE KEY `referral_code_22` (`referral_code`),
  UNIQUE KEY `referral_code_23` (`referral_code`),
  UNIQUE KEY `referral_code_24` (`referral_code`),
  UNIQUE KEY `referral_code_25` (`referral_code`),
  UNIQUE KEY `referral_code_26` (`referral_code`),
  UNIQUE KEY `referral_code_27` (`referral_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.users: ~11 rows (approximately)
INSERT INTO `users` (`id`, `email`, `password`, `referral_code`, `is_verified`, `is_profile_completed`, `role`, `status`, `resetPasswordToken`, `resetPasswordExpire`, `createdAt`, `updatedAt`) VALUES
	('0f7bc9e7-df4b-4353-b728-28901567e14d', 'admin@admin.com', '$2b$10$3T1s7S7AbSUkkDZC/FGFC.9bpx7k43zRWes7IzC2h3eqOpyFaSqOW', 'FE8BF8', 0, 0, 'admin', 'active', NULL, NULL, '2026-05-05 15:42:57', '2026-05-05 15:42:57'),
	('13cfa403-8c93-48ed-aaaa-3b18771cb4dd', 'hamdann@gmail.com', '$2b$10$g9OaZ6OKvG4n7rfUNaO4we0fnwIIS8eLsVgnvUYxOCLkFPTU98Kf6', 'DDE105', 0, 1, 'user', 'active', NULL, NULL, '2026-06-19 13:19:07', '2026-06-19 13:19:16'),
	('189df97a-adaa-445a-bd74-065c890092dc', 'mohsancode1@gmail.com', '$2b$10$dUf3TEGAlN9UdhGFOC95ueOyx7FVRmkvaqTiRQCn/00s.tnexPVxi', '4A2EE2', 0, 1, 'user', 'active', NULL, NULL, '2026-06-19 12:47:01', '2026-06-19 12:47:12'),
	('2769c2cd-73c0-42ce-aabb-b53814a628fe', 'admin@repvio.ai', '$2b$10$h32tfMmJl36s2bs3BBq9l.o.twO5EZTOWM3gx.j.sGCNXvjNs2qWq', '683B7E', 0, 0, 'admin', 'active', NULL, NULL, '2026-06-17 12:21:04', '2026-06-19 15:41:23'),
	('2f09d0b2-4ac5-4461-8114-e89dfd155bc8', 'musmangul99@gmail.com', '$2b$10$ed1A5gz8Y1rQ0hmFdGAMqeTWFi/a4Z7BsjBkKa7RWAVtKpnIKFomq', '8248C6', 0, 1, 'user', 'active', NULL, NULL, '2026-06-19 14:42:20', '2026-06-19 14:42:36'),
	('59d62336-9f73-48fe-bb37-4ab893f5a840', 'hamdan@gmail.com', '$2b$10$Fwp6mG8nRBHsNGau7SFMfe340z9foeWI/XlnjtDPeTEuzhVeTRFVm', '3C8796', 0, 0, 'user', 'active', NULL, NULL, '2026-06-19 10:07:34', '2026-06-19 10:07:34'),
	('a56b6a5f-7d73-41d3-8d82-018600a206a9', 'hamdanmansoor5490@gmail.com', '$2b$10$Ntt/Eb7prTLhYFalC6zuZuHeCvHt1bjjG1RcBIvo0AYi1HbpgyrOe', 'EF6F0D', 0, 1, 'user', 'active', '9cf8c80a920baa3ada00989a18bd3e92809d4401f6131c4b25d1b344333ece52', '2026-06-22 17:13:18', '2026-06-19 16:29:35', '2026-06-22 16:43:18'),
	('a5709dd8-73e6-4054-9140-d66de8883d4c', 'blingset42@gmail.com', '$2b$10$p.HQK.aKFPC9rMwUa/6y3OXVmgX9KDlcV9Lj8Bqs1A/ivEa7awm2C', 'EF574E', 0, 1, 'user', 'active', NULL, NULL, '2026-06-22 05:57:53', '2026-06-22 05:57:57'),
	('b586d41f-bd1d-4cd0-b11b-5bad3296f31b', 'g@gmail.com', '$2b$10$4IdZwwN4b64Q2NQ9RiKN/OVGE42heYed7Q21GYVt9/W9UKa8ikZwu', '2E7513', 0, 1, 'user', 'active', NULL, NULL, '2026-06-19 13:05:39', '2026-06-19 13:05:44'),
	('d977d0f2-32ad-49bc-815e-1e8fdd8bd528', 'a@gmail.com', '$2b$10$dHwkRGMms9jeKLD51gvAg.QpIrnLHFz.Q8BQ8m1XIwf6G5p41Vru6', 'BC724A', 0, 1, 'user', 'active', NULL, NULL, '2026-06-19 13:02:31', '2026-06-19 13:02:40'),
	('e83c8333-0c43-48dc-b3ca-1d5a046ad49c', 'mohsancode@gmail.com', '$2b$10$CTvwIsY6n.DqLQl7RAcy8.GYHIAeObn.iBhJ2Jb0Aae8UHojYVeo.', '766B89', 1, 1, 'user', 'active', NULL, NULL, '2026-05-12 10:39:09', '2026-05-15 19:09:28');

-- Dumping structure for table formforge_db.user_badges
CREATE TABLE IF NOT EXISTS `user_badges` (
  `id` char(36) NOT NULL,
  `user_id` char(36) NOT NULL,
  `badge_id` char(36) NOT NULL,
  `earned_at` datetime NOT NULL,
  `context` json DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_badge` (`user_id`,`badge_id`),
  KEY `idx_user_badges_user` (`user_id`),
  KEY `idx_user_badges_badge` (`badge_id`),
  CONSTRAINT `user_badges_ibfk_37` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_badges_ibfk_38` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.user_badges: ~0 rows (approximately)

-- Dumping structure for table formforge_db.user_challenges
CREATE TABLE IF NOT EXISTS `user_challenges` (
  `id` char(36) NOT NULL,
  `user_id` char(36) NOT NULL,
  `challenge_id` char(36) NOT NULL,
  `status` enum('joined','in_progress','completed','failed','expired') NOT NULL DEFAULT 'joined',
  `total_points_earned` int NOT NULL DEFAULT '0',
  `joined_at` datetime NOT NULL,
  `completed_at` datetime DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_challenge` (`user_id`,`challenge_id`),
  KEY `idx_user_challenges_user` (`user_id`),
  KEY `idx_user_challenges_challenge` (`challenge_id`),
  CONSTRAINT `user_challenges_ibfk_37` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_challenges_ibfk_38` FOREIGN KEY (`challenge_id`) REFERENCES `challenges` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.user_challenges: ~1 rows (approximately)
INSERT INTO `user_challenges` (`id`, `user_id`, `challenge_id`, `status`, `total_points_earned`, `joined_at`, `completed_at`, `createdAt`, `updatedAt`) VALUES
	('5437d071-46cd-4482-9665-98cd0097adf7', '59d62336-9f73-48fe-bb37-4ab893f5a840', 'c286a95c-b236-442f-b7a2-3682f4d17b29', 'in_progress', 0, '2026-06-23 11:02:39', NULL, '2026-06-23 11:02:39', '2026-06-23 11:02:39'),
	('c86099cf-8abc-482e-aeeb-cb5a23b98f9d', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', 'c286a95c-b236-442f-b7a2-3682f4d17b29', 'in_progress', 0, '2026-06-22 07:05:24', NULL, '2026-06-22 07:05:24', '2026-06-22 07:05:24');

-- Dumping structure for table formforge_db.user_challenge_exercise_progress
CREATE TABLE IF NOT EXISTS `user_challenge_exercise_progress` (
  `id` char(36) NOT NULL,
  `user_challenge_id` char(36) NOT NULL,
  `challenge_stage_exercise_id` char(36) NOT NULL,
  `sets_completed` int NOT NULL DEFAULT '0',
  `reps_logged` int NOT NULL DEFAULT '0',
  `form_score` int DEFAULT NULL COMMENT 'Latest form score 0-100',
  `mistakes` json DEFAULT NULL COMMENT 'Form mistakes from AI session',
  `status` enum('not_started','in_progress','completed') NOT NULL DEFAULT 'not_started',
  `points_awarded` int NOT NULL DEFAULT '0',
  `completed_at` datetime DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ucep_mapping` (`user_challenge_id`,`challenge_stage_exercise_id`),
  KEY `idx_ucep_user_challenge` (`user_challenge_id`),
  KEY `idx_ucep_cse` (`challenge_stage_exercise_id`),
  CONSTRAINT `user_challenge_exercise_progress_ibfk_37` FOREIGN KEY (`user_challenge_id`) REFERENCES `user_challenges` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_challenge_exercise_progress_ibfk_38` FOREIGN KEY (`challenge_stage_exercise_id`) REFERENCES `challenge_stage_exercises` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.user_challenge_exercise_progress: ~6 rows (approximately)
INSERT INTO `user_challenge_exercise_progress` (`id`, `user_challenge_id`, `challenge_stage_exercise_id`, `sets_completed`, `reps_logged`, `form_score`, `mistakes`, `status`, `points_awarded`, `completed_at`, `createdAt`, `updatedAt`) VALUES
	('2d322431-94f4-4a14-99fa-3a5a90952cef', '5437d071-46cd-4482-9665-98cd0097adf7', '53889100-9595-4568-9de4-28a406594413', 0, 0, NULL, NULL, 'not_started', 0, NULL, '2026-06-23 11:02:39', '2026-06-23 11:02:39'),
	('3a4e55ef-5512-4f8e-abff-3f44dc90f58d', 'c86099cf-8abc-482e-aeeb-cb5a23b98f9d', '53889100-9595-4568-9de4-28a406594413', 0, 0, NULL, NULL, 'not_started', 0, NULL, '2026-06-22 07:05:24', '2026-06-22 07:05:24'),
	('4f1ebcc6-bd11-418a-8638-ef150e70dab8', 'c86099cf-8abc-482e-aeeb-cb5a23b98f9d', 'ca82b18c-de17-403e-9f99-16a7d92bc346', 0, 0, NULL, NULL, 'not_started', 0, NULL, '2026-06-22 07:05:24', '2026-06-22 07:05:24'),
	('9419466f-5622-478d-8860-b2d28ba13243', 'c86099cf-8abc-482e-aeeb-cb5a23b98f9d', 'f4506f77-7ea9-4f35-95fd-188dc75d245c', 0, 0, NULL, NULL, 'not_started', 0, NULL, '2026-06-22 07:05:24', '2026-06-22 07:05:24'),
	('c688b47b-63fa-4aee-b9b3-095cbeec727a', '5437d071-46cd-4482-9665-98cd0097adf7', 'ca82b18c-de17-403e-9f99-16a7d92bc346', 0, 0, NULL, NULL, 'not_started', 0, NULL, '2026-06-23 11:02:39', '2026-06-23 11:02:39'),
	('d1d20d06-b20d-40e9-9066-5fe1bd4b8095', '5437d071-46cd-4482-9665-98cd0097adf7', 'f4506f77-7ea9-4f35-95fd-188dc75d245c', 0, 0, NULL, NULL, 'not_started', 0, NULL, '2026-06-23 11:02:39', '2026-06-23 11:02:39');

-- Dumping structure for table formforge_db.user_challenge_stage_progress
CREATE TABLE IF NOT EXISTS `user_challenge_stage_progress` (
  `id` char(36) NOT NULL,
  `user_challenge_id` char(36) NOT NULL,
  `challenge_stage_id` char(36) NOT NULL,
  `status` enum('locked','active','completed') NOT NULL DEFAULT 'locked',
  `completed_at` datetime DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ucsp_stage` (`user_challenge_id`,`challenge_stage_id`),
  KEY `idx_ucsp_user_challenge` (`user_challenge_id`),
  KEY `idx_ucsp_stage` (`challenge_stage_id`),
  CONSTRAINT `user_challenge_stage_progress_ibfk_37` FOREIGN KEY (`user_challenge_id`) REFERENCES `user_challenges` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_challenge_stage_progress_ibfk_38` FOREIGN KEY (`challenge_stage_id`) REFERENCES `challenge_stages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.user_challenge_stage_progress: ~1 rows (approximately)
INSERT INTO `user_challenge_stage_progress` (`id`, `user_challenge_id`, `challenge_stage_id`, `status`, `completed_at`, `createdAt`, `updatedAt`) VALUES
	('3f55adbe-36ac-4294-8bb7-d703b7ef7610', '5437d071-46cd-4482-9665-98cd0097adf7', '68acec2e-903d-4c26-a0e2-61b6c9b397b6', 'active', NULL, '2026-06-23 11:02:39', '2026-06-23 11:02:39'),
	('ed1daa7d-7427-4d92-92b3-f8ecba8dd062', 'c86099cf-8abc-482e-aeeb-cb5a23b98f9d', '68acec2e-903d-4c26-a0e2-61b6c9b397b6', 'active', NULL, '2026-06-22 07:05:24', '2026-06-22 07:05:24');

-- Dumping structure for table formforge_db.user_subscriptions
CREATE TABLE IF NOT EXISTS `user_subscriptions` (
  `id` char(36) NOT NULL,
  `user_id` char(36) NOT NULL,
  `subscription_plan_id` char(36) NOT NULL,
  `status` enum('trialing','active','expired','cancelled','paused') NOT NULL DEFAULT 'active',
  `platform` enum('google_play','app_store','manual','admin') NOT NULL DEFAULT 'manual',
  `store_purchase_token` varchar(512) DEFAULT NULL,
  `started_at` datetime NOT NULL,
  `expires_at` datetime DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `refunded_at` datetime DEFAULT NULL,
  `deactivated_at` datetime DEFAULT NULL,
  `auto_renew` tinyint(1) NOT NULL DEFAULT '1',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `subscription_plan_id` (`subscription_plan_id`),
  CONSTRAINT `user_subscriptions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_subscriptions_ibfk_2` FOREIGN KEY (`subscription_plan_id`) REFERENCES `subscription_plans` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.user_subscriptions: ~1 rows (approximately)
INSERT INTO `user_subscriptions` (`id`, `user_id`, `subscription_plan_id`, `status`, `platform`, `store_purchase_token`, `started_at`, `expires_at`, `cancelled_at`, `refunded_at`, `deactivated_at`, `auto_renew`, `createdAt`, `updatedAt`) VALUES
	('0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7', 'e83c8333-0c43-48dc-b3ca-1d5a046ad49c', 'd9ae6120-af75-4790-8833-4f781d3a3ad7', 'expired', 'google_play', 'jlpledhicicahlenknaffbka.AO-J1Owj1GYIa_htBtOWuu-qMfS-cbiXYreDICMsxFU7wfKhD274Agg0_OyMQdkJPUIiuPlkHFb3k1oOnAcymMEDMESpZZFXg2-nvUnD7Vf06SI_hfVy_apYKWld83yUjr7sSB9ZMtFM6fMbGeVCSCEpC-h1UzSy5A', '2026-05-15 13:14:01', '2026-05-22 13:13:00', '2026-05-15 15:08:58', NULL, NULL, 0, '2026-05-15 13:14:01', '2026-06-17 13:05:18');

-- Dumping structure for table formforge_db.user_subscription_logs
CREATE TABLE IF NOT EXISTS `user_subscription_logs` (
  `id` char(36) NOT NULL,
  `user_subscription_id` char(36) DEFAULT NULL,
  `user_id` char(36) NOT NULL,
  `action` enum('created','expiry_updated','deactivated','cancelled','refunded','deleted','reactivated','store_synced') NOT NULL,
  `performed_by` char(36) DEFAULT NULL,
  `note` text,
  `metadata` json DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_sub_logs_subscription` (`user_subscription_id`),
  CONSTRAINT `fk_sub_logs_subscription` FOREIGN KEY (`user_subscription_id`) REFERENCES `user_subscriptions` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.user_subscription_logs: ~0 rows (approximately)
INSERT INTO `user_subscription_logs` (`id`, `user_subscription_id`, `user_id`, `action`, `performed_by`, `note`, `metadata`, `createdAt`) VALUES
	('b6ea88cd-3330-4878-a7bd-18ed1170aa84', '0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7', 'e83c8333-0c43-48dc-b3ca-1d5a046ad49c', 'created', '0f7bc9e7-df4b-4353-b728-28901567e14d', NULL, '{"status": "trialing", "platform": "admin", "expires_at": "2026-05-22T13:13:00.000Z", "subscription_plan_id": "d9ae6120-af75-4790-8833-4f781d3a3ad7"}', '2026-05-15 13:14:01'),
	('c501b6dd-3c15-4e84-b031-5cd2b4d28ec7', '0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7', 'e83c8333-0c43-48dc-b3ca-1d5a046ad49c', 'cancelled', '0f7bc9e7-df4b-4353-b728-28901567e14d', NULL, NULL, '2026-05-15 15:08:58');

-- Dumping structure for table formforge_db.user_subscription_store_syncs
CREATE TABLE IF NOT EXISTS `user_subscription_store_syncs` (
  `id` char(36) NOT NULL,
  `user_subscription_id` char(36) NOT NULL,
  `user_id` char(36) NOT NULL,
  `platform` enum('google_play','app_store') NOT NULL,
  `sync_type` enum('pull','cancel','refund') NOT NULL DEFAULT 'pull',
  `status` enum('success','no_change','failed','manual_required') NOT NULL,
  `message` varchar(500) DEFAULT NULL,
  `store_status` varchar(64) DEFAULT NULL,
  `store_expires_at` datetime DEFAULT NULL,
  `store_auto_renew` tinyint(1) DEFAULT NULL,
  `store_product_id` varchar(255) DEFAULT NULL,
  `user_updated` tinyint(1) NOT NULL DEFAULT '0',
  `previous_data` json DEFAULT NULL,
  `store_snapshot` json DEFAULT NULL,
  `applied_updates` json DEFAULT NULL,
  `error_detail` text,
  `performed_by` char(36) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.user_subscription_store_syncs: ~9 rows (approximately)
INSERT INTO `user_subscription_store_syncs` (`id`, `user_subscription_id`, `user_id`, `platform`, `sync_type`, `status`, `message`, `store_status`, `store_expires_at`, `store_auto_renew`, `store_product_id`, `user_updated`, `previous_data`, `store_snapshot`, `applied_updates`, `error_detail`, `performed_by`, `createdAt`) VALUES
	('172901e9-7b80-44dd-9dbb-836602e98c2d', '0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7', 'e83c8333-0c43-48dc-b3ca-1d5a046ad49c', 'google_play', 'pull', 'failed', 'Store sync failed.', NULL, NULL, NULL, NULL, 0, '{"status": "active", "auto_renew": false, "expires_at": "2026-05-22T13:13:00.000Z", "cancelled_at": "2026-05-15T15:08:58.000Z"}', '{"_adminConsoleLog": ["[00:05:38] ▶ Store sync started", "[00:05:38] User subscription: 0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7", "[00:05:38] DB now → status: active, expires: 2026-05-22T13:13:00.000Z, auto_renew: false", "[00:05:38] Platform: Google Play", "[00:05:38] Calling Play API (product: pro_weekly)…", "[00:05:39] ✗ Sync failed: invalid_grant: Invalid JWT Signature."]}', NULL, 'invalid_grant: Invalid JWT Signature.', NULL, '2026-05-15 19:05:39'),
	('2cea7fbc-91dd-4a9c-89b5-883e6f33ca92', '0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7', 'e83c8333-0c43-48dc-b3ca-1d5a046ad49c', 'google_play', 'pull', 'failed', 'Store sync failed.', NULL, NULL, NULL, NULL, 0, '{"status": "active", "auto_renew": false, "expires_at": "2026-05-22T13:13:00.000Z", "cancelled_at": "2026-05-15T15:08:58.000Z"}', '{"_adminConsoleLog": ["[22:35:15] ▶ Store sync started", "[22:35:15] User subscription: 0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7", "[22:35:15] DB now → status: active, expires: 2026-05-22T13:13:00.000Z, auto_renew: false", "[22:35:15] Platform: Google Play", "[22:35:15] Calling Play API (product: pro_weekly)…", "[22:35:17] ✗ Sync failed: The subscription purchase is no longer available for query because it has been expired for too long."]}', NULL, 'The subscription purchase is no longer available for query because it has been expired for too long.', '0f7bc9e7-df4b-4353-b728-28901567e14d', '2026-05-15 17:35:17'),
	('4749e686-a064-476f-a60e-081c7da04789', '0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7', 'e83c8333-0c43-48dc-b3ca-1d5a046ad49c', 'google_play', 'pull', 'failed', 'Store sync failed.', NULL, NULL, NULL, NULL, 0, '{"status": "expired", "auto_renew": false, "expires_at": "2026-05-22T13:13:00.000Z", "cancelled_at": "2026-05-15T15:08:58.000Z"}', '{"_adminConsoleLog": ["[21:21:18] ▶ Store sync started", "[21:21:18] User subscription: 0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7", "[21:21:18] DB now → status: expired, expires: 2026-05-22T13:13:00.000Z, auto_renew: false", "[21:21:18] Platform: Google Play", "[21:21:18] Calling Play API (product: pro_weekly)…", "[21:21:18] ✗ Sync failed: invalid_grant: Invalid JWT Signature."]}', NULL, 'invalid_grant: Invalid JWT Signature.', NULL, '2026-06-19 16:21:18'),
	('6ecf6139-581d-4db9-be84-f2065c75f97e', '0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7', 'e83c8333-0c43-48dc-b3ca-1d5a046ad49c', 'google_play', 'pull', 'failed', 'Store sync failed.', NULL, NULL, NULL, NULL, 0, '{"status": "active", "auto_renew": false, "expires_at": "2026-05-22T13:13:00.000Z", "cancelled_at": "2026-05-15T15:08:58.000Z"}', '{"_adminConsoleLog": ["[18:05:17] ▶ Store sync started", "[18:05:17] User subscription: 0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7", "[18:05:17] DB now → status: active, expires: 2026-05-22T13:13:00.000Z, auto_renew: false", "[18:05:17] Platform: Google Play", "[18:05:17] Calling Play API (product: pro_weekly)…", "[18:05:18] ✗ Sync failed: invalid_grant: Invalid JWT Signature."]}', NULL, 'invalid_grant: Invalid JWT Signature.', NULL, '2026-06-17 13:05:18'),
	('6f608d26-5a8a-402d-a351-b5c2611d8b45', '0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7', 'e83c8333-0c43-48dc-b3ca-1d5a046ad49c', 'google_play', 'pull', 'failed', 'Store sync failed.', NULL, NULL, NULL, NULL, 0, '{"status": "active", "auto_renew": false, "expires_at": "2026-05-22T13:13:00.000Z", "cancelled_at": "2026-05-15T15:08:58.000Z"}', '{"_adminConsoleLog": ["[00:11:37] ▶ Store sync started", "[00:11:37] User subscription: 0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7", "[00:11:37] DB now → status: active, expires: 2026-05-22T13:13:00.000Z, auto_renew: false", "[00:11:37] Platform: Google Play", "[00:11:37] Calling Play API (product: pro_weekly)…", "[00:11:38] ✗ Sync failed: invalid_grant: Invalid JWT Signature."]}', NULL, 'invalid_grant: Invalid JWT Signature.', NULL, '2026-05-15 19:11:38'),
	('82215ccf-3f9c-4264-bef8-62ece9ba9bc5', '0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7', 'e83c8333-0c43-48dc-b3ca-1d5a046ad49c', 'google_play', 'pull', 'failed', 'Store sync failed.', NULL, NULL, NULL, NULL, 0, '{"status": "expired", "auto_renew": false, "expires_at": "2026-05-22T13:13:00.000Z", "cancelled_at": "2026-05-15T15:08:58.000Z"}', '{"_adminConsoleLog": ["[18:39:30] ▶ Store sync started", "[18:39:30] User subscription: 0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7", "[18:39:30] DB now → status: expired, expires: 2026-05-22T13:13:00.000Z, auto_renew: false", "[18:39:30] Platform: Google Play", "[18:39:30] Calling Play API (product: pro_weekly)…", "[18:39:30] ✗ Sync failed: invalid_grant: Invalid JWT Signature."]}', NULL, 'invalid_grant: Invalid JWT Signature.', NULL, '2026-06-19 13:39:30'),
	('86f6e806-1c9d-4fc8-ae21-49b7df887fca', '0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7', 'e83c8333-0c43-48dc-b3ca-1d5a046ad49c', 'google_play', 'pull', 'failed', 'Store sync failed.', NULL, NULL, NULL, NULL, 0, '{"status": "active", "auto_renew": false, "expires_at": "2026-05-22T13:13:00.000Z", "cancelled_at": "2026-05-15T15:08:58.000Z"}', '{"_adminConsoleLog": ["[22:38:37] ▶ Store sync started", "[22:38:37] User subscription: 0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7", "[22:38:37] DB now → status: active, expires: 2026-05-22T13:13:00.000Z, auto_renew: false", "[22:38:37] Platform: Google Play", "[22:38:37] Calling Play API (product: pro_weekly)…", "[22:38:39] ✗ Sync failed: The subscription purchase is no longer available for query because it has been expired for too long."]}', NULL, 'The subscription purchase is no longer available for query because it has been expired for too long.', NULL, '2026-05-15 17:38:39'),
	('b35f4a08-bfd0-49bd-8021-c7864a163c66', '0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7', 'e83c8333-0c43-48dc-b3ca-1d5a046ad49c', 'google_play', 'pull', 'failed', 'Store sync failed.', NULL, NULL, NULL, NULL, 0, '{"status": "active", "auto_renew": false, "expires_at": "2026-05-22T13:13:00.000Z", "cancelled_at": "2026-05-15T15:08:58.000Z"}', '{"_adminConsoleLog": ["[22:45:50] ▶ Store sync started", "[22:45:50] User subscription: 0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7", "[22:45:50] DB now → status: active, expires: 2026-05-22T13:13:00.000Z, auto_renew: false", "[22:45:50] Platform: Google Play", "[22:45:50] Calling Play API (product: pro_weekly)…", "[22:45:52] ✗ Sync failed: The subscription purchase is no longer available for query because it has been expired for too long."]}', NULL, 'The subscription purchase is no longer available for query because it has been expired for too long.', NULL, '2026-05-15 17:45:52'),
	('b51a08c1-6b4f-4844-b482-0ab3116b18b4', '0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7', 'e83c8333-0c43-48dc-b3ca-1d5a046ad49c', 'google_play', 'pull', 'failed', 'Store sync failed.', NULL, NULL, NULL, NULL, 0, '{"status": "expired", "auto_renew": false, "expires_at": "2026-05-22T13:13:00.000Z", "cancelled_at": "2026-05-15T15:08:58.000Z"}', '{"_adminConsoleLog": ["[18:52:32] ▶ Store sync started", "[18:52:32] User subscription: 0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7", "[18:52:32] DB now → status: expired, expires: 2026-05-22T13:13:00.000Z, auto_renew: false", "[18:52:32] Platform: Google Play", "[18:52:32] Calling Play API (product: pro_weekly)…", "[18:52:33] ✗ Sync failed: invalid_grant: Invalid JWT Signature."]}', NULL, 'invalid_grant: Invalid JWT Signature.', NULL, '2026-06-17 13:52:33'),
	('d3624349-f7f1-4c66-9768-043e2cfdcf5b', '0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7', 'e83c8333-0c43-48dc-b3ca-1d5a046ad49c', 'google_play', 'pull', 'failed', 'Store sync failed.', NULL, NULL, NULL, NULL, 0, '{"status": "active", "auto_renew": false, "expires_at": "2026-05-22T13:13:00.000Z", "cancelled_at": "2026-05-15T15:08:58.000Z"}', '{"_adminConsoleLog": ["[22:35:19] ▶ Store sync started", "[22:35:19] User subscription: 0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7", "[22:35:19] DB now → status: active, expires: 2026-05-22T13:13:00.000Z, auto_renew: false", "[22:35:19] Platform: Google Play", "[22:35:19] Calling Play API (product: pro_weekly)…", "[22:35:20] ✗ Sync failed: The subscription purchase is no longer available for query because it has been expired for too long."]}', NULL, 'The subscription purchase is no longer available for query because it has been expired for too long.', '0f7bc9e7-df4b-4353-b728-28901567e14d', '2026-05-15 17:35:20'),
	('f5e67949-c6b2-4ca9-9f8f-990757b8957b', '0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7', 'e83c8333-0c43-48dc-b3ca-1d5a046ad49c', 'google_play', 'pull', 'failed', 'Store sync failed.', NULL, NULL, NULL, NULL, 0, '{"status": "active", "auto_renew": false, "expires_at": "2026-05-22T13:13:00.000Z", "cancelled_at": "2026-05-15T15:08:58.000Z"}', '{"_adminConsoleLog": ["[00:11:50] ▶ Store sync started", "[00:11:50] User subscription: 0fb5ca2c-5bb0-4127-a4fa-7ee07448e8a7", "[00:11:50] DB now → status: active, expires: 2026-05-22T13:13:00.000Z, auto_renew: false", "[00:11:50] Platform: Google Play", "[00:11:50] Calling Play API (product: pro_weekly)…", "[00:11:50] ✗ Sync failed: invalid_grant: Invalid JWT Signature."]}', NULL, 'invalid_grant: Invalid JWT Signature.', NULL, '2026-05-15 19:11:50');

-- Dumping structure for table formforge_db.waitlistusers
CREATE TABLE IF NOT EXISTS `waitlistusers` (
  `id` char(36) NOT NULL,
  `email` varchar(255) NOT NULL,
  `device` varchar(255) DEFAULT NULL,
  `interest` varchar(255) DEFAULT NULL,
  `referralCode` varchar(255) DEFAULT NULL,
  `referredBy` varchar(255) DEFAULT NULL,
  `referralCount` int DEFAULT '0',
  `waitlistPosition` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `email_2` (`email`),
  UNIQUE KEY `email_3` (`email`),
  UNIQUE KEY `email_4` (`email`),
  UNIQUE KEY `email_5` (`email`),
  UNIQUE KEY `email_6` (`email`),
  UNIQUE KEY `email_7` (`email`),
  UNIQUE KEY `email_8` (`email`),
  UNIQUE KEY `email_9` (`email`),
  UNIQUE KEY `email_10` (`email`),
  UNIQUE KEY `email_11` (`email`),
  UNIQUE KEY `email_12` (`email`),
  UNIQUE KEY `email_13` (`email`),
  UNIQUE KEY `email_14` (`email`),
  UNIQUE KEY `email_15` (`email`),
  UNIQUE KEY `email_16` (`email`),
  UNIQUE KEY `email_17` (`email`),
  UNIQUE KEY `email_18` (`email`),
  UNIQUE KEY `email_19` (`email`),
  UNIQUE KEY `email_20` (`email`),
  UNIQUE KEY `email_21` (`email`),
  UNIQUE KEY `email_22` (`email`),
  UNIQUE KEY `email_23` (`email`),
  UNIQUE KEY `email_24` (`email`),
  UNIQUE KEY `email_25` (`email`),
  UNIQUE KEY `email_26` (`email`),
  UNIQUE KEY `email_27` (`email`),
  UNIQUE KEY `email_28` (`email`),
  UNIQUE KEY `email_29` (`email`),
  UNIQUE KEY `email_30` (`email`),
  UNIQUE KEY `email_31` (`email`),
  UNIQUE KEY `email_32` (`email`),
  UNIQUE KEY `referralCode` (`referralCode`),
  UNIQUE KEY `referralCode_2` (`referralCode`),
  UNIQUE KEY `referralCode_3` (`referralCode`),
  UNIQUE KEY `referralCode_4` (`referralCode`),
  UNIQUE KEY `referralCode_5` (`referralCode`),
  UNIQUE KEY `referralCode_6` (`referralCode`),
  UNIQUE KEY `referralCode_7` (`referralCode`),
  UNIQUE KEY `referralCode_8` (`referralCode`),
  UNIQUE KEY `referralCode_9` (`referralCode`),
  UNIQUE KEY `referralCode_10` (`referralCode`),
  UNIQUE KEY `referralCode_11` (`referralCode`),
  UNIQUE KEY `referralCode_12` (`referralCode`),
  UNIQUE KEY `referralCode_13` (`referralCode`),
  UNIQUE KEY `referralCode_14` (`referralCode`),
  UNIQUE KEY `referralCode_15` (`referralCode`),
  UNIQUE KEY `referralCode_16` (`referralCode`),
  UNIQUE KEY `referralCode_17` (`referralCode`),
  UNIQUE KEY `referralCode_18` (`referralCode`),
  UNIQUE KEY `referralCode_19` (`referralCode`),
  UNIQUE KEY `referralCode_20` (`referralCode`),
  UNIQUE KEY `referralCode_21` (`referralCode`),
  UNIQUE KEY `referralCode_22` (`referralCode`),
  UNIQUE KEY `referralCode_23` (`referralCode`),
  UNIQUE KEY `referralCode_24` (`referralCode`),
  UNIQUE KEY `referralCode_25` (`referralCode`),
  UNIQUE KEY `referralCode_26` (`referralCode`),
  UNIQUE KEY `referralCode_27` (`referralCode`),
  UNIQUE KEY `referralCode_28` (`referralCode`),
  UNIQUE KEY `referralCode_29` (`referralCode`),
  UNIQUE KEY `referralCode_30` (`referralCode`),
  UNIQUE KEY `referralCode_31` (`referralCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.waitlistusers: ~5 rows (approximately)
INSERT INTO `waitlistusers` (`id`, `email`, `device`, `interest`, `referralCode`, `referredBy`, `referralCount`, `waitlistPosition`, `createdAt`, `updatedAt`) VALUES
	('5484508b-6f6c-4fe5-b986-3b9510587a4e', 'mohsan.webdev@gmail.com', 'Android', 'Recovery & mobility', 'BA151D', '6A7D55', 0, NULL, '2026-05-01 17:03:22', '2026-05-01 17:03:22'),
	('63ed9a88-b30d-4f9f-bdb0-da84c46c1b17', 'mohsancode@gmail.com', 'Android', 'Workout form correction', 'AB1A82', NULL, 2, NULL, '2026-05-01 13:56:16', '2026-05-01 15:28:32'),
	('6ad25e41-6cc2-483c-994b-a7f04642bc03', 'tenaco5723@kynninc.com', 'Android', 'Workout form correction', '6A7D55', 'AB1A82', 1, NULL, '2026-05-01 15:28:32', '2026-05-01 17:03:22'),
	('798df966-8697-4b48-8460-37392a2cedfb', 'musmangul99@gmail.com', 'iPhone', 'Fitness gaming', 'E9CE8C', '370297', 0, NULL, '2026-05-01 15:48:05', '2026-05-01 15:48:05'),
	('e2070a6d-067f-474c-b9d0-f27eda9b96c4', 'amohsan12345678@gmail.com', 'Android', 'Fitness gaming', '370297', 'AB1A82', 1, NULL, '2026-05-01 14:21:13', '2026-05-01 15:48:05');

-- Dumping structure for table formforge_db.workout_sessions
CREATE TABLE IF NOT EXISTS `workout_sessions` (
  `id` char(36) NOT NULL,
  `user_id` char(36) NOT NULL,
  `exercise_id` char(36) NOT NULL,
  `mode` enum('train','play','recover') NOT NULL,
  `challenge_id` char(36) DEFAULT NULL,
  `form_score` int DEFAULT NULL,
  `reps` int NOT NULL DEFAULT '0',
  `sets` int NOT NULL DEFAULT '0',
  `duration_sec` int NOT NULL DEFAULT '0',
  `calories` int DEFAULT NULL,
  `xp_earned` int NOT NULL DEFAULT '0',
  `mistakes` json DEFAULT NULL,
  `notes` text,
  `completed_at` datetime NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `exercise_id` (`exercise_id`),
  KEY `challenge_id` (`challenge_id`),
  CONSTRAINT `workout_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `workout_sessions_ibfk_2` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `workout_sessions_ibfk_3` FOREIGN KEY (`challenge_id`) REFERENCES `challenges` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.workout_sessions: ~51 rows (approximately)
INSERT INTO `workout_sessions` (`id`, `user_id`, `exercise_id`, `mode`, `challenge_id`, `form_score`, `reps`, `sets`, `duration_sec`, `calories`, `xp_earned`, `mistakes`, `notes`, `completed_at`, `createdAt`, `updatedAt`) VALUES
	('0345bbe3-3abb-4e6c-a971-068f013599a1', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '32d3d42f-e926-4904-a550-d49fa7bdaf62', 'train', NULL, 49, 6, 1, 41, NULL, 49, '["Body Detected. Move Through The Full Rep Range.", "Shoulder position", "Press To Full Extension"]', NULL, '2026-06-23 06:10:46', '2026-06-23 06:10:48', '2026-06-23 06:10:48'),
	('04b02a54-2e45-421c-b48d-9c0714f6554e', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '86dc75ba-4bb2-446a-a9aa-27d044209d19', 'train', NULL, 52, 2, 1, 21, NULL, 52, '["Body Detected. Move Through The Full Rep Range.", "Camera setup", "Stance control"]', NULL, '2026-06-19 15:59:23', '2026-06-19 15:59:25', '2026-06-19 15:59:25'),
	('04d174b5-c1ee-45a3-a168-4f34cdaa1edf', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '0eafe471-1d5c-4b5e-a513-e03d39e3d46f', 'train', NULL, 52, 0, 1, 6, NULL, 52, '["Back posture", "No Body Detected"]', NULL, '2026-06-23 08:51:07', '2026-06-23 08:51:09', '2026-06-23 08:51:09'),
	('0b2ae2b9-b6ca-40e9-87f1-08047a5a1898', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '509880db-396c-428e-908c-59e76e79152b', 'train', NULL, 49, 3, 1, 23, NULL, 49, '["Body Detected. Move Through The Full Rep Range.", "No Body Detected", "Shoulder position"]', NULL, '2026-06-22 14:04:00', '2026-06-22 14:04:02', '2026-06-22 14:04:02'),
	('1421fbb9-2c99-494c-892e-7b6fe670cc05', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '888594f4-f2ca-4038-b088-d8b4da1212e8', 'train', NULL, 44, 2, 1, 40, NULL, 44, '["Body Detected. Move Through The Full Rep Range.", "Knee tracking"]', NULL, '2026-06-22 13:43:51', '2026-06-22 13:43:53', '2026-06-22 13:43:53'),
	('17640805-1bba-4d87-8025-ae502081fd91', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '888594f4-f2ca-4038-b088-d8b4da1212e8', 'train', NULL, 52, 4, 1, 60, NULL, 52, '["Body Detected. Move Through The Full Rep Range.", "No Body Detected", "Camera setup"]', NULL, '2026-06-23 11:17:27', '2026-06-23 11:17:29', '2026-06-23 11:17:29'),
	('187b96f0-942e-462e-b647-47e59783fc09', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '1c3cf316-8330-4f67-bf56-b366c61eb85c', 'train', NULL, 52, 0, 1, 33, NULL, 52, '["Camera setup", "Body Detected. Move Through The Full Rep Range."]', NULL, '2026-06-22 13:46:58', '2026-06-22 13:47:00', '2026-06-22 13:47:00'),
	('1da21ce5-3aea-4d29-9133-6a30c9011702', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '1c98c98d-e943-489d-b792-7e7b20394e36', 'train', NULL, 49, 4, 1, 77, NULL, 49, '["Shoulder position", "Body Detected. Move Through The Full Rep Range.", "Lower Fully. Keep Smooth Control."]', NULL, '2026-06-23 06:59:22', '2026-06-23 06:59:24', '2026-06-23 06:59:24'),
	('1deec1e5-7110-4aa9-9891-2eb4baede1f5', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '888594f4-f2ca-4038-b088-d8b4da1212e8', 'train', NULL, 44, 3, 1, 42, NULL, 44, '["Body Detected. Move Through The Full Rep Range.", "Knee tracking", "No Body Detected"]', NULL, '2026-06-22 14:03:30', '2026-06-22 14:03:31', '2026-06-22 14:03:31'),
	('225190b1-484f-4ee0-9221-7f232ee2eef0', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '6387ae2e-1272-4a17-b263-475dd4f8e562', 'train', NULL, 49, 8, 1, 65, NULL, 49, '["Body Detected. Move Through The Full Rep Range.", "Shoulder position", "Back posture"]', NULL, '2026-06-23 06:03:48', '2026-06-23 06:03:49', '2026-06-23 06:03:49'),
	('22c7482f-ad70-4d9e-ac41-41f033d8026a', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '3a52c682-5111-4698-8ffa-45d70b004522', 'train', NULL, 52, 0, 1, 18, NULL, 52, '["Camera setup"]', NULL, '2026-06-22 12:37:48', '2026-06-22 12:37:50', '2026-06-22 12:37:50'),
	('25227c39-67f3-44b3-9b91-2fcd456b4234', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', 'e27c9e80-2eff-45c5-83df-993abb888df5', 'train', NULL, 49, 1, 1, 92, NULL, 49, '["Body Detected. Move Through The Full Rep Range.", "Press Overhead Fully. Keep Smooth Control.", "Shoulder position"]', NULL, '2026-06-22 13:45:31', '2026-06-22 13:45:34', '2026-06-22 13:45:34'),
	('2a2372a3-0d8c-4305-9d96-2651b7626e9e', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '888594f4-f2ca-4038-b088-d8b4da1212e8', 'train', NULL, 44, 0, 1, 50, NULL, 44, '["Knee tracking", "Body Detected. Move Through The Full Rep Range.", "Camera setup"]', NULL, '2026-06-22 13:28:43', '2026-06-22 13:28:45', '2026-06-22 13:28:45'),
	('33fb6112-c0d9-46ff-8cc4-a4984b71f059', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '32d3d42f-e926-4904-a550-d49fa7bdaf62', 'train', NULL, 100, 7, 1, 47, NULL, 100, '["Body Detected. Move Through The Full Rep Range.", "Press Both Arms Evenly. Keep Smooth Control.", "Shoulder position"]', NULL, '2026-06-23 06:34:51', '2026-06-23 06:34:53', '2026-06-23 06:34:53'),
	('357e08df-e137-4b11-a4f8-e6bea140ea9f', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '99d8f3fd-9dcb-4a36-b373-62f7b61c1820', 'train', NULL, 44, 0, 1, 9, NULL, 44, '["No Body Detected", "Camera setup", "Knee tracking"]', NULL, '2026-06-22 13:54:22', '2026-06-22 13:54:23', '2026-06-22 13:54:23'),
	('35b22f07-fb71-40f3-981c-5220f05abdfe', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '6387ae2e-1272-4a17-b263-475dd4f8e562', 'train', NULL, 52, 20, 1, 34, NULL, 52, '["Camera setup", "Body Detected. Move Through The Full Rep Range."]', NULL, '2026-06-22 14:02:36', '2026-06-22 14:02:37', '2026-06-22 14:02:37'),
	('43a9e826-5b9d-42f5-a6f6-136b7b0c3923', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '04e9fc10-eed2-413a-bcc1-eb4140486ad8', 'train', NULL, 52, 0, 1, 3, NULL, 52, '["Camera setup"]', NULL, '2026-06-22 13:30:34', '2026-06-22 13:30:35', '2026-06-22 13:30:35'),
	('4541cc59-4970-4a13-9cba-a799b5cabd58', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '4ad754fd-05c7-448c-8c33-9d089ad454ad', 'train', NULL, 52, 0, 1, 56, NULL, 52, '["Stance control", "Body Detected. Move Through The Full Rep Range.", "Shoulder position"]', NULL, '2026-06-23 09:24:52', '2026-06-23 09:24:54', '2026-06-23 09:24:54'),
	('4d8282fa-0ec6-4726-98ba-4aacff753c2a', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '6387ae2e-1272-4a17-b263-475dd4f8e562', 'train', NULL, 49, 1, 1, 32, NULL, 49, '["Body Detected. Move Through The Full Rep Range.", "Shoulder position", "Rep Not Counted Correct Highlighted Form. Keep Smooth Control."]', NULL, '2026-06-22 15:38:22', '2026-06-22 15:38:23', '2026-06-22 15:38:23'),
	('4ecfe88d-04c7-4017-8080-b03d95ebc88a', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '04e9fc10-eed2-413a-bcc1-eb4140486ad8', 'train', NULL, 52, 0, 1, 24, NULL, 52, '["Camera setup"]', NULL, '2026-06-22 13:27:46', '2026-06-22 13:27:48', '2026-06-22 13:27:48'),
	('69aaef13-18ad-4e20-88f4-d28689804a6d', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '6387ae2e-1272-4a17-b263-475dd4f8e562', 'train', NULL, 49, 13, 1, 53, NULL, 49, '["Shoulder position", "Body Detected. Move Through The Full Rep Range.", "Lower Fully. Keep Smooth Control."]', NULL, '2026-06-23 07:01:24', '2026-06-23 07:01:26', '2026-06-23 07:01:26'),
	('7135304e-b959-4b5d-bf38-badc16356c02', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '32d3d42f-e926-4904-a550-d49fa7bdaf62', 'train', NULL, 49, 3, 1, 64, NULL, 49, '["Body Detected. Move Through The Full Rep Range.", "Shoulder position", "Press To Full Extension. Keep Smooth Control."]', NULL, '2026-06-23 06:05:03', '2026-06-23 06:05:10', '2026-06-23 06:05:10'),
	('84dcc74c-dd33-4aaa-9d8e-c03b5cbcdc2c', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '509880db-396c-428e-908c-59e76e79152b', 'train', NULL, 49, 0, 1, 69, NULL, 49, '["Body Detected. Move Through The Full Rep Range.", "Shoulder position", "No Body Detected"]', NULL, '2026-06-23 11:19:07', '2026-06-23 11:19:09', '2026-06-23 11:19:09'),
	('86de4129-eb84-4745-af1d-c361bdc42fc0', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '58134982-b74b-4599-87b0-31e28dbe5996', 'train', NULL, 52, 0, 1, 41, NULL, 52, '["Camera setup", "Body Detected. Move Through The Full Rep Range.", "No Body Detected"]', NULL, '2026-06-22 14:01:55', '2026-06-22 14:01:57', '2026-06-22 14:01:57'),
	('8a2ab8fd-a860-4fc4-b702-ba687cc36fb8', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', 'e27c9e80-2eff-45c5-83df-993abb888df5', 'train', NULL, 100, 1, 1, 29, NULL, 100, '["Body Detected. Move Through The Full Rep Range.", "Shoulder position", "Rep Not Counted Correct Highlighted Form"]', NULL, '2026-06-23 06:11:25', '2026-06-23 06:11:27', '2026-06-23 06:11:27'),
	('8b80e031-4449-4e9b-bba3-98549afa451d', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '509880db-396c-428e-908c-59e76e79152b', 'train', NULL, 49, 0, 1, 68, NULL, 49, '["Body Detected. Move Through The Full Rep Range.", "Shoulder position", "No Body Detected"]', NULL, '2026-06-23 11:19:06', '2026-06-23 11:19:08', '2026-06-23 11:19:08'),
	('8d8877af-c0cc-4d0d-973d-d29c0fd4638c', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '32d3d42f-e926-4904-a550-d49fa7bdaf62', 'train', NULL, 94, 3, 1, 51, NULL, 94, '["Body Detected. Move Through The Full Rep Range.", "Shoulder position", "Press Both Arms Evenly. Keep Smooth Control."]', NULL, '2026-06-23 07:14:01', '2026-06-23 07:14:03', '2026-06-23 07:14:03'),
	('8df807e4-9f3c-480d-8d55-d68419ca8d99', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '86dc75ba-4bb2-446a-a9aa-27d044209d19', 'train', 'c286a95c-b236-442f-b7a2-3682f4d17b29', 52, 0, 1, 6, NULL, 52, '["Camera setup"]', NULL, '2026-06-22 07:18:39', '2026-06-22 07:18:44', '2026-06-22 07:18:44'),
	('9e0a2c46-7d66-4b9e-8624-10638b7df30a', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '58134982-b74b-4599-87b0-31e28dbe5996', 'train', NULL, 49, 8, 1, 61, NULL, 49, '["Body Detected. Move Through The Full Rep Range.", "Shoulder position", "Lower Fully. Keep Smooth Control."]', NULL, '2026-06-23 06:33:48', '2026-06-23 06:33:49', '2026-06-23 06:33:49'),
	('9eca937c-31e0-4679-9d14-03ecbfdd0bb0', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '0eafe471-1d5c-4b5e-a513-e03d39e3d46f', 'train', NULL, 52, 1, 1, 153, NULL, 52, '["Back posture", "Body Detected. Move Through The Full Rep Range.", "No Body Detected"]', NULL, '2026-06-23 11:14:08', '2026-06-23 11:14:11', '2026-06-23 11:14:11'),
	('9f583b1b-0aa2-40b3-b606-b7103ba1257a', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '36977cbc-7ae7-4d27-beb0-e2d2889126c1', 'train', NULL, 52, 0, 1, 132, NULL, 52, '["Camera setup", "Body Detected. Move Through The Full Rep Range.", "Stance control"]', NULL, '2026-06-23 11:21:32', '2026-06-23 11:21:34', '2026-06-23 11:21:34'),
	('a0e6467c-af2f-41ab-9553-5e7462c64284', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '32d3d42f-e926-4904-a550-d49fa7bdaf62', 'train', NULL, 100, 8, 1, 77, NULL, 100, '["Body Detected. Move Through The Full Rep Range.", "Shoulder position", "Press To Full Extension"]', NULL, '2026-06-23 07:02:49', '2026-06-23 07:02:51', '2026-06-23 07:02:51'),
	('a462bed7-26a1-4915-a5ef-a682c8d18129', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', 'c421248c-706c-46fe-b73e-d016937bfdfa', 'train', NULL, 52, 0, 1, 34, NULL, 52, '["Camera setup", "No Body Detected"]', NULL, '2026-06-23 11:11:20', '2026-06-23 11:11:22', '2026-06-23 11:11:22'),
	('a54ca5e1-8ac7-47ba-bb15-c06c8ca418f4', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '0eafe471-1d5c-4b5e-a513-e03d39e3d46f', 'train', NULL, 52, 0, 1, 31, NULL, 52, '["Body Detected. Move Through The Full Rep Range.", "Back posture", "No Body Detected"]', NULL, '2026-06-23 11:14:51', '2026-06-23 11:14:53', '2026-06-23 11:14:53'),
	('a897fbe2-5194-4d26-bb96-19515a831c71', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '509880db-396c-428e-908c-59e76e79152b', 'train', NULL, 49, 1, 1, 19, NULL, 49, '["Body Detected. Move Through The Full Rep Range.", "Shoulder position", "Arm path"]', NULL, '2026-06-22 12:42:20', '2026-06-22 12:42:21', '2026-06-22 12:42:21'),
	('bca870e5-eda4-4b20-9720-09fd13e42f9a', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '99d8f3fd-9dcb-4a36-b373-62f7b61c1820', 'train', NULL, 44, 0, 1, 35, NULL, 44, '["Knee tracking", "Body Detected. Move Through The Full Rep Range."]', NULL, '2026-06-22 13:46:17', '2026-06-22 13:46:19', '2026-06-22 13:46:19'),
	('c09a819f-d706-43e0-b75d-c41700557714', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '0a9e0ed6-81d9-4395-a0ed-8454af7792df', 'train', NULL, 52, 0, 1, 25, NULL, 52, '["Back posture", "Body Detected. Move Through The Full Rep Range."]', NULL, '2026-06-23 07:00:22', '2026-06-23 07:00:24', '2026-06-23 07:00:24'),
	('c19c8ce2-ee9b-41ec-9314-43f8ba147383', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', 'eeefad65-8dc5-4b90-b29d-3527d4294555', 'train', NULL, 44, 4, 1, 56, NULL, 44, '["Body Detected. Move Through The Full Rep Range.", "Knee tracking", "No Body Detected"]', NULL, '2026-06-22 13:48:24', '2026-06-22 13:48:25', '2026-06-22 13:48:25'),
	('c84a6384-256e-4ece-9d29-a8bc41c39aeb', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '1c98c98d-e943-489d-b792-7e7b20394e36', 'train', NULL, 49, 4, 1, 49, NULL, 49, '["Body Detected. Move Through The Full Rep Range.", "Shoulder position", "Lower Fully. Keep Smooth Control."]', NULL, '2026-06-23 06:02:36', '2026-06-23 06:02:37', '2026-06-23 06:02:37'),
	('cab7cf07-1da1-4a57-87ab-410a3d8a01c5', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '99d8f3fd-9dcb-4a36-b373-62f7b61c1820', 'train', NULL, 52, 0, 1, 5, NULL, 52, '["Camera setup"]', NULL, '2026-06-22 12:14:31', '2026-06-22 12:14:33', '2026-06-22 12:14:33'),
	('cb3ecfb3-928e-4588-8c42-0d11aeb74511', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', 'c421248c-706c-46fe-b73e-d016937bfdfa', 'train', NULL, 52, 0, 1, 26, NULL, 52, '["Camera setup", "Body Detected. Move Through The Full Rep Range.", "No Body Detected"]', NULL, '2026-06-23 11:10:32', '2026-06-23 11:10:34', '2026-06-23 11:10:34'),
	('ccf05e61-34e1-47ab-85e5-13c78e5bfa96', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '1c98c98d-e943-489d-b792-7e7b20394e36', 'train', NULL, 100, 5, 1, 71, NULL, 100, '["Body Detected. Move Through The Full Rep Range.", "Shoulder position", "Rep Not Counted Correct Highlighted Form"]', NULL, '2026-06-23 06:09:25', '2026-06-23 06:09:26', '2026-06-23 06:09:26'),
	('d8ad1b53-e7b8-4894-8898-f823d8f46ab0', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '1c98c98d-e943-489d-b792-7e7b20394e36', 'train', NULL, 49, 7, 1, 59, NULL, 49, '["Body Detected. Move Through The Full Rep Range.", "Shoulder position", "Lower Fully. Keep Smooth Control."]', NULL, '2026-06-23 06:32:37', '2026-06-23 06:32:39', '2026-06-23 06:32:39'),
	('da760b81-a3ec-4a0b-b0eb-00fe10728f30', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '99d8f3fd-9dcb-4a36-b373-62f7b61c1820', 'train', NULL, 52, 0, 1, 4, NULL, 52, '["Camera setup"]', NULL, '2026-06-22 12:22:53', '2026-06-22 12:22:54', '2026-06-22 12:22:54'),
	('dd70acd6-d011-4b2e-94f7-81a1e8b951a5', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '99d8f3fd-9dcb-4a36-b373-62f7b61c1820', 'train', NULL, 52, 0, 1, 19, NULL, 52, '["Camera setup", "Body Detected. Move Through The Full Rep Range."]', NULL, '2026-06-22 12:23:19', '2026-06-22 12:23:21', '2026-06-22 12:23:21'),
	('de85107f-9d8e-4b76-884d-1f065db8156c', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '1c98c98d-e943-489d-b792-7e7b20394e36', 'train', NULL, 52, 1, 1, 43, NULL, 52, '["Camera setup", "Body Detected. Move Through The Full Rep Range."]', NULL, '2026-06-23 05:53:53', '2026-06-23 05:53:54', '2026-06-23 05:53:54'),
	('ea5075c7-45bc-4be2-9696-6d9e5d55719a', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '20b6556a-873e-472e-9348-eda5097f1dd6', 'train', NULL, 49, 0, 1, 11, NULL, 49, '["Shoulder position", "Camera setup"]', NULL, '2026-06-22 13:54:39', '2026-06-22 13:54:40', '2026-06-22 13:54:40'),
	('eb61f237-8282-446d-8aa7-e4cb5e1f43ab', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '99d8f3fd-9dcb-4a36-b373-62f7b61c1820', 'train', NULL, 44, 0, 1, 5, NULL, 44, '["Knee tracking"]', NULL, '2026-06-22 14:04:11', '2026-06-22 14:04:13', '2026-06-22 14:04:13'),
	('ebf735fe-a1bf-4d05-a27b-862383a130e5', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '3a52c682-5111-4698-8ffa-45d70b004522', 'train', NULL, 52, 0, 1, 7, NULL, 52, '["Camera setup"]', NULL, '2026-06-22 13:47:22', '2026-06-22 13:47:23', '2026-06-22 13:47:23'),
	('ed68092d-f38e-4bd1-a2e5-c4db30dce86f', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '1c98c98d-e943-489d-b792-7e7b20394e36', 'train', NULL, 52, 0, 1, 55, NULL, 52, '["Camera setup", "Body Detected. Move Through The Full Rep Range."]', NULL, '2026-06-23 05:47:13', '2026-06-23 05:47:15', '2026-06-23 05:47:15'),
	('f812f138-33e2-45af-b402-2e6fa2915cb8', '13cfa403-8c93-48ed-aaaa-3b18771cb4dd', '99d8f3fd-9dcb-4a36-b373-62f7b61c1820', 'train', NULL, 52, 0, 1, 63, NULL, 52, '["Camera setup", "Body Detected. Move Through The Full Rep Range."]', NULL, '2026-06-22 12:35:36', '2026-06-22 12:35:38', '2026-06-22 12:35:38');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
