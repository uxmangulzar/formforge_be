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
CREATE DATABASE IF NOT EXISTS `Repvio_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `Repvio_db`;

-- Dumping structure for table formforge_db.settings
CREATE TABLE IF NOT EXISTS `settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text,
  `description` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.settings: ~3 rows (approximately)
INSERT INTO `settings` (`id`, `setting_key`, `setting_value`, `description`, `createdAt`, `updatedAt`) VALUES
	(1, 'maintenance_mode', 'false', 'Enable or disable landing page maintenance mode', '2026-05-01 12:42:43', '2026-05-01 12:42:43'),
	(2, 'max_waitlist_spots', '10000', 'Maximum number of users allowed in waitlist', '2026-05-01 12:42:43', '2026-05-01 12:42:43'),
	(3, 'beta_launch_date', '2026-06-01', 'Scheduled date for beta launch', '2026-05-01 12:42:43', '2026-05-01 12:42:43');

-- Dumping structure for table formforge_db.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` char(36) NOT NULL,
  `email` varchar(255) NOT NULL,
  `device` varchar(100) DEFAULT NULL,
  `interest` varchar(100) DEFAULT NULL,
  `referralCode` varchar(20) DEFAULT NULL,
  `referredBy` varchar(20) DEFAULT NULL,
  `referralCount` int DEFAULT '0',
  `waitlistPosition` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `referralCode` (`referralCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table formforge_db.users: ~0 rows (approximately)
INSERT INTO `users` (`id`, `email`, `device`, `interest`, `referralCode`, `referredBy`, `referralCount`, `waitlistPosition`, `createdAt`, `updatedAt`) VALUES
	('5484508b-6f6c-4fe5-b986-3b9510587a4e', 'mohsan.webdev@gmail.com', 'Android', 'Recovery & mobility', 'BA151D', '6A7D55', 0, NULL, '2026-05-01 17:03:22', '2026-05-01 17:03:22'),
	('63ed9a88-b30d-4f9f-bdb0-da84c46c1b17', 'mohsancode@gmail.com', 'Android', 'Workout form correction', 'AB1A82', NULL, 2, NULL, '2026-05-01 13:56:16', '2026-05-01 15:28:32'),
	('6ad25e41-6cc2-483c-994b-a7f04642bc03', 'tenaco5723@kynninc.com', 'Android', 'Workout form correction', '6A7D55', 'AB1A82', 1, NULL, '2026-05-01 15:28:32', '2026-05-01 17:03:22'),
	('798df966-8697-4b48-8460-37392a2cedfb', 'musmangul99@gmail.com', 'iPhone', 'Fitness gaming', 'E9CE8C', '370297', 0, NULL, '2026-05-01 15:48:05', '2026-05-01 15:48:05'),
	('e2070a6d-067f-474c-b9d0-f27eda9b96c4', 'amohsan12345678@gmail.com', 'Android', 'Fitness gaming', '370297', 'AB1A82', 1, NULL, '2026-05-01 14:21:13', '2026-05-01 15:48:05');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
