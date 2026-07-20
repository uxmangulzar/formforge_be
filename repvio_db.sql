-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: repvio_db
-- ------------------------------------------------------
-- Server version	8.0.46-0ubuntu0.24.04.3

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Settings`
--

DROP TABLE IF EXISTS `Settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(255) NOT NULL,
  `setting_value` text,
  `description` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
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
  UNIQUE KEY `setting_key_29` (`setting_key`),
  UNIQUE KEY `setting_key_30` (`setting_key`),
  UNIQUE KEY `setting_key_31` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Settings`
--

LOCK TABLES `Settings` WRITE;
/*!40000 ALTER TABLE `Settings` DISABLE KEYS */;
INSERT INTO `Settings` VALUES (1,'maintenance_mode','false','Enable or disable landing page maintenance mode',1,'2026-05-08 15:57:28','2026-05-08 15:57:28'),(2,'max_waitlist_spots','10000','Maximum number of users allowed in waitlist',1,'2026-05-08 15:57:28','2026-05-08 15:57:28'),(3,'beta_launch_date','2026-06-01','Scheduled date for beta launch',1,'2026-05-08 15:57:28','2026-05-08 15:57:28');
/*!40000 ALTER TABLE `Settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_notification_settings`
--

DROP TABLE IF EXISTS `admin_notification_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_notification_settings` (
  `user_id` char(36) NOT NULL,
  `in_app_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `email_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `allowed_types` json DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_admin_notification_settings_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_notification_settings`
--

LOCK TABLES `admin_notification_settings` WRITE;
/*!40000 ALTER TABLE `admin_notification_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_notification_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `badge_rules`
--

DROP TABLE IF EXISTS `badge_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `badge_rules` (
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
  CONSTRAINT `badge_rules_ibfk_57` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `badge_rules_ibfk_58` FOREIGN KEY (`challenge_id`) REFERENCES `challenges` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `badge_rules`
--

LOCK TABLES `badge_rules` WRITE;
/*!40000 ALTER TABLE `badge_rules` DISABLE KEYS */;
INSERT INTO `badge_rules` VALUES ('0cf588a2-ed09-41cc-b015-cecf86e8d230','c3917a63-d497-4c53-932b-e630a89b25a1','c286a95c-b236-442f-b7a2-3682f4d17b29','challenge_complete',NULL,0,1,'2026-07-16 16:05:30','2026-07-16 16:05:30');
/*!40000 ALTER TABLE `badge_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `badges`
--

DROP TABLE IF EXISTS `badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `badges` (
  `id` char(36) NOT NULL,
  `challenge_id` char(36) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `icon_url` varchar(500) DEFAULT NULL,
  `rarity` enum('common','rare','epic','legendary') NOT NULL DEFAULT 'common',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_badges_active` (`is_active`),
  KEY `idx_badges_challenge_id` (`challenge_id`),
  CONSTRAINT `badges_ibfk_1` FOREIGN KEY (`challenge_id`) REFERENCES `challenges` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `badges`
--

LOCK TABLES `badges` WRITE;
/*!40000 ALTER TABLE `badges` DISABLE KEYS */;
INSERT INTO `badges` VALUES ('c3917a63-d497-4c53-932b-e630a89b25a1','c286a95c-b236-442f-b7a2-3682f4d17b29','GOAT',NULL,NULL,'rare',1,'2026-07-01 12:35:58','2026-07-01 12:35:58');
/*!40000 ALTER TABLE `badges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `challenge_stage_exercises`
--

DROP TABLE IF EXISTS `challenge_stage_exercises`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `challenge_stage_exercises` (
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
  CONSTRAINT `challenge_stage_exercises_ibfk_57` FOREIGN KEY (`challenge_stage_id`) REFERENCES `challenge_stages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `challenge_stage_exercises_ibfk_58` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `challenge_stage_exercises`
--

LOCK TABLES `challenge_stage_exercises` WRITE;
/*!40000 ALTER TABLE `challenge_stage_exercises` DISABLE KEYS */;
INSERT INTO `challenge_stage_exercises` VALUES ('427ce2db-e118-41a0-b011-672a02bd6f9a','309f558d-f9b2-41bb-bf29-712f860879f2','32d3d42f-e926-4904-a550-d49fa7bdaf62',4,3,12,50,0,NULL,'2026-07-16 16:05:30','2026-07-16 16:05:30'),('6fe6ddd6-2974-4a21-b820-12bdb5e6fefd','e27e8c1c-4b73-4d09-84e9-79fe45969d3c','f68763ea-aae8-4a0d-8559-5b3ee922f07b',1,3,12,50,0,NULL,'2026-07-16 16:12:30','2026-07-16 16:12:30'),('b38ac288-59ec-41d3-9c69-ae3c196ae3b5','309f558d-f9b2-41bb-bf29-712f860879f2','0a9e0ed6-81d9-4395-a0ed-8454af7792df',2,7,12,50,0,NULL,'2026-07-16 16:05:30','2026-07-16 16:05:30'),('be680cb9-407c-44ac-8de6-2a53fdda3cdd','309f558d-f9b2-41bb-bf29-712f860879f2','f68763ea-aae8-4a0d-8559-5b3ee922f07b',1,3,12,50,0,NULL,'2026-07-16 16:05:30','2026-07-16 16:05:30'),('cd39782a-a3c5-47fc-b01d-0db84e53d449','309f558d-f9b2-41bb-bf29-712f860879f2','c144ba27-8353-4411-b80f-a56747999111',3,3,12,50,0,NULL,'2026-07-16 16:05:30','2026-07-16 16:05:30'),('fac6303c-72dd-46bb-9781-fe130f0448b9','309f558d-f9b2-41bb-bf29-712f860879f2','4ad754fd-05c7-448c-8c33-9d089ad454ad',5,3,12,50,0,NULL,'2026-07-16 16:05:30','2026-07-16 16:05:30');
/*!40000 ALTER TABLE `challenge_stage_exercises` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `challenge_stages`
--

DROP TABLE IF EXISTS `challenge_stages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `challenge_stages` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `challenge_stages`
--

LOCK TABLES `challenge_stages` WRITE;
/*!40000 ALTER TABLE `challenge_stages` DISABLE KEYS */;
INSERT INTO `challenge_stages` VALUES ('309f558d-f9b2-41bb-bf29-712f860879f2','c286a95c-b236-442f-b7a2-3682f4d17b29',1,'qwerw','dfsfsfsdf',210,'2026-07-16 16:05:30','2026-07-16 16:05:30'),('e27e8c1c-4b73-4d09-84e9-79fe45969d3c','63e052ea-438b-46b4-b7e9-f599397da1b9',1,'Weak 1','stages',8,'2026-07-16 16:12:30','2026-07-16 16:12:30');
/*!40000 ALTER TABLE `challenge_stages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `challenges`
--

DROP TABLE IF EXISTS `challenges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `challenges` (
  `id` char(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `image_urls` json DEFAULT NULL,
  `video_urls` json DEFAULT NULL,
  `starts_at` datetime NOT NULL,
  `ends_at` datetime NOT NULL,
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_challenges_status` (`status`),
  KEY `idx_challenges_dates` (`starts_at`,`ends_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `challenges`
--

LOCK TABLES `challenges` WRITE;
/*!40000 ALTER TABLE `challenges` DISABLE KEYS */;
INSERT INTO `challenges` VALUES ('63e052ea-438b-46b4-b7e9-f599397da1b9','Testing Challenge','This is the challenge for testing purpose','[\"/uploads/files-1784218062196-507234423.jfif\"]','[]','2026-07-16 16:06:00','2026-07-23 16:06:00','published','2026-07-16 16:08:38','2026-07-16 16:12:30'),('c286a95c-b236-442f-b7a2-3682f4d17b29','Challenge','This is the first challenge','[\"/uploads/files-1784217802601-644933189.jfif\"]','[]','2026-05-13 14:03:00','2034-06-20 14:03:00','published','2026-05-13 14:10:09','2026-07-16 16:04:25');
/*!40000 ALTER TABLE `challenges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exercise_categories`
--

DROP TABLE IF EXISTS `exercise_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exercise_categories` (
  `id` char(36) NOT NULL,
  `slug` varchar(64) NOT NULL,
  `display_name` varchar(120) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `is_locked` tinyint(1) NOT NULL DEFAULT '0',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  UNIQUE KEY `slug_2` (`slug`),
  UNIQUE KEY `slug_3` (`slug`),
  UNIQUE KEY `slug_4` (`slug`),
  UNIQUE KEY `slug_5` (`slug`),
  UNIQUE KEY `slug_6` (`slug`),
  UNIQUE KEY `slug_7` (`slug`),
  UNIQUE KEY `slug_8` (`slug`),
  UNIQUE KEY `slug_9` (`slug`),
  UNIQUE KEY `slug_10` (`slug`),
  UNIQUE KEY `slug_11` (`slug`),
  UNIQUE KEY `slug_12` (`slug`),
  UNIQUE KEY `slug_13` (`slug`),
  UNIQUE KEY `slug_14` (`slug`),
  UNIQUE KEY `slug_15` (`slug`),
  UNIQUE KEY `slug_16` (`slug`),
  UNIQUE KEY `slug_17` (`slug`),
  UNIQUE KEY `slug_18` (`slug`),
  UNIQUE KEY `slug_19` (`slug`),
  UNIQUE KEY `slug_20` (`slug`),
  UNIQUE KEY `slug_21` (`slug`),
  UNIQUE KEY `slug_22` (`slug`),
  UNIQUE KEY `slug_23` (`slug`),
  UNIQUE KEY `slug_24` (`slug`),
  UNIQUE KEY `slug_25` (`slug`),
  UNIQUE KEY `slug_26` (`slug`),
  UNIQUE KEY `slug_27` (`slug`),
  UNIQUE KEY `slug_28` (`slug`),
  UNIQUE KEY `slug_29` (`slug`),
  UNIQUE KEY `slug_30` (`slug`),
  KEY `idx_exercise_categories_active_sort` (`is_active`,`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exercise_categories`
--

LOCK TABLES `exercise_categories` WRITE;
/*!40000 ALTER TABLE `exercise_categories` DISABLE KEYS */;
INSERT INTO `exercise_categories` VALUES ('18a16f69-3cf4-47cd-adbb-9eb9917f2193','balance_stability','Balance Stability',NULL,10,1,0,'2026-07-17 09:30:16','2026-07-17 09:30:16'),('4c7931f4-49ef-4053-bd78-d90b2b21b54e','cardio','Cardio',NULL,10,1,0,'2026-07-17 14:32:29','2026-07-17 14:32:29'),('6da8d40c-c82c-412e-acc3-6a749cce7004','strength','Strength',NULL,10,1,0,'2026-07-17 09:24:37','2026-07-17 09:24:37'),('a1111111-1111-4111-8111-111111111101','upper_body','Upper Body',NULL,10,0,0,'2026-05-15 18:33:30','2026-07-17 09:27:49'),('a1111111-1111-4111-8111-111111111102','lower_body','Lower Body',NULL,20,1,0,'2026-05-15 18:33:30','2026-07-17 09:28:27'),('a1111111-1111-4111-8111-111111111103','core','Core',NULL,30,1,0,'2026-05-15 18:33:30','2026-07-07 17:48:40'),('a1111111-1111-4111-8111-111111111104','full_body','Full Body',NULL,40,1,0,'2026-05-15 18:33:30','2026-07-07 17:48:41'),('bc8b9d0f-0d6f-463e-b355-2145abc8bd60','flexibility','Flexibity',NULL,10,1,0,'2026-07-17 09:30:33','2026-07-17 09:30:33'),('cb013234-6019-4189-8c63-bef7c740d52d','mobality','Mobality',NULL,10,1,0,'2026-07-17 09:29:25','2026-07-17 09:29:25'),('deba510b-2415-4680-913c-42dcab1a8ba7','recovery','Recovery',NULL,10,1,0,'2026-07-17 09:29:48','2026-07-17 09:29:48');
/*!40000 ALTER TABLE `exercise_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exercise_training_modes`
--

DROP TABLE IF EXISTS `exercise_training_modes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exercise_training_modes` (
  `exercise_id` char(36) NOT NULL,
  `mode_id` char(36) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`exercise_id`,`mode_id`),
  KEY `idx_exercise_training_modes_mode` (`mode_id`),
  CONSTRAINT `fk_exercise_training_modes_exercise` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_exercise_training_modes_mode` FOREIGN KEY (`mode_id`) REFERENCES `training_modes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exercise_training_modes`
--

LOCK TABLES `exercise_training_modes` WRITE;
/*!40000 ALTER TABLE `exercise_training_modes` DISABLE KEYS */;
INSERT INTO `exercise_training_modes` VALUES ('0112ee81-a37f-42fa-9f54-42cef106cace','a0000001-0001-4001-8001-000000000002','2026-07-03 15:28:21','2026-07-03 15:28:21'),('578b3dbd-dad4-40f2-a363-ae50b52cdd52','a0000001-0001-4001-8001-000000000001','2026-05-14 10:22:19','2026-05-14 10:22:19'),('578b3dbd-dad4-40f2-a363-ae50b52cdd52','a0000001-0001-4001-8001-000000000003','2026-05-14 13:02:32','2026-05-14 13:02:32'),('8459a4e2-4873-11f1-b0b5-c8f7503f9a48','a0000001-0001-4001-8001-000000000001','2026-05-14 10:22:19','2026-05-14 10:22:19'),('8459a4e2-4873-11f1-b0b5-c8f7503f9a48','a0000001-0001-4001-8001-000000000003','2026-05-14 13:02:32','2026-05-14 13:02:32'),('845ac1ed-4873-11f1-b0b5-c8f7503f9a48','a0000001-0001-4001-8001-000000000001','2026-05-14 10:22:19','2026-05-14 10:22:19'),('845ac1ed-4873-11f1-b0b5-c8f7503f9a48','a0000001-0001-4001-8001-000000000003','2026-05-14 13:02:32','2026-05-14 13:02:32'),('845ac8f8-4873-11f1-b0b5-c8f7503f9a48','a0000001-0001-4001-8001-000000000003','2026-05-14 13:02:32','2026-05-14 13:02:32'),('845ad01f-4873-11f1-b0b5-c8f7503f9a48','a0000001-0001-4001-8001-000000000001','2026-05-14 10:22:19','2026-05-14 10:22:19'),('845ad01f-4873-11f1-b0b5-c8f7503f9a48','a0000001-0001-4001-8001-000000000003','2026-05-14 13:02:32','2026-05-14 13:02:32'),('86dc75ba-4bb2-446a-a9aa-27d044209d19','a0000001-0001-4001-8001-000000000001','2026-05-14 10:22:19','2026-05-14 10:22:19'),('86dc75ba-4bb2-446a-a9aa-27d044209d19','a0000001-0001-4001-8001-000000000003','2026-05-14 13:02:32','2026-05-14 13:02:32'),('91e2855e-508c-11f1-b0fc-00163c1e51d8','a0000001-0001-4001-8001-000000000001','2026-05-15 18:33:30','2026-05-15 18:33:30'),('91e2855e-508c-11f1-b0fc-00163c1e51d8','a0000001-0001-4001-8001-000000000003','2026-05-15 18:33:30','2026-05-15 18:33:30'),('91e28b7f-508c-11f1-b0fc-00163c1e51d8','a0000001-0001-4001-8001-000000000001','2026-05-15 18:33:30','2026-05-15 18:33:30'),('91e28b7f-508c-11f1-b0fc-00163c1e51d8','a0000001-0001-4001-8001-000000000003','2026-05-15 18:33:30','2026-05-15 18:33:30'),('91e28d70-508c-11f1-b0fc-00163c1e51d8','a0000001-0001-4001-8001-000000000001','2026-05-15 18:33:30','2026-05-15 18:33:30'),('91e28d70-508c-11f1-b0fc-00163c1e51d8','a0000001-0001-4001-8001-000000000003','2026-05-15 18:33:30','2026-05-15 18:33:30'),('91e28e13-508c-11f1-b0fc-00163c1e51d8','a0000001-0001-4001-8001-000000000001','2026-05-15 18:33:30','2026-05-15 18:33:30'),('91e28e13-508c-11f1-b0fc-00163c1e51d8','a0000001-0001-4001-8001-000000000003','2026-05-15 18:33:30','2026-05-15 18:33:30'),('9ea6ee94-da2c-4bcf-b586-8e0e8fb781d5','a0000001-0001-4001-8001-000000000001','2026-05-14 10:22:19','2026-05-14 10:22:19'),('9ea6ee94-da2c-4bcf-b586-8e0e8fb781d5','a0000001-0001-4001-8001-000000000003','2026-05-14 13:02:32','2026-05-14 13:02:32'),('f3922cdc-a715-4382-9d1b-4f58a3c5f249','a0000001-0001-4001-8001-000000000002','2026-07-03 15:28:21','2026-07-03 15:28:21'),('f605d35a-0751-4d09-9a60-8a9cbf138a08','a0000001-0001-4001-8001-000000000002','2026-07-03 15:28:21','2026-07-03 15:28:21');
/*!40000 ALTER TABLE `exercise_training_modes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exercises`
--

DROP TABLE IF EXISTS `exercises`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exercises` (
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
  `custom_fields` json DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_locked` tinyint(1) NOT NULL DEFAULT '0',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `exercises_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `exercise_categories` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exercises`
--

LOCK TABLES `exercises` WRITE;
/*!40000 ALTER TABLE `exercises` DISABLE KEYS */;
INSERT INTO `exercises` VALUES ('0112ee81-a37f-42fa-9f54-42cef106cace','Frozen Shoulder Rehab','recover','deba510b-2415-4680-913c-42dcab1a8ba7','Frozen Shoulder Rehab is a gentle mobility exercise designed to reduce shoulder stiffness, improve range of motion, and gradually restore normal shoulder function. Perform each movement slowly and within a comfortable, pain-free range. Focus on controlled motion rather than stretching forcefully.\n\nTips\nKeep your shoulders relaxed and avoid shrugging.\nMove slowly and smoothly without jerking.\nStay within a comfortable range of motion—mild stretching is okay, but stop if you feel sharp pain.\nMaintain an upright posture throughout the exercise.\nBreathe normally and avoid holding your breath.\nPerform the movements consistently to improve flexibility over time.\nDo not force the shoulder beyond its current mobility.\nIf pain increases significantly or persists after exercising, reduce the range of motion or consult a healthcare professional.','','','/uploads/file-1783092388083-415852779.csv','intermediate','[]','{}','{}',NULL,1,0,'2026-07-03 14:27:05','2026-07-17 09:31:13'),('04e9fc10-eed2-413a-bcc1-eb4140486ad8','Sits Ups','train','a1111111-1111-4111-8111-111111111104','Lie on your back.\nBend your knees and place your feet flat on the floor.\nCross your arms over your chest or place fingertips lightly behind your ears.\nTighten your core.\nMovement\nLift your upper body toward your knees.\nKeep the movement controlled.\nExhale as you sit up.\nSlowly lower yourself back to the starting position.\nInhale as you lower down.','','','/uploads/file-1782134096953-630396085.csv','beginner','[]','{}','{}',NULL,0,0,'2026-06-22 13:20:51','2026-07-04 22:22:10'),('095408ef-b323-4549-b7ec-e4092669cea2','Standard Squat','train','a1111111-1111-4111-8111-111111111104','Keep your feet shoulder-width apart. Lower your hips as if sitting in a chair, keeping your chest up and back straight.','https://assets.formforge.ai/exercises/squat.mp4','','','beginner','[\"Quads\", \"Glutes\", \"Hamstrings\"]','{\"heel_contact\": true, \"max_back_lean\": 30, \"min_knee_angle\": 90}','{\"state_a\": \"standing\", \"state_b\": \"descending\", \"state_c\": \"squat_point\", \"threshold\": 100}',NULL,0,0,'2026-05-15 19:07:05','2026-07-04 22:22:10'),('0a9e0ed6-81d9-4395-a0ed-8454af7792df','Set Up High Box','train','a1111111-1111-4111-8111-111111111104','Description:\nThe Setup High Box exercise is a lower-body movement that involves stepping onto a high box or platform. It primarily targets the quadriceps, glutes, and hamstrings while also improving balance, coordination, and single-leg strength. The increased box height places greater demand on the working leg compared to a standard step-up.\n\nInstructions:\n\nStand facing a sturdy high box or platform with your feet hip-width apart.\nPlace one foot firmly on top of the box.\nEngage your core and keep your chest lifted.\nPush through the heel of the elevated foot to lift your body onto the box.\nBring the opposite foot onto the box and stand tall at the top.\nStep down carefully, leading with the non-working leg.\nReturn to the starting position with control.\nRepeat for the desired number of repetitions, then switch the leading leg if performing single-leg sets.\n\nTips:\n\nUse a box height that allows proper form without excessive strain.\nDrive through the heel of the working leg rather than pushing off the ground leg.\nKeep your knee aligned with your toes throughout the movement.\nAvoid leaning forward excessively or using momentum.\nMove slowly and maintain balance during both the ascent and descent.','','/uploads/gif-1782199192778-685474122.gif','/uploads/file-1782197387482-972147277.csv','intermediate','[\"Quadriceps\", \"Gluteus Maximus\", \"Hamstrings\", \"Calves,\"]','{}','{}',NULL,1,0,'2026-06-23 06:49:49','2026-07-04 22:22:10'),('0eafe471-1d5c-4b5e-a513-e03d39e3d46f','Single Leg DeadLift','train','6da8d40c-c82c-412e-acc3-6a749cce7004','Instructions:\n\nStand upright with your feet hip-width apart, holding a dumbbell or kettlebell in one or both hands (optional).\nShift your weight onto one leg and slightly bend the knee of the standing leg.\nEngage your core and keep your back straight.\nHinge at the hips while extending the non-working leg straight behind you.\nLower your torso until it is nearly parallel to the floor or until you feel a stretch in your hamstrings.\nKeep your hips square and shoulders level throughout the movement.\nDrive through the heel of the standing leg and squeeze your glute to return to the starting position.\nComplete the desired number of repetitions, then switch legs.\n\nTips:\n\nMaintain a neutral spine and avoid rounding your back.\nKeep a slight bend in the standing knee throughout the exercise.\nMove slowly and with control to improve balance and stability.\nFocus on hinging at the hips rather than bending at the waist.\nIf balance is challenging, perform the movement near a wall or support.','','/uploads/gif-1782203468664-406432382.gif','/uploads/file-1782203450202-161290629.csv','advanced','[\"Hamstrings\", \"Gluteus Maximus\", \"Lower Back,\"]','{}','{}',NULL,1,0,'2026-06-23 08:31:12','2026-07-17 09:25:00'),('0f9206c3-a0f4-464e-95d8-14fa3084c032','High Knee','train','4c7931f4-49ef-4053-bd78-d90b2b21b54e','Description\nStand upright with your feet hip-width apart and your arms at your sides.\nEngage your core and keep your chest lifted.\nBegin running in place, driving one knee up toward hip height while the opposite arm swings forward naturally.\nQuickly alternate legs, maintaining a fast, rhythmic pace.\nLand softly on the balls of your feet and keep your movements controlled.\nContinue for the desired duration or number of repetitions.','','/uploads/gif-1784542864990-876318965.gif','/uploads/file-1784542830184-858489087.csv','intermediate','[\"Hip flexors\", \"Quadriceps\", \"Hamstrings\", \"Calves\", \"Glutes\"]','{}','{}',NULL,1,0,'2026-07-20 10:21:53','2026-07-20 10:21:53'),('10043d9d-5467-41b6-8928-426027e92cd0','Plank','train','a1111111-1111-4111-8111-111111111104','Isometric core exercise for stability and endurance.','https://assets.formforge.ai/exercises/plank.mp4','','','intermediate','[\"Abs\", \"Lower Back\", \"Shoulders\"]','{\"time_based\": true, \"back_flatness\": 0.9, \"hip_height_threshold\": 0.2}','{\"type\": \"duration\", \"unit\": \"seconds\", \"min_hold\": 30}',NULL,0,0,'2026-05-15 15:35:28','2026-07-04 22:22:10'),('10e78c3c-abf0-4e50-9ae1-40a2eb8d265c','Frozen Shoulder Rehab','recover','6da8d40c-c82c-412e-acc3-6a749cce7004','Frozen Shoulder Rehab is a gentle mobility exercise designed to reduce shoulder stiffness, improve range of motion, and gradually restore normal shoulder function. Perform each movement slowly and within a comfortable, pain-free range. Focus on controlled motion rather than stretching forcefully.\n\nTips\nKeep your shoulders relaxed and avoid shrugging.\nMove slowly and smoothly without jerking.\nStay within a comfortable range of motion—mild stretching is okay, but stop if you feel sharp pain.\nMaintain an upright posture throughout the exercise.\nBreathe normally and avoid holding your breath.\nPerform the movements consistently to improve flexibility over time.\nDo not force the shoulder beyond its current mobility.\nIf pain increases significantly or persists after exercising, reduce the range of motion or consult a healthcare professional.','','','','intermediate','[]','{}','{}',NULL,0,0,'2026-07-03 14:27:05','2026-07-17 09:26:43'),('1bbfec87-f3b1-4d4b-abc9-8aecb7a37689','Frozen Shoulder Rehab','recover','6da8d40c-c82c-412e-acc3-6a749cce7004','Frozen Shoulder Rehab is a gentle mobility exercise designed to reduce shoulder stiffness, improve range of motion, and gradually restore normal shoulder function. Perform each movement slowly and within a comfortable, pain-free range. Focus on controlled motion rather than stretching forcefully.\n\nTips\nKeep your shoulders relaxed and avoid shrugging.\nMove slowly and smoothly without jerking.\nStay within a comfortable range of motion—mild stretching is okay, but stop if you feel sharp pain.\nMaintain an upright posture throughout the exercise.\nBreathe normally and avoid holding your breath.\nPerform the movements consistently to improve flexibility over time.\nDo not force the shoulder beyond its current mobility.\nIf pain increases significantly or persists after exercising, reduce the range of motion or consult a healthcare professional.','','','','intermediate','[]','{}','{}',NULL,0,0,'2026-07-03 14:27:05','2026-07-17 09:26:47'),('1c3cf316-8330-4f67-bf56-b366c61eb85c','Warrior Yoga','train','a1111111-1111-4111-8111-111111111104','Instructions\nStand tall with feet together.\nStep one foot back about 3–4 feet.\nTurn the back foot outward about 45°.\nBend the front knee to roughly 90°.\nRaise both arms overhead.\nKeep your chest facing forward.\nHold for 20–30 seconds.\nMuscles Worked\nQuadriceps\nGlutes\nHamstrings\nCore\nShoulders','','/uploads/gif-1782143632655-890378430.gif','/uploads/file-1782134524808-454429574.csv','beginner','[\"Glutes\", \"Quadriceps\", \"Hip Flexors\", \"Core\", \"Shoulders\", \"Inner Thighs\"]','{}','{}',NULL,0,0,'2026-06-22 13:24:09','2026-07-01 05:37:59'),('1c98c98d-e943-489d-b792-7e7b20394e36','CONCENTRATION CURL','train','6da8d40c-c82c-412e-acc3-6a749cce7004','The Concentration Curl is an isolation exercise that targets the biceps brachii. It is performed while seated, with the working arm braced against the inner thigh to minimize body movement and focus tension directly on the biceps. This exercise helps improve arm strength, muscle definition, and peak bicep development.\n\nInstructions:\n\nSit on a bench with your feet flat on the floor and knees apart.\nHold a dumbbell in one hand with your palm facing upward.\nRest the back of your upper arm against the inside of the same-side thigh.\nExtend your arm downward until it is almost fully straight.\nCurl the dumbbell upward toward your shoulder while keeping your upper arm stationary.\nSqueeze your bicep at the top of the movement.\nSlowly lower the dumbbell back to the starting position in a controlled manner.\nComplete the desired number of repetitions, then switch arms.\n\nTips:\n\nKeep your elbow fixed against your thigh throughout the movement.\nAvoid swinging the weight or using momentum.\nFocus on a full range of motion and controlled tempo.\nExhale while curling up and inhale while lowering the weight.\n\nPrimary Muscle: Biceps Brachii\nSecondary Muscles: Brachialis, Brachioradialis\nEquipment: Dumbbell\nDifficulty Level: Beginner to Intermediate','','/uploads/gif-1782193316720-247629714.gif','/uploads/file-1782193296977-667957888.csv','intermediate','[]','{}','{}',NULL,0,0,'2026-06-23 05:42:42','2026-07-17 10:17:26'),('20b6556a-873e-472e-9348-eda5097f1dd6','Pushups','train','a1111111-1111-4111-8111-111111111104','A classic upper body exercise for chest, triceps, and shoulders.','','','/uploads/file-1782127623927-361078430.csv','intermediate','[\"Chest\", \"Triceps\", \"Shoulders\"]','{\"body_straight\": true, \"hand_placement\": \"shoulder_width\", \"min_elbow_angle\": 70}','{\"state_a\": \"high_plank\", \"state_b\": \"low_plank\", \"threshold\": 0.5}',NULL,0,0,'2026-05-15 19:07:05','2026-07-04 22:22:10'),('32d3d42f-e926-4904-a550-d49fa7bdaf62','Chest Press','train','6da8d40c-c82c-412e-acc3-6a749cce7004','Starting Position\nLie flat on a bench.\nHold a dumbbell in each hand.\nPosition the dumbbells at chest level.\nKeep your feet flat on the floor.\nEngage your core.\nMovement\nPress the dumbbells upward until your arms are almost straight.\nSqueeze your chest at the top.\nSlowly lower the weights back to chest level.\nRepeat.','','/uploads/gif-1782142263361-221652714.gif','/uploads/file-1782134471794-355134312.csv','beginner','[]','{}','{}',NULL,1,0,'2026-06-22 13:21:50','2026-07-17 09:27:10'),('36977cbc-7ae7-4d27-beb0-e2d2889126c1','Squats','train','6da8d40c-c82c-412e-acc3-6a749cce7004','A fundamental lower body exercise that targets the quads, glutes, and hamstrings.','','/uploads/gif-1782143283548-595003656.gif','/uploads/file-1782127672702-307990092.csv','advanced','[\"Quads\", \"Glutes\", \"Hamstrings\"]','{\"heel_contact\": true, \"max_back_lean\": 30, \"knee_alignment\": \"toes\"}','{\"state_a\": \"standing\", \"state_b\": \"deep_squat\", \"min_depth\": 90}',NULL,1,0,'2026-05-15 19:07:05','2026-07-17 09:24:53'),('3a52c682-5111-4698-8ffa-45d70b004522','Plank','train','a1111111-1111-4111-8111-111111111103','Isometric core exercise for stability and endurance.','https://assets.formforge.ai/exercises/plank.mp4','/uploads/gif-1782141744671-987963904.gif','/uploads/file-1782127470160-60515610.csv','intermediate','[\"Abs\", \"Lower Back\", \"Shoulders\"]','{\"time_based\": true, \"back_flatness\": 0.9, \"hip_height_threshold\": 0.2}','{\"type\": \"duration\", \"unit\": \"seconds\", \"min_hold\": 30}',NULL,1,0,'2026-05-15 19:07:05','2026-07-17 09:23:41'),('4ad754fd-05c7-448c-8c33-9d089ad454ad','Single Leg Squat','train','a1111111-1111-4111-8111-111111111104','Instructions:\n\nStand upright with your feet hip-width apart.\nShift your weight onto one leg and lift the opposite foot slightly off the ground in front of you.\nEngage your core and keep your chest up.\nSlowly bend the knee of the standing leg and push your hips back as you lower into a squat.\nLower as far as you can while maintaining balance and proper form.\nKeep the standing knee aligned with your toes throughout the movement.\nPush through the heel of the working leg to return to the starting position.\nComplete the desired number of repetitions, then switch legs.\n\nTips:\n\nKeep your chest lifted and back neutral throughout the exercise.\nAvoid letting the knee collapse inward.\nUse a controlled tempo and focus on balance.\nExtend your arms forward for additional stability if needed.\nReduce the depth or use a support if you are new to the movement.','','/uploads/gif-1782206065875-442888218.gif','/uploads/file-1782206043804-738160371.csv','intermediate','[\"Quadriceps\", \"Gluteus Maximus\", \"Hamstrings\", \"Gluteus Medius,\", \"Core Stabilizers\"]','{}','{}',NULL,1,0,'2026-06-23 09:15:42','2026-07-04 22:22:10'),('509880db-396c-428e-908c-59e76e79152b','Triceps','play','6da8d40c-c82c-412e-acc3-6a749cce7004','Stand facing a cable machine.\nGrab the rope or straight bar.\nKeep elbows close to your sides.\nPush the handle down until arms are fully extended.\nSlowly return to the starting position.\n\nSets/Reps: 3–4 sets × 10–15 reps','','/uploads/gif-1782141668413-496017896.gif','/uploads/file-1782131944826-240611510.csv','advanced','[\"Triceps\"]','{}','{}',NULL,1,0,'2026-06-22 12:40:49','2026-07-17 09:27:12'),('559bfc32-4d6b-4a8e-aad3-c465f89d13e0','Lunges','train','a1111111-1111-4111-8111-111111111102','Unilateral lower body exercise for balance and strength.','','/uploads/gif-1782127080318-48138396.gif','/uploads/file-1782126754822-722704296.csv','beginner','[\"Quads\", \"Glutes\", \"Hip Flexors\"]','{\"torso_upright\": true, \"knee_angle_front\": 90, \"balance_stability\": 0.8}','{\"alternating\": true, \"count_per_leg\": true}',NULL,1,0,'2026-05-15 19:07:05','2026-07-17 09:28:21'),('578b3dbd-dad4-40f2-a363-ae50b52cdd52','Lunges','train','6da8d40c-c82c-412e-acc3-6a749cce7004','Unilateral lower body exercise for balance and strength.','','','','beginner','[\"Quads\", \"Glutes\", \"Hip Flexors\"]','{\"torso_upright\": true, \"knee_angle_front\": 90, \"balance_stability\": 0.8}','{\"alternating\": true, \"count_per_leg\": true}',NULL,1,0,'2026-05-12 08:20:03','2026-07-17 09:27:21'),('58134982-b74b-4599-87b0-31e28dbe5996','Biceps curl','train','6da8d40c-c82c-412e-acc3-6a749cce7004','Starting Position\nStand with feet shoulder-width apart.\nHold a dumbbell in each hand.\nLet your arms hang at your sides.\nKeep palms facing forward.\nMovement\nKeep your elbows close to your body.\nCurl the dumbbells toward your shoulders.\nSqueeze your biceps at the top.\nSlowly lower the weights back down.\nRepeat.','','/uploads/gif-1782198971545-353974622.gif','/uploads/file-1782136312845-186440230.csv','intermediate','[]','{}','{}',NULL,1,0,'2026-06-22 13:52:49','2026-07-17 09:25:20'),('58af8f17-6402-4ea7-9365-0384b70fb1e7','Burpees','train','4c7931f4-49ef-4053-bd78-d90b2b21b54e','How to perform a burpee:\n\nStart standing with your feet shoulder-width apart.\nSquat down and place your hands on the floor in front of you.\nJump your feet back into a plank position.\n(Optional) Perform a push-up.\nJump your feet back toward your hands.\nExplosively jump upward with your arms raised overhead.\nLand softly and repeat.','','/uploads/gif-1784307870020-686707794.gif','/uploads/file-1784305838567-170318514.csv','beginner','[\"Quadriceps\"]','{}','{}',NULL,1,0,'2026-07-17 16:33:32','2026-07-17 17:09:09'),('6387ae2e-1272-4a17-b263-475dd4f8e562','Biceps','train','6da8d40c-c82c-412e-acc3-6a749cce7004','Stand upright holding dumbbells at your sides.\nKeep elbows close to your body.\nCurl the weights toward your shoulders.\nSqueeze your biceps at the top.\nLower slowly.\n\n3–4 sets × 10–12 reps','','/uploads/gif-1782142574741-406175671.gif','/uploads/file-1782136228623-353341038.csv','beginner','[\"muscles\"]','{}','{}',NULL,1,0,'2026-06-22 13:51:38','2026-07-17 09:27:07'),('6416caa0-ea2f-43a9-98f6-891ac72fcb22','Mountain Climber','train','18a16f69-3cf4-47cd-adbb-9eb9917f2193','How to Perform\nStart in a high plank position with your hands directly under your shoulders and your body forming a straight line from head to heels.\nEngage your core and keep your hips level.\nDrive one knee toward your chest without lifting your hips.\nQuickly switch legs by extending the first leg back while bringing the opposite knee toward your chest.\nContinue alternating legs in a smooth, controlled, running motion.\nMaintain a steady pace while keeping your core tight and your back flat.','','','/uploads/file-1784546821084-137444806.csv','beginner','[\"Rectus abdominis (abdominals)\", \"Transverse abdominis\", \"Obliques\"]','{}','{}',NULL,0,0,'2026-07-20 11:41:53','2026-07-20 11:56:30'),('69a3e913-9c45-4e9b-94aa-e2a6773bbbd8','Bend Over Row','train','6da8d40c-c82c-412e-acc3-6a749cce7004','Stand with your feet about shoulder-width apart.\nHold a barbell (or a pair of dumbbells) with your hands slightly wider than shoulder-width apart.\nHinge at your hips until your torso is roughly 30–45 degrees above parallel to the floor. Keep your back flat, chest up, and core braced.\nLet the weight hang with your arms fully extended.\nPull the weight toward your lower chest or upper abdomen by driving your elbows backward.\nSqueeze your shoulder blades together at the top of the movement.\nLower the weight slowly and under control until your arms are fully extended.\nRepeat for the desired number of repetitions.','','/uploads/gif-1784302354377-101051055.gif','/uploads/file-1784302049983-913769372.csv','beginner','[\"Latissimus dorsi (lats)\"]','{}','{}',NULL,1,0,'2026-07-17 15:32:53','2026-07-17 15:32:53'),('7e0ae5f4-75c3-4ba0-8224-5472d9667281','Glute Activation','train','a1111111-1111-4111-8111-111111111102','Quick Standing Glute Activation Routine (3–5 Minutes)\nStanding Kickbacks – 15 reps/leg\nStanding Hip Abductions – 15 reps/leg\nBanded Lateral Walks – 10 steps each way\nDiagonal Kickbacks – 15 reps/leg\n\nRepeat 2 rounds before squats, lunges, or lower-body workouts.','','/uploads/gif-1782142303484-212172025.gif','/uploads/file-1782133892419-498106602.csv','advanced','[]','{}','{}',NULL,0,0,'2026-06-22 13:13:04','2026-07-17 09:28:21'),('8459a4e2-4873-11f1-b0b5-c8f7503f9a48','Standard Squat','train','a1111111-1111-4111-8111-111111111104','Keep your feet shoulder-width apart. Lower your hips as if sitting in a chair, keeping your chest up and back straight.','https://assets.formforge.ai/exercises/squat.mp4',NULL,NULL,'beginner','[\"Quads\", \"Glutes\", \"Hamstrings\"]','{\"heel_contact\": true, \"max_back_lean\": 30, \"min_knee_angle\": 90}','{\"state_a\": \"standing\", \"state_b\": \"descending\", \"state_c\": \"squat_point\", \"threshold\": 100}',NULL,0,0,'2026-05-05 11:14:00','2026-07-04 22:22:10'),('845ac1ed-4873-11f1-b0b5-c8f7503f9a48','Push-up','train','a1111111-1111-4111-8111-111111111104','Start in a plank position. Lower your body until your chest nearly touches the floor, then push back up.','https://assets.formforge.ai/exercises/pushup.mp4',NULL,'/uploads/file-1778576693395-205117979.xlsx','beginner','[\"Chest\", \"Triceps\", \"Shoulders\"]','{\"min_elbow_angle\": 70, \"body_straightness_threshold\": 165}','{\"state_a\": \"high_plank\", \"state_b\": \"lowering\", \"state_c\": \"bottom_point\"}',NULL,0,0,'2026-05-05 11:14:00','2026-07-04 22:22:10'),('845ac8f8-4873-11f1-b0b5-c8f7503f9a48','Walking Lunge','train','a1111111-1111-4111-8111-111111111104','Step forward with one leg and lower your hips until both knees are bent at a 90-degree angle.','https://assets.formforge.ai/exercises/lunge.mp4',NULL,NULL,'intermediate','[\"Quads\", \"Glutes\", \"Hip Flexors\"]','{\"balance_stability\": 0.8, \"knee_angle_target\": 90}','{\"count_per_leg\": true}',NULL,0,0,'2026-05-05 11:14:00','2026-07-04 22:22:10'),('845ad01f-4873-11f1-b0b5-c8f7503f9a48','Plank','train','a1111111-1111-4111-8111-111111111104','Isometric core exercise for stability and endurance.','https://assets.formforge.ai/exercises/plank.mp4',NULL,NULL,'intermediate','[\"Abs\", \"Lower Back\", \"Shoulders\"]','{\"time_based\": true, \"back_flatness\": 0.9, \"hip_height_threshold\": 0.2}','{\"type\": \"duration\", \"unit\": \"seconds\", \"min_hold\": 30}',NULL,0,0,'2026-05-05 11:14:00','2026-07-04 22:22:10'),('86dc75ba-4bb2-446a-a9aa-27d044209d19','Squats','train','a1111111-1111-4111-8111-111111111104','A fundamental lower body exercise that targets the quads, glutes, and hamstrings.',NULL,NULL,NULL,'beginner','[\"Quads\", \"Glutes\", \"Hamstrings\"]','{\"heel_contact\": true, \"max_back_lean\": 30, \"knee_alignment\": \"toes\"}','{\"state_a\": \"standing\", \"state_b\": \"deep_squat\", \"min_depth\": 90}',NULL,0,0,'2026-05-12 08:20:02','2026-07-04 22:22:10'),('888594f4-f2ca-4038-b088-d8b4da1212e8','Dead Lift ','train','6da8d40c-c82c-412e-acc3-6a749cce7004','Stand with feet hip-width apart.\nPosition the bar over the middle of your feet.\nBend at the hips and knees to grip the bar.\nKeep your chest up and back neutral.\nEngage your core and lats.\nLift\nPush through your heels.\nExtend your knees and hips together.\nKeep the bar close to your body.\nStand tall and squeeze your glutes at the top.\nLowering\nPush your hips back first.\nLower the bar along your legs.\nBend your knees once the bar passes them.\nReturn the bar to the floor under control.','','/uploads/gif-1782142468340-143550773.gif','/uploads/file-1782134005870-489885602.csv','advanced','[\"Back\"]','{}','{}',NULL,1,0,'2026-06-22 13:14:37','2026-07-17 09:25:00'),('91e2855e-508c-11f1-b0fc-00163c1e51d8','Standard Squat','train','a1111111-1111-4111-8111-111111111104','Keep your feet shoulder-width apart. Lower your hips as if sitting in a chair, keeping your chest up and back straight.','https://assets.formforge.ai/exercises/squat.mp4','','','beginner','[\"Quads\", \"Glutes\", \"Hamstrings\"]','{\"heel_contact\": true, \"max_back_lean\": 30, \"min_knee_angle\": 90}','{\"state_a\": \"standing\", \"state_b\": \"descending\", \"state_c\": \"squat_point\", \"threshold\": 100}',NULL,0,0,'2026-05-15 18:33:29','2026-07-04 22:22:10'),('91e28b7f-508c-11f1-b0fc-00163c1e51d8','Push-up','train','a1111111-1111-4111-8111-111111111104','Start in a plank position. Lower your body until your chest nearly touches the floor, then push back up.','https://assets.formforge.ai/exercises/pushup.mp4','','','beginner','[\"Chest\", \"Triceps\", \"Shoulders\"]','{\"min_elbow_angle\": 70, \"body_straightness_threshold\": 165}','{\"state_a\": \"high_plank\", \"state_b\": \"lowering\", \"state_c\": \"bottom_point\"}',NULL,0,0,'2026-05-15 18:33:29','2026-07-04 22:22:10'),('91e28d70-508c-11f1-b0fc-00163c1e51d8','Walking Lunge','train','a1111111-1111-4111-8111-111111111104','Step forward with one leg and lower your hips until both knees are bent at a 90-degree angle.','https://assets.formforge.ai/exercises/lunge.mp4',NULL,NULL,'intermediate','[\"Quads\", \"Glutes\", \"Hip Flexors\"]','{\"balance_stability\": 0.8, \"knee_angle_target\": 90}','{\"count_per_leg\": true}',NULL,0,0,'2026-05-15 18:33:29','2026-07-04 22:22:10'),('91e28e13-508c-11f1-b0fc-00163c1e51d8','Plank','train','a1111111-1111-4111-8111-111111111104','Maintain a straight line from head to heels while resting on your forearms and toes.','https://assets.formforge.ai/exercises/plank.mp4',NULL,NULL,'beginner','[\"Abs\", \"Lower Back\", \"Shoulders\"]','{\"time_based\": true, \"hip_height_threshold\": \"aligned\"}','{\"type\": \"duration\", \"unit\": \"seconds\"}',NULL,0,0,'2026-05-15 18:33:29','2026-07-04 22:22:10'),('94f19831-9b37-40ac-8129-5aa2ce7ec0aa','Push-up','train','6da8d40c-c82c-412e-acc3-6a749cce7004','Start in a plank position. Lower your body until your chest nearly touches the floor, then push back up.','https://assets.formforge.ai/exercises/pushup.mp4','/uploads/gif-1782142895672-914577791.gif','/uploads/file-1782127569339-204353954.csv','beginner','[\"Chest\", \"Triceps\", \"Shoulders\"]','{\"min_elbow_angle\": 70, \"body_straightness_threshold\": 165}','{\"state_a\": \"high_plank\", \"state_b\": \"lowering\", \"state_c\": \"bottom_point\"}',NULL,1,0,'2026-05-15 19:07:05','2026-07-17 09:27:15'),('99d8f3fd-9dcb-4a36-b373-62f7b61c1820','Single Leg Calf','train','a1111111-1111-4111-8111-111111111104','Stand on one leg on a step or flat floor. Hold a wall or chair for balance.\nLift the other foot off the ground (bend knee, foot behind standing leg).\nLower the heel of your standing foot slowly until you feel a stretch in the calf. Don’t slam the heel down.\nPush up through the ball of your foot and rise onto your toes as high as you can.\nSqueeze the calf at the top for 1–2 seconds.\nLower back down with control.\nDo 15–20 reps, then switch legs.','','/uploads/gif-1782129911348-323882838.gif','/uploads/file-1782131082050-109746432.csv','advanced','[\"Gastrocnemius\", \"Soleus\", \"Tibialis anterior\", \"Gluteus medius\", \"Core (abdominals)\"]','{}','{}',NULL,1,0,'2026-06-22 12:08:30','2026-07-04 22:22:10'),('9ea6ee94-da2c-4bcf-b586-8e0e8fb781d5','Pushups','train','a1111111-1111-4111-8111-111111111104','A classic upper body exercise for chest, triceps, and shoulders.','',NULL,'/uploads/file-1778576614070-711236569.xlsx','intermediate','[\"Chest\", \"Triceps\", \"Shoulders\"]','{\"body_straight\": true, \"hand_placement\": \"shoulder_width\", \"min_elbow_angle\": 70}','{\"state_a\": \"high_plank\", \"state_b\": \"low_plank\", \"threshold\": 0.5}',NULL,0,0,'2026-05-12 08:20:03','2026-07-04 22:22:10'),('ab1a0dfb-77cd-4c2f-93b3-9c10b6aef938','Jumping Jack','train','6da8d40c-c82c-412e-acc3-6a749cce7004','Instructions:\n\nStand upright with your feet together and arms resting at your sides.\nJump your feet outward to about shoulder-width or wider while simultaneously raising your arms overhead.\nLand softly on the balls of your feet with your knees slightly bent.\nQuickly jump back to the starting position, bringing your feet together and lowering your arms to your sides.\nContinue the movement in a smooth, rhythmic manner for the desired number of repetitions or duration.\n\nTips:\n\nMaintain an upright posture throughout the exercise.\nLand softly to reduce impact on your joints.\nKeep your core engaged to support proper body alignment.\nCoordinate your arm and leg movements for a smooth rhythm.\nBreathe naturally and maintain a steady pace.','','/uploads/gif-1782218384850-73331732.gif','/uploads/file-1782217356958-10780086.csv','beginner','[\"Quadriceps\", \"Glutes\", \"Calves\", \"Deltoids\", \"Hamstrings\", \", Hip Flexors, Core Stabilizers\"]','{}','{}',NULL,0,0,'2026-06-23 12:22:56','2026-07-17 09:27:01'),('b0da526b-8ec4-4246-a545-7a71b12c409c','Frozen Shoulder Rehab','recover','6da8d40c-c82c-412e-acc3-6a749cce7004','','','','','intermediate','[]','{}','{}',NULL,0,0,'2026-07-03 14:25:14','2026-07-17 09:26:54'),('b3eefecf-4962-4522-af3e-0eae954ef892','Mountain Climber','train','18a16f69-3cf4-47cd-adbb-9eb9917f2193','How to Perform\nStart in a high plank position with your hands directly under your shoulders and your body forming a straight line from head to heels.\nEngage your core and keep your hips level.\nDrive one knee toward your chest without lifting your hips.\nQuickly switch legs by extending the first leg back while bringing the opposite knee toward your chest.\nContinue alternating legs in a smooth, controlled, running motion.\nMaintain a steady pace while keeping your core tight and your back flat.','','/uploads/gif-1784549894213-917078869.gif','/uploads/file-1784546821084-137444806.csv','beginner','[\"Rectus abdominis (abdominals)\", \"Transverse abdominis\", \"Obliques\"]','{}','{}',NULL,1,0,'2026-07-20 11:41:53','2026-07-20 12:18:24'),('c144ba27-8353-4411-b80f-a56747999111','Pike Push','train','a1111111-1111-4111-8111-111111111104','Instructions:\n\nStart in a push-up position with your hands slightly wider than shoulder-width apart.\nLift your hips toward the ceiling to form an inverted \"V\" shape with your body.\nKeep your legs as straight as comfortably possible and your core engaged.\nBend your elbows and lower your head toward the floor between your hands.\nContinue lowering until your head is just above the ground.\nPress through your palms and straighten your arms to return to the starting position.\nRepeat for the desired number of repetitions.\n\nTips:\n\nKeep your core tight and maintain the pike position throughout the movement.\nFocus on lowering your head between your hands rather than forward.\nAvoid flaring your elbows excessively.\nMove slowly and with control to maximize shoulder engagement.\nAdjust your foot position closer to your hands to increase shoulder emphasis.','','/uploads/gif-1782214777203-544587844.gif','/uploads/file-1782214709037-375976969.csv','intermediate','[\"Anterior Deltoids\", \"Medial Deltoids\", \"Triceps\", \"Upper Chest\", \"Serratus Anterior,\"]','{}','{}',NULL,1,0,'2026-06-23 11:39:43','2026-07-04 22:22:10'),('c421248c-706c-46fe-b73e-d016937bfdfa','Dumbell Crunches ','train','a1111111-1111-4111-8111-111111111104','Instructions:\n\nLie on your back on an exercise mat with your knees bent and feet flat on the floor.\nHold a dumbbell securely against your chest or just above your chest with both hands.\nEngage your core and keep your lower back in contact with the floor.\nLift your head, shoulders, and upper back off the ground by contracting your abdominal muscles.\nPause briefly at the top and squeeze your abs.\nSlowly lower your upper body back to the starting position in a controlled manner.\nRepeat for the desired number of repetitions.\n\nTips:\n\nKeep the movement slow and controlled; avoid using momentum.\nFocus on lifting with your abdominal muscles rather than pulling with your neck.\nKeep your chin slightly tucked and your neck relaxed.\nExhale as you crunch upward and inhale as you lower down.\nChoose a weight that allows proper form throughout the set.','','/uploads/gif-1782211699197-67269547.gif','/uploads/file-1782211708472-101393995.csv','intermediate','[\"Rectus Abdominis\", \"Obliques\", \"Transverse Abdominis\", \"Hip Flexors\"]','{}','{}',NULL,1,0,'2026-06-23 10:48:32','2026-07-04 22:22:10'),('c904f0ae-bbfd-449d-8eee-7f359fd53561','Mountain Climber','train','18a16f69-3cf4-47cd-adbb-9eb9917f2193','How to Perform\nStart in a high plank position with your hands directly under your shoulders and your body forming a straight line from head to heels.\nEngage your core and keep your hips level.\nDrive one knee toward your chest without lifting your hips.\nQuickly switch legs by extending the first leg back while bringing the opposite knee toward your chest.\nContinue alternating legs in a smooth, controlled, running motion.\nMaintain a steady pace while keeping your core tight and your back flat.','','','/uploads/file-1784546821084-137444806.csv','beginner','[\"Rectus abdominis (abdominals)\", \"Transverse abdominis\", \"Obliques\"]','{}','{}',NULL,0,0,'2026-07-20 11:41:53','2026-07-20 11:56:32'),('d6fff728-939a-4358-a2fd-27b21298fb70','Mountain Climber','train','18a16f69-3cf4-47cd-adbb-9eb9917f2193','How to Perform\nStart in a high plank position with your hands directly under your shoulders and your body forming a straight line from head to heels.\nEngage your core and keep your hips level.\nDrive one knee toward your chest without lifting your hips.\nQuickly switch legs by extending the first leg back while bringing the opposite knee toward your chest.\nContinue alternating legs in a smooth, controlled, running motion.\nMaintain a steady pace while keeping your core tight and your back flat.','','','/uploads/file-1784546821084-137444806.csv','beginner','[\"Rectus abdominis (abdominals)\", \"Transverse abdominis\", \"Obliques\"]','{}','{}',NULL,0,0,'2026-07-20 11:41:53','2026-07-20 11:56:32'),('e27c9e80-2eff-45c5-83df-993abb888df5','Shoulder Press','train','6da8d40c-c82c-412e-acc3-6a749cce7004','Starting Position\nSit on a bench with back support or stand upright.\nHold a dumbbell in each hand at shoulder level.\nPalms should face forward.\nKeep your chest up and core tight.\nMovement\nPress the dumbbells upward until your arms are almost fully extended.\nDo not lock your elbows aggressively.\nPause briefly at the top.\nSlowly lower the weights back to shoulder level.\nRepeat.','','/uploads/gif-1782142856652-124768764.gif','/uploads/file-1782133772421-272351192.csv','beginner','[\"shoulder\"]','{}','{}',NULL,1,0,'2026-06-22 13:10:31','2026-07-17 09:25:09'),('e887b6ad-5648-4699-8911-313e6b84187c','Mountain Climber','train','4c7931f4-49ef-4053-bd78-d90b2b21b54e','How to Perform\nStart in a high plank position with your hands directly under your shoulders and your body forming a straight line from head to heels.\nEngage your core and keep your hips level.\nDrive one knee toward your chest without lifting your hips.\nQuickly switch legs by extending the first leg back while bringing the opposite knee toward your chest.\nContinue alternating legs in a smooth, controlled, running motion.\nMaintain a steady pace while keeping your core tight and your back flat.','','','/uploads/file-1784546821084-137444806.csv','beginner','[\"Rectus abdominis (abdominals)\", \"Transverse abdominis\", \"Obliques\"]','{}','{}',NULL,0,0,'2026-07-20 11:41:53','2026-07-20 11:56:33'),('ed5b0bfb-5098-4f1e-a811-e4f01bec9e76','Butt Kick','train','4c7931f4-49ef-4053-bd78-d90b2b21b54e','Butt Kicks are a dynamic cardio exercise that involves jogging in place while kicking your heels up toward your glutes. Commonly used as a warm-up or conditioning exercise, butt kicks improve cardiovascular endurance, increase lower-body mobility, and prepare the muscles for running and other athletic activities.\n\nHow to Perform\nStand upright with your feet hip-width apart and your arms at your sides.\nBegin jogging in place at a comfortable pace.\nLift one heel toward your glutes while keeping your thigh pointing downward.\nAlternate legs quickly, aiming to kick your heels toward your buttocks with each step.\nSwing your arms naturally in coordination with your legs.\nLand softly on the balls of your feet and maintain a steady, rhythmic pace.','','/uploads/gif-1784550810961-609308537.gif','/uploads/file-1784550536647-145421275.csv','beginner','[\"Hamstrings\", \"Calves (gastrocnemius and soleus)\"]','{}','{}',NULL,1,0,'2026-07-20 12:29:44','2026-07-20 12:35:17'),('eeefad65-8dc5-4b90-b29d-3527d4294555','Walking Lunge','train','a1111111-1111-4111-8111-111111111102','Step forward with one leg and lower your hips until both knees are bent at a 90-degree angle.','https://assets.formforge.ai/exercises/lunge.mp4','/uploads/gif-1782143386361-891558121.gif','/uploads/file-1782127701820-768128256.csv','intermediate','[\"Quads\", \"Glutes\", \"Hip Flexors\"]','{\"balance_stability\": 0.8, \"knee_angle_target\": 90}','{\"count_per_leg\": true}',NULL,1,0,'2026-05-15 19:07:05','2026-07-17 09:28:21'),('f1835dd1-98b9-492f-acbd-1e52b4216496','Frozen Shoulder Rehab','recover','6da8d40c-c82c-412e-acc3-6a749cce7004','Frozen Shoulder Rehab is a gentle mobility exercise designed to reduce shoulder stiffness, improve range of motion, and gradually restore normal shoulder function. Perform each movement slowly and within a comfortable, pain-free range. Focus on controlled motion rather than stretching forcefully.\n\nTips\nKeep your shoulders relaxed and avoid shrugging.\nMove slowly and smoothly without jerking.\nStay within a comfortable range of motion—mild stretching is okay, but stop if you feel sharp pain.\nMaintain an upright posture throughout the exercise.\nBreathe normally and avoid holding your breath.\nPerform the movements consistently to improve flexibility over time.\nDo not force the shoulder beyond its current mobility.\nIf pain increases significantly or persists after exercising, reduce the range of motion or consult a healthcare professional.','','','','intermediate','[]','{}','{}',NULL,0,0,'2026-07-03 14:27:05','2026-07-17 09:26:51'),('f3922cdc-a715-4382-9d1b-4f58a3c5f249','Knee Rehab','train','deba510b-2415-4680-913c-42dcab1a8ba7','Description\nStrengthen the muscles that support your knee while improving stability, flexibility, and range of motion. These controlled, low-impact movements are designed to aid recovery, reduce discomfort, and help restore normal knee function. Perform each repetition slowly and with proper form, avoiding any movement that causes sharp pain.\n\nInstructions\n\nStand or sit in the recommended starting position.\nKeep your core engaged and maintain good posture.\nMove your knee through the prescribed range of motion in a slow, controlled manner.\nAvoid locking or twisting the knee unless instructed.\nReturn to the starting position smoothly.\nBreathe steadily throughout the exercise.\nStop immediately if you experience sharp pain, swelling, or instability.\n\nTips\n\nPerform movements slowly and under control.\nFocus on quality of movement rather than speed.\nKeep the knee aligned with your toes during standing exercises.\nUse support (such as a chair or wall) if needed for balance.\nComplete only the recommended number of repetitions.\n\nBenefits\n\nImproves knee strength and stability\nIncreases joint mobility and flexibility\nSupports injury recovery and rehabilitation\nEnhances balance and coordination\nReduces the risk of future knee injuries','','','/uploads/file-1783083861649-17170968.csv','beginner','[\"knee\"]','{}','{}',NULL,1,0,'2026-07-03 13:05:06','2026-07-17 09:31:19'),('f605d35a-0751-4d09-9a60-8a9cbf138a08','Lower Back Mobality','recover','cb013234-6019-4189-8c63-bef7c740d52d','Instructions\n\nBegin in the recommended starting position with your spine in a neutral alignment.\nEngage your core muscles to support your lower back.\nMove slowly through the full, comfortable range of motion.\nAvoid sudden or jerky movements.\nBreathe steadily throughout the exercise.\nReturn to the starting position with control.\nStop if you experience sharp pain, numbness, or increased discomfort.\n\nTips\n\nPerform each repetition slowly and with control.\nKeep movements smooth and pain-free.\nAvoid overstretching beyond your comfortable range.\nFocus on maintaining proper posture throughout the exercise.\nMove with your breath to help relax the muscles.\n\nBenefits\n\nIncreases lower back mobility and flexibility\nReduces stiffness and muscle tightness\nImproves spinal movement and posture\nSupports core stability and functional movement\nHelps reduce the risk of lower back discomfort and injury','','','/uploads/file-1783086443793-746685918.csv','intermediate','[\"back\"]','{}','{}',NULL,1,0,'2026-07-03 13:47:30','2026-07-17 09:30:54'),('f68763ea-aae8-4a0d-8559-5b3ee922f07b','Jumping Jack','train','6da8d40c-c82c-412e-acc3-6a749cce7004','Instructions:\n\nStand upright with your feet together and arms resting at your sides.\nJump your feet outward to about shoulder-width or wider while simultaneously raising your arms overhead.\nLand softly on the balls of your feet with your knees slightly bent.\nQuickly jump back to the starting position, bringing your feet together and lowering your arms to your sides.\nContinue the movement in a smooth, rhythmic manner for the desired number of repetitions or duration.\n\nTips:\n\nMaintain an upright posture throughout the exercise.\nLand softly to reduce impact on your joints.\nKeep your core engaged to support proper body alignment.\nCoordinate your arm and leg movements for a smooth rhythm.\nBreathe naturally and maintain a steady pace.','','/uploads/gif-1782218620681-211070904.gif','/uploads/file-1782217356958-10780086.csv','beginner','[\"Quadriceps\", \"Glutes\", \"Calves\", \"Deltoids\", \"Hamstrings\", \", Hip Flexors, Core Stabilizers\"]','{}','{}',NULL,1,0,'2026-06-23 12:22:56','2026-07-17 09:28:04');
/*!40000 ALTER TABLE `exercises` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` char(36) NOT NULL,
  `recipient_user_id` char(36) NOT NULL COMMENT 'Admin user who sees this row',
  `type` varchar(64) NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text,
  `metadata` json DEFAULT NULL,
  `read_at` datetime DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_notifications_recipient_unread` (`recipient_user_id`,`read_at`),
  KEY `idx_notifications_recipient_created` (`recipient_user_id`,`createdAt`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`recipient_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profiles`
--

DROP TABLE IF EXISTS `profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `profiles` (
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
  `preferred_language` varchar(10) DEFAULT 'en',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `longest_streak` int DEFAULT '0',
  `last_streak_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profiles`
--

LOCK TABLES `profiles` WRITE;
/*!40000 ALTER TABLE `profiles` DISABLE KEYS */;
INSERT INTO `profiles` VALUES ('0919a104-525b-4dfd-b2dd-f70e2c198712','49f86a6b-ba79-436f-9895-a64f4735b5f4','Hamdan Mansoor','https://lh3.googleusercontent.com/a/ACg8ocJeEjoJkBAeLtFT_0MVLUvFQfgOK_5KhEDoxfz2XLOwKo00BMEv=s1337',11,'advanced','Build muscle',NULL,849,1,1,'English','2026-06-17 13:24:17','2026-07-20 11:49:16',1,'2026-07-20'),('17c2c8e0-8eb3-4e92-941f-2aa9286bcabe','36c6331c-2099-489c-bf60-f02c39d66fc3','abccc@xcn.xom',NULL,NULL,'advanced','Lose weight',NULL,0,1,0,'English','2026-07-02 07:22:50','2026-07-02 07:23:23',0,NULL),('1acd7d00-1cc6-4455-891f-0ecd85d27c08','eec74c80-8802-4d81-9229-00d8c15e04c9','testinge@wel.com',NULL,NULL,'intermediate','Lose weight',NULL,0,1,0,'English','2026-06-30 06:33:23','2026-06-30 06:33:37',0,NULL),('1b99027c-a2ca-4644-9fe2-d1cc51fd63d9','c4f8df19-b40d-4318-879e-08a165f35cea','james@jack.com',NULL,NULL,'beginner','Lose weight',NULL,0,1,0,'English','2026-07-02 11:13:24','2026-07-02 11:13:49',0,NULL),('1ea59851-dcd5-4164-adfb-e4b6c6f3c80d','a90f00ba-5259-4380-94ee-42e764b7fb9e',NULL,NULL,NULL,'beginner',NULL,NULL,0,1,0,'en','2026-07-02 06:55:23','2026-07-02 06:55:23',0,NULL),('2c5207a0-46cf-4b62-add7-e0d72e93681d','48dedfb8-cad7-4c5e-8587-e79daec3b201',NULL,NULL,NULL,'beginner',NULL,NULL,0,1,0,'en','2026-07-02 08:58:24','2026-07-02 08:58:24',0,NULL),('2d94c61c-e076-4740-a215-0b1dec54e954','9436a3d9-54ba-4dba-8793-90a45ed999f4','aaaa',NULL,NULL,'intermediate','Lose weight',NULL,183,1,1,'English','2026-07-03 05:12:31','2026-07-10 10:52:29',1,'2026-07-10'),('2e1e8865-94b9-4578-9cf1-303e21286deb','2b831991-3d20-4dd4-8864-21e813f51617','hamdann@gmail.com',NULL,55,'intermediate','Lose weight',NULL,1273,1,1,'English','2026-06-18 09:24:53','2026-06-26 14:33:44',1,'2026-06-26'),('3297befe-9ab4-44e5-bd42-aeedfe54a7de','95b18071-b853-4d70-b37f-fe26286ef025',NULL,NULL,NULL,'beginner',NULL,NULL,0,1,0,'en','2026-07-14 14:37:13','2026-07-14 14:37:13',0,NULL),('35ba953e-cc69-4400-bffe-6eeb2e7d5d0c','54d44b92-0af3-4a2d-b3aa-89fc15cb764b','abcc@cvb.com',NULL,NULL,'intermediate','Lose weight',NULL,104,1,1,'English','2026-07-02 07:39:58','2026-07-02 07:40:33',1,'2026-07-02'),('3ec472c8-e2b5-4b34-a7ee-26d6fc8d02d7','c32682d0-27dc-4072-959f-dd888e925bd4',NULL,NULL,NULL,'beginner',NULL,NULL,0,1,0,'en','2026-07-06 07:44:15','2026-07-06 07:44:15',0,NULL),('460319e4-4892-4dcd-9c17-0eb8fe028dcd','71f8f10a-31f8-493c-b221-0edb8e1f47fd',NULL,NULL,NULL,'beginner',NULL,NULL,0,1,0,'en','2026-07-03 07:18:08','2026-07-03 07:18:08',0,NULL),('4c9be6e5-d2a9-4580-92b4-0a169627b6c8','5a90ba96-9815-48bf-b1b5-da33e20826da','agag@2278.com',NULL,NULL,'beginner','Lose weight',NULL,106,1,1,'Arabic','2026-07-02 07:31:05','2026-07-02 07:38:24',1,'2026-07-02'),('51251e60-4b88-415a-9dd0-1385568ef6b6','61522823-cabf-426f-939c-86b4a293d0e7','musmangul99@gmail.com',NULL,NULL,'intermediate','Lose weight',NULL,104,1,1,'English','2026-06-24 21:14:30','2026-06-24 21:16:00',1,'2026-06-24'),('51df32e3-232f-43a8-939a-e2484b43ba77','54b99638-48a6-4167-9987-232e713e6424','hamdan',NULL,22,'intermediate','Lose weight',NULL,0,1,0,'English','2026-06-18 14:14:39','2026-06-18 14:16:01',0,NULL),('55a20134-86b3-4a46-b00e-46734d5b3468','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','HamdanDev','https://lh3.googleusercontent.com/a/ACg8ocLW-nx-80pEGy1tjf700tbGSkayj7qw1S-pkee1-ErtEZ9mnw=s1337',21,'intermediate','Lose weight',NULL,2190,1,1,'English','2026-07-02 11:22:03','2026-07-20 11:40:25',2,'2026-07-20'),('57fe2060-ca6e-44c5-98f9-ebc1caf53b7c','5d40ec0c-fe7f-4b8a-b3bd-36d950868be4','testinge@weol.com',NULL,NULL,'intermediate','Lose weight',NULL,0,1,0,'English','2026-06-30 06:35:30','2026-06-30 06:35:53',0,NULL),('5e7e9479-11be-4a15-9b89-7b6e0f622aa2','e304ca99-06fb-4c5d-818c-48ea20ad3aeb','usama@codesteem.com',NULL,NULL,'beginner','Lose weight',NULL,260,1,1,'English','2026-06-29 07:20:22','2026-06-29 11:18:47',1,'2026-06-29'),('62e64b93-e1b2-4a8c-982d-d8d1e5853b21','0ac73e72-8181-4598-9585-4847c2782f56','testing',NULL,9,'intermediate','Build muscle',NULL,9558,1,1,'English','2026-06-24 19:43:00','2026-07-20 13:07:46',4,'2026-07-20'),('767aa284-6c9d-400b-bb13-8dc854a4b46d','2698e971-2b31-4c49-a815-af0e66ecc0eb','M Usman','https://lh3.googleusercontent.com/a/ACg8ocImLjvATGqyNTYfXlQSLEL_pj2KEeDtdkwGvU7VEXdPjeP3Nw=s1337',NULL,'beginner',NULL,NULL,52,1,1,'en','2026-07-03 17:28:49','2026-07-03 17:37:33',1,'2026-07-03'),('7c7599c3-cf2b-449c-88a6-8737850553a8','0e4c5a12-0a9e-4f6e-9a87-51ea53b17e7d','a1@gmail.com',NULL,NULL,'intermediate','Lose weight',NULL,150,1,1,'English','2026-07-02 07:48:21','2026-07-02 08:43:02',1,'2026-07-02'),('83fee0d6-b28f-4ad5-a812-e0f9bd399ad0','57f22c95-4f57-4726-8baa-82527f96d17d','ali@gmail.com',NULL,NULL,'intermediate','Lose weight',NULL,0,1,0,'English','2026-06-18 10:27:40','2026-06-18 10:27:50',0,NULL),('97dcf897-57c6-4c2d-967f-0c1851153b46','707e8883-6fc2-4be0-84e6-cd24f28bddbd','6yr4r52cg7',NULL,25,'intermediate','Lose weight',NULL,7750,1,2,'English','2026-07-02 13:59:21','2026-07-17 17:01:44',5,'2026-07-17'),('9a43faff-1eed-4b7e-a03c-aa1d313bd22c','367acfa4-0322-45bd-ba6d-4b245b687bbd',NULL,NULL,NULL,'beginner',NULL,NULL,0,1,0,'en','2026-07-02 07:04:43','2026-07-02 07:04:43',0,NULL),('9c42e782-d2f0-46d0-ac87-905e3073733f','829d351c-d2db-417e-8184-748ec074e7d6','usama',NULL,22,'beginner','Lose weight',NULL,135,1,1,'English','2026-07-01 06:33:33','2026-07-01 12:37:13',1,'2026-07-01'),('a217ddad-3d8a-4cb3-b60b-80d566b0a596','3e33c37c-c586-4d5e-b1a1-60bf49076596',NULL,NULL,NULL,'beginner',NULL,NULL,0,1,0,'en','2026-06-29 11:20:41','2026-06-29 11:20:41',0,NULL),('a3c356e3-2081-4ef7-b890-b13dcb7e868a','6862c015-942a-4d82-990a-c602881234b9','ddani@gmail.com',NULL,NULL,'intermediate','Lose weight',NULL,0,1,0,'English','2026-06-29 05:51:59','2026-06-29 05:52:17',0,NULL),('a96f5295-0871-40ee-bdb2-2eeb25c39aed','32ed2c8b-05fa-4335-8a38-95aa69a4b2a6',NULL,NULL,NULL,'beginner',NULL,NULL,0,1,0,'en','2026-07-06 07:51:22','2026-07-06 07:51:22',0,NULL),('aa24957d-692f-4c25-81b7-7d13ffe3f0c5','3455e753-5b9c-4a73-9b8a-cbd8618017d2',NULL,NULL,NULL,'beginner',NULL,NULL,0,1,0,'en','2026-06-17 11:28:00','2026-06-17 11:28:00',0,NULL),('afab8755-30e0-48d2-ad39-2aac4bc7bdd3','7c884423-3d8b-41e5-af18-6666d53ddd99',NULL,NULL,NULL,'beginner',NULL,NULL,0,1,0,'en','2026-07-02 06:53:54','2026-07-02 06:53:54',0,NULL),('ba443a85-cc64-4269-a889-788c5faadf44','269b4dd6-916b-4340-b5e1-2277e5b3ee9f','hamdaan@gmail.com',NULL,NULL,'intermediate','Build muscle',NULL,0,1,0,'English','2026-06-18 14:10:28','2026-06-18 14:10:38',0,NULL),('bb5b8a1c-7787-4f14-95f6-1d81ad831d25','816a6566-7fb0-4a46-a2aa-f17079767586',NULL,NULL,NULL,'beginner',NULL,NULL,0,1,0,'en','2026-07-01 05:41:45','2026-07-01 05:41:45',0,NULL),('bc876015-6275-407e-97dc-01b18e061a4c','0cda18ca-d71c-4f16-b7de-8a998cd390df',NULL,NULL,NULL,'beginner',NULL,NULL,0,1,0,'en','2026-07-06 07:24:55','2026-07-06 07:24:55',0,NULL),('bc9ad094-cfa0-408a-8557-b773b98d4a3f','12437910-ff71-4520-8ee0-225a919720b1','cab@sfj.vom',NULL,NULL,'beginner','Improve form',NULL,0,1,0,'Portuguese','2026-07-02 07:24:24','2026-07-02 07:27:38',0,NULL),('bf674b89-4b9f-4579-826f-f86df0dd1573','9a274228-3432-4fb9-bf8c-6c8ec1beac87','fbasesoftarena83@gmail.com',NULL,NULL,'intermediate','Lose weight',NULL,52,1,1,'English','2026-07-14 14:39:27','2026-07-14 14:57:24',1,'2026-07-14'),('c0adb788-3372-44cc-9c43-127225fd5365','3765bb21-86d4-4faf-8fc7-fde1b1dc48df',NULL,NULL,NULL,'beginner',NULL,NULL,0,1,0,'en','2026-07-02 07:19:40','2026-07-02 07:19:40',0,NULL),('c35664c7-c92b-4917-841f-b8a4af84b903','822e6879-34f9-476a-84fd-fe09dcd60eaa','ttest@gmail.com',NULL,NULL,'intermediate','Lose weight',NULL,0,1,0,'English','2026-06-29 05:53:18','2026-06-29 05:53:27',0,NULL),('c4dd0c6d-70e0-46fa-8c4d-eb9c40278a6b','f46d6ea4-7b74-490a-b74e-e46cddf3cdf8','a3@gmail.com',NULL,NULL,'intermediate','Lose weight',NULL,0,1,0,'English','2026-07-02 07:55:41','2026-07-02 07:55:47',0,NULL),('c5d5dc32-49b6-4df4-83a9-e9b515b2a950','20e70835-5bf1-4e16-9b99-7d1d653737ca','hamdan',NULL,22,'intermediate','Lose weight',NULL,0,1,0,'English','2026-06-18 14:11:59','2026-06-18 14:13:31',0,NULL),('d00ae561-6e87-4b76-ad21-18cd1b4831e9','193ae65d-ea83-485e-9520-16e94fc51b30','hamdann',NULL,11,'intermediate','Lose weight',NULL,0,1,0,'English','2026-06-18 09:18:28','2026-06-18 09:20:23',0,NULL),('d814fb57-c97c-4d0d-9bed-3c94bca31746','01c97de3-e9b2-4220-9e78-5255a1084b39',NULL,NULL,NULL,'beginner',NULL,NULL,0,1,0,'en','2026-07-01 06:26:33','2026-07-01 06:26:33',0,NULL),('e38fc79d-8f0b-441a-be8f-b518faa55308','74e3ae7f-87d6-495b-b81c-05e7d8dc82c4',NULL,NULL,NULL,'beginner',NULL,NULL,0,1,0,'en','2026-07-02 11:20:01','2026-07-02 11:20:01',0,NULL),('e3fd1fa8-9e9d-4567-824e-5ca81d4cd3ea','6ccab45d-b1e2-4e49-9a10-90fa9f07f2d2',NULL,NULL,NULL,'beginner',NULL,NULL,0,1,0,'en','2026-07-02 07:10:52','2026-07-02 07:10:52',0,NULL),('eb8a0fb1-909e-45d6-970a-09f4f450144f','f96faa96-c0d1-48ad-b6e5-28e2220364e2','a2@gmail.com',NULL,NULL,'intermediate','Lose weight',NULL,34,1,1,'English','2026-07-02 07:49:09','2026-07-02 07:51:00',1,'2026-07-02');
/*!40000 ALTER TABLE `profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES (1,'maintenance_mode','false','Enable or disable landing page maintenance mode','2026-05-01 12:42:43','2026-05-01 12:42:43',1),(2,'max_waitlist_spots','10000','Maximum number of users allowed in waitlist','2026-05-01 12:42:43','2026-05-01 12:42:43',1),(3,'beta_launch_date','2026-06-01','Scheduled date for beta launch','2026-05-01 12:42:43','2026-05-14 07:05:13',1);
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscription_plans`
--

DROP TABLE IF EXISTS `subscription_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscription_plans` (
  `id` char(36) NOT NULL,
  `name` varchar(120) NOT NULL,
  `description` text,
  `status` enum('draft','active','inactive','archived') NOT NULL DEFAULT 'draft',
  `free_trials` int NOT NULL DEFAULT '0',
  `price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `currency` char(3) NOT NULL DEFAULT 'USD',
  `features` json DEFAULT NULL,
  `play_store_sub_id` varchar(255) DEFAULT NULL,
  `app_store_sub_id` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_subscription_plans_play_store_sub_id` (`play_store_sub_id`),
  UNIQUE KEY `uq_subscription_plans_app_store_sub_id` (`app_store_sub_id`),
  KEY `idx_subscription_plans_status` (`status`),
  KEY `idx_subscription_plans_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscription_plans`
--

LOCK TABLES `subscription_plans` WRITE;
/*!40000 ALTER TABLE `subscription_plans` DISABLE KEYS */;
INSERT INTO `subscription_plans` VALUES ('a1906a43-4528-401a-99f7-3b4f6652a4bb','Premium','testing','active',0,40.00,'USD','[\"train mode\"]','repvio_monthly','com.codesteem.repvio.premium','2026-05-15 14:29:39','2026-06-24 17:35:41'),('d9ae6120-af75-4790-8833-4f781d3a3ad7','Pro Weekly','weekly','active',0,10.00,'USD','[\"game mod\", \"biseps\"]','pro_weekly','com.codesteem.repvio.pro.weely','2026-05-15 11:40:01','2026-07-03 06:19:40');
/*!40000 ALTER TABLE `subscription_plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `training_modes`
--

DROP TABLE IF EXISTS `training_modes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `training_modes` (
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
  UNIQUE KEY `slug_3` (`slug`),
  UNIQUE KEY `slug_4` (`slug`),
  UNIQUE KEY `slug_5` (`slug`),
  UNIQUE KEY `slug_6` (`slug`),
  UNIQUE KEY `slug_7` (`slug`),
  UNIQUE KEY `slug_8` (`slug`),
  UNIQUE KEY `slug_9` (`slug`),
  UNIQUE KEY `slug_10` (`slug`),
  UNIQUE KEY `slug_11` (`slug`),
  UNIQUE KEY `slug_12` (`slug`),
  UNIQUE KEY `slug_13` (`slug`),
  UNIQUE KEY `slug_14` (`slug`),
  UNIQUE KEY `slug_15` (`slug`),
  UNIQUE KEY `slug_16` (`slug`),
  UNIQUE KEY `slug_17` (`slug`),
  UNIQUE KEY `slug_18` (`slug`),
  UNIQUE KEY `slug_19` (`slug`),
  UNIQUE KEY `slug_20` (`slug`),
  UNIQUE KEY `slug_21` (`slug`),
  UNIQUE KEY `slug_22` (`slug`),
  UNIQUE KEY `slug_23` (`slug`),
  UNIQUE KEY `slug_24` (`slug`),
  UNIQUE KEY `slug_25` (`slug`),
  UNIQUE KEY `slug_26` (`slug`),
  UNIQUE KEY `slug_27` (`slug`),
  UNIQUE KEY `slug_28` (`slug`),
  UNIQUE KEY `slug_29` (`slug`),
  UNIQUE KEY `slug_30` (`slug`),
  KEY `idx_training_modes_active` (`is_active`),
  KEY `idx_training_modes_sort` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `training_modes`
--

LOCK TABLES `training_modes` WRITE;
/*!40000 ALTER TABLE `training_modes` DISABLE KEYS */;
INSERT INTO `training_modes` VALUES ('a0000001-0001-4001-8001-000000000001','training','Training','Standard strength and conditioning style work.',0,1,'2026-05-15 18:33:30','2026-05-15 18:33:30'),('a0000001-0001-4001-8001-000000000002','rehab','Rehab','Recovery-oriented, controlled load and range.',1,1,'2026-05-15 18:33:30','2026-05-15 18:33:30'),('a0000001-0001-4001-8001-000000000003','gaming','Gaming','Playful, score and streak friendly sessions.',2,1,'2026-05-15 18:33:30','2026-05-15 18:33:30');
/*!40000 ALTER TABLE `training_modes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_badges`
--

DROP TABLE IF EXISTS `user_badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_badges` (
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
  CONSTRAINT `user_badges_ibfk_57` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_badges_ibfk_58` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_badges`
--

LOCK TABLES `user_badges` WRITE;
/*!40000 ALTER TABLE `user_badges` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_badges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_challenge_exercise_progress`
--

DROP TABLE IF EXISTS `user_challenge_exercise_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_challenge_exercise_progress` (
  `id` char(36) NOT NULL,
  `user_challenge_id` char(36) NOT NULL,
  `challenge_stage_exercise_id` char(36) NOT NULL,
  `sets_completed` int NOT NULL DEFAULT '0',
  `reps_logged` int NOT NULL DEFAULT '0',
  `status` enum('not_started','in_progress','completed') NOT NULL DEFAULT 'not_started',
  `points_awarded` int NOT NULL DEFAULT '0',
  `completed_at` datetime DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `form_score` int DEFAULT NULL,
  `mistakes` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ucep_mapping` (`user_challenge_id`,`challenge_stage_exercise_id`),
  KEY `idx_ucep_user_challenge` (`user_challenge_id`),
  KEY `idx_ucep_cse` (`challenge_stage_exercise_id`),
  CONSTRAINT `user_challenge_exercise_progress_ibfk_57` FOREIGN KEY (`user_challenge_id`) REFERENCES `user_challenges` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_challenge_exercise_progress_ibfk_58` FOREIGN KEY (`challenge_stage_exercise_id`) REFERENCES `challenge_stage_exercises` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_challenge_exercise_progress`
--

LOCK TABLES `user_challenge_exercise_progress` WRITE;
/*!40000 ALTER TABLE `user_challenge_exercise_progress` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_challenge_exercise_progress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_challenge_stage_progress`
--

DROP TABLE IF EXISTS `user_challenge_stage_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_challenge_stage_progress` (
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
  CONSTRAINT `user_challenge_stage_progress_ibfk_57` FOREIGN KEY (`user_challenge_id`) REFERENCES `user_challenges` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_challenge_stage_progress_ibfk_58` FOREIGN KEY (`challenge_stage_id`) REFERENCES `challenge_stages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_challenge_stage_progress`
--

LOCK TABLES `user_challenge_stage_progress` WRITE;
/*!40000 ALTER TABLE `user_challenge_stage_progress` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_challenge_stage_progress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_challenges`
--

DROP TABLE IF EXISTS `user_challenges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_challenges` (
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
  CONSTRAINT `user_challenges_ibfk_57` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_challenges_ibfk_58` FOREIGN KEY (`challenge_id`) REFERENCES `challenges` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_challenges`
--

LOCK TABLES `user_challenges` WRITE;
/*!40000 ALTER TABLE `user_challenges` DISABLE KEYS */;
INSERT INTO `user_challenges` VALUES ('298d92d8-1bca-4f13-80cf-ddf58d2887e4','2b831991-3d20-4dd4-8864-21e813f51617','c286a95c-b236-442f-b7a2-3682f4d17b29','in_progress',0,'2026-06-23 14:58:53',NULL,'2026-06-23 14:58:53','2026-06-23 14:58:53'),('32517e85-f688-4860-831f-777142180bae','707e8883-6fc2-4be0-84e6-cd24f28bddbd','c286a95c-b236-442f-b7a2-3682f4d17b29','in_progress',0,'2026-07-02 14:30:26',NULL,'2026-07-02 14:30:26','2026-07-02 14:30:26'),('3fb94bf9-e24f-42c7-8722-0b75680656db','49f86a6b-ba79-436f-9895-a64f4735b5f4','c286a95c-b236-442f-b7a2-3682f4d17b29','in_progress',0,'2026-07-03 09:59:56',NULL,'2026-07-03 09:59:56','2026-07-03 09:59:56'),('5e928d2a-5210-491f-9c2f-fc6f1e28a162','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','c286a95c-b236-442f-b7a2-3682f4d17b29','in_progress',0,'2026-07-02 11:26:20',NULL,'2026-07-02 11:26:20','2026-07-02 11:26:20'),('6cb8cd07-a34e-4ec1-80c7-7ae2da16b036','829d351c-d2db-417e-8184-748ec074e7d6','c286a95c-b236-442f-b7a2-3682f4d17b29','in_progress',0,'2026-07-01 07:37:48',NULL,'2026-07-01 07:37:48','2026-07-01 07:37:48'),('9aeb2f7e-9ad4-427e-ad4c-e6ad72dd7252','9436a3d9-54ba-4dba-8793-90a45ed999f4','c286a95c-b236-442f-b7a2-3682f4d17b29','in_progress',0,'2026-07-10 10:43:57',NULL,'2026-07-10 10:43:57','2026-07-10 10:43:57'),('ab5d9dfb-9190-46b9-96ea-0f6f33496c76','e304ca99-06fb-4c5d-818c-48ea20ad3aeb','c286a95c-b236-442f-b7a2-3682f4d17b29','in_progress',0,'2026-06-29 08:59:30',NULL,'2026-06-29 08:59:30','2026-06-29 08:59:30'),('b17c8c46-d690-4440-b24b-1b11828ced24','269b4dd6-916b-4340-b5e1-2277e5b3ee9f','c286a95c-b236-442f-b7a2-3682f4d17b29','in_progress',0,'2026-06-24 04:58:17',NULL,'2026-06-24 04:58:17','2026-06-24 04:58:17'),('bff1084e-3d58-4014-8e6d-b2a9f1fbfe77','61522823-cabf-426f-939c-86b4a293d0e7','c286a95c-b236-442f-b7a2-3682f4d17b29','in_progress',0,'2026-07-02 18:03:37',NULL,'2026-07-02 18:03:37','2026-07-02 18:03:37'),('c463430b-33d0-4d13-a68a-94df9fdd631d','0ac73e72-8181-4598-9585-4847c2782f56','c286a95c-b236-442f-b7a2-3682f4d17b29','in_progress',0,'2026-06-29 11:32:29',NULL,'2026-06-29 11:32:29','2026-06-29 11:32:29');
/*!40000 ALTER TABLE `user_challenges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_subscription_logs`
--

DROP TABLE IF EXISTS `user_subscription_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_subscription_logs` (
  `id` char(36) NOT NULL,
  `user_subscription_id` char(36) DEFAULT NULL,
  `user_id` char(36) NOT NULL,
  `action` enum('created','expiry_updated','deactivated','cancelled','refunded','deleted','reactivated','store_synced') NOT NULL,
  `performed_by` char(36) DEFAULT NULL,
  `note` text,
  `metadata` json DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_sub_logs_subscription` (`user_subscription_id`),
  KEY `idx_sub_logs_user` (`user_id`),
  KEY `idx_sub_logs_action` (`action`),
  CONSTRAINT `fk_sub_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_subscription_logs_ibfk_1` FOREIGN KEY (`user_subscription_id`) REFERENCES `user_subscriptions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_subscription_logs`
--

LOCK TABLES `user_subscription_logs` WRITE;
/*!40000 ALTER TABLE `user_subscription_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_subscription_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_subscription_store_syncs`
--

DROP TABLE IF EXISTS `user_subscription_store_syncs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_subscription_store_syncs` (
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
  PRIMARY KEY (`id`),
  KEY `idx_store_syncs_subscription` (`user_subscription_id`),
  KEY `idx_store_syncs_user` (`user_id`),
  KEY `idx_store_syncs_created` (`createdAt`),
  CONSTRAINT `fk_store_syncs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_subscription_store_syncs_ibfk_1` FOREIGN KEY (`user_subscription_id`) REFERENCES `user_subscriptions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_subscription_store_syncs`
--

LOCK TABLES `user_subscription_store_syncs` WRITE;
/*!40000 ALTER TABLE `user_subscription_store_syncs` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_subscription_store_syncs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_subscriptions`
--

DROP TABLE IF EXISTS `user_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_subscriptions` (
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
  KEY `idx_user_subscriptions_user` (`user_id`),
  KEY `idx_user_subscriptions_plan` (`subscription_plan_id`),
  KEY `idx_user_subscriptions_status` (`status`),
  CONSTRAINT `user_subscriptions_ibfk_57` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_subscriptions_ibfk_58` FOREIGN KEY (`subscription_plan_id`) REFERENCES `subscription_plans` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_subscriptions`
--

LOCK TABLES `user_subscriptions` WRITE;
/*!40000 ALTER TABLE `user_subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
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
  UNIQUE KEY `email_28` (`email`),
  UNIQUE KEY `email_29` (`email`),
  UNIQUE KEY `email_30` (`email`),
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
  UNIQUE KEY `referral_code_27` (`referral_code`),
  UNIQUE KEY `referral_code_28` (`referral_code`),
  UNIQUE KEY `referral_code_29` (`referral_code`),
  UNIQUE KEY `referral_code_30` (`referral_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('01c97de3-e9b2-4220-9e78-5255a1084b39','fhgh@rty.com','$2b$10$4CzqlRpf5rVUSKVN/2J1He1vSFrom263JTI63DC5MQ9jaV3XMjWqC','593F3C',0,0,'user','active',NULL,NULL,'2026-07-01 06:26:33','2026-07-01 06:26:33'),('0ac73e72-8181-4598-9585-4847c2782f56','test@gmail.com','$2b$10$Wzvt6W3TrWGcqLd7hD/g8uYThVOw0VCVtw53IQua6HXbodd4/o4Ke','BA0BC8',0,1,'user','active','fd6e7bb23cf9aa08c53d01059da4ba45ad68a427be0575b3da31ba483d2c036c','2026-07-01 08:11:40','2026-06-24 19:43:00','2026-07-01 07:41:40'),('0cda18ca-d71c-4f16-b7de-8a998cd390df','balaniy921@lovadio.com','$2b$10$WiN7IASVNPgHHtsHekxjCe3htg7DoA35iB./VT13IfgsgFwy1aOhO','87727A',0,0,'user','active','50c2ecf4f8400def747dc315c7a3185a01786118bcf106a3bd75cdafcf606190','2026-07-06 07:44:55','2026-07-06 07:24:55','2026-07-06 07:24:55'),('0e4c5a12-0a9e-4f6e-9a87-51ea53b17e7d','a1@gmail.com','$2b$10$7QG7JeN5Ax0jvscrE2gH6eoo1gB0tc6p85qSOa08vJKHXPMFNFd4y','7BA641',0,1,'user','active',NULL,NULL,'2026-07-02 07:48:21','2026-07-02 07:48:26'),('12437910-ff71-4520-8ee0-225a919720b1','cab@sfj.vom','$2b$10$m2bq9VwErCEsbp4ZfZzOJ.RYguieXfK7ZuMYLegjFIfwoPdrt5CqO','6839C5',0,1,'user','active',NULL,NULL,'2026-07-02 07:24:24','2026-07-02 07:27:38'),('193ae65d-ea83-485e-9520-16e94fc51b30','h@gmail.con','$2b$10$kXfG8IKmF4ACqotLmVzMf.x94n4yravaWTs3aurpplFUt1GBfhMJC','8CE16C',0,1,'user','active',NULL,NULL,'2026-06-18 09:18:28','2026-06-18 09:22:35'),('20e70835-5bf1-4e16-9b99-7d1d653737ca','dani@gmail.com','$2b$10$.XkqpEqJlTuqAAwZk87HB.5ZrJgrtscfpEHV62Pdg0oIqdLUMM0mi','7627C7',0,1,'user','active',NULL,NULL,'2026-06-18 14:11:59','2026-06-18 14:12:05'),('2698e971-2b31-4c49-a815-af0e66ecc0eb','support@codesteemhq.com','$2b$10$OTcRaBpJOmbjqim/N39Vnu0uyYYYz5WqZRK6yR2gc0j.wYIsoxIFi','94F0EF',1,0,'user','active',NULL,NULL,'2026-07-03 17:28:49','2026-07-03 17:28:49'),('269b4dd6-916b-4340-b5e1-2277e5b3ee9f','hamdaan@gmail.com','$2b$10$yORPfe.vyUhlzt6x0yOE1.SCYNMYnmyloZwJWOpgI6oONQJicineu','477E13',0,1,'user','active',NULL,NULL,'2026-06-18 14:10:28','2026-06-18 14:10:38'),('2b831991-3d20-4dd4-8864-21e813f51617','hamdann@gmail.com','$2b$10$yRWpA63VHh1xb68MZtB2ZOE3ezgFn6b9pF8DLU/hKMObfPfP.7mW.','DA9005',0,1,'user','active',NULL,NULL,'2026-06-18 09:24:53','2026-06-18 09:24:58'),('32ed2c8b-05fa-4335-8a38-95aa69a4b2a6','us9587341@gmail.com','$2b$10$CO/Yo9MwfZt512qWkdjqke/V5qXFeW2ybzXN91zuUNWuXc9zS6riC','61B2FC',1,0,'user','active','a08fdef698c61c712ab6ddd1d483d064a7e3dd2cb66897d6edeecee331f042a3','2026-07-10 14:54:23','2026-07-06 07:51:22','2026-07-10 14:24:23'),('3455e753-5b9c-4a73-9b8a-cbd8618017d2','admin@repvio.ai','$2b$10$KabX56mYVoVm/5EnIafuh.ItNjK8Vh7QG4YpAEG00e86wkSM5Nm2u','94842B',0,0,'admin','active',NULL,NULL,'2026-06-17 11:28:00','2026-06-17 11:28:00'),('367acfa4-0322-45bd-ba6d-4b245b687bbd','ghjkbv@jkl.com','$2b$10$7zlt2jyGSc5TJBM/5kdmouyYNPvbYrvk/IXOg/dWvoNHY1w6pw1ku','D0C0BA',0,0,'user','active',NULL,NULL,'2026-07-02 07:04:43','2026-07-02 07:04:43'),('36c6331c-2099-489c-bf60-f02c39d66fc3','abccc@xcn.xom','$2b$10$fbguzoZ0BXgkjib.mJt46uTgHEfwdZ7.76.bU3f7f1A34Hsbe/Imq','B24346',0,1,'user','active',NULL,NULL,'2026-07-02 07:22:50','2026-07-02 07:23:23'),('3765bb21-86d4-4faf-8fc7-fde1b1dc48df','abcc@xyz.com','$2b$10$qgavpzNdcn8GzhWoMmf4M.mY5c6wNKO1kwJzINAgkFP1mXNkzCJiC','A2AD5F',0,0,'user','active',NULL,NULL,'2026-07-02 07:19:40','2026-07-02 07:19:40'),('3e33c37c-c586-4d5e-b1a1-60bf49076596','gdk@gmail.com','$2b$10$8wApDJj8B3DsHWyEE.Db8erlwJQdpbumPE.aCoKnA26awQ1uFJ6Pi','936EDE',0,0,'user','active',NULL,NULL,'2026-06-29 11:20:41','2026-06-29 11:20:41'),('48dedfb8-cad7-4c5e-8587-e79daec3b201','hamdanmansoor1211@gmail.com','$2b$10$UOEW0THHVG4FLefo0biL9Oa01IVxWJ11dwzrxj.5Y2vxUHIBdX1XG','06CD32',1,0,'user','active','e17b5831363db4dda1734970f4784f2b02e8769949b86cbd5a12d2c0466aee49','2026-07-02 09:36:44','2026-07-02 08:58:24','2026-07-02 09:06:44'),('49f86a6b-ba79-436f-9895-a64f4735b5f4','hamdanmansoor5490@gmail.com','$2b$10$U4Us6eD57J3TrrMVzBDsfeRewwNU413mVQJv.tSdtghzEgYeoOaka','7C1CFF',1,1,'user','active',NULL,NULL,'2026-06-17 13:24:17','2026-07-10 15:21:37'),('54b99638-48a6-4167-9987-232e713e6424','a@gmail.com','$2b$10$OT9sTGIn3m8J81/gjBZIM.Wd3030q5rkNy3TEDYNzBT4Z3mxW/u9O','7D823E',0,1,'user','active',NULL,NULL,'2026-06-18 14:14:39','2026-06-18 14:14:51'),('54d44b92-0af3-4a2d-b3aa-89fc15cb764b','abcc@cvb.com','$2b$10$qY/Q21eQSDrqVcmI/Fad7ev7KTnYiASABubljfsMtpA84J3FyTWAa','5B907C',0,1,'user','active',NULL,NULL,'2026-07-02 07:39:58','2026-07-02 07:40:07'),('57f22c95-4f57-4726-8baa-82527f96d17d','ali@gmail.com','$2b$10$a9R.G0tJFKKYedLV.aTDme5hRapTKb7Fn1gOlFyDhdebXvZW.Ulga','ED14C4',0,1,'user','active',NULL,NULL,'2026-06-18 10:27:40','2026-06-18 10:27:50'),('5a90ba96-9815-48bf-b1b5-da33e20826da','agag@2278.com','$2b$10$8FapEqdIBm3sGVatgqQvq.rCainA//fzoALO58SqQ1KydGSF1FWAa','0F3887',0,1,'user','active',NULL,NULL,'2026-07-02 07:31:05','2026-07-02 07:35:58'),('5d40ec0c-fe7f-4b8a-b3bd-36d950868be4','testinge@weol.com','$2b$10$K/nQX.FW4N3xGQAXpdwTCOPVGRw9YcjTADH2k62ZHgu66nFgwMgFC','C50E1D',0,1,'user','active',NULL,NULL,'2026-06-30 06:35:30','2026-06-30 06:35:53'),('61522823-cabf-426f-939c-86b4a293d0e7','musmangul99@gmail.com','$2b$10$kMOYPTdFIQwFEh1kNZVTfOaRWDXlMpNi4Is5HoQApaOvsLpFZbS3i','67EDAE',0,1,'user','active',NULL,NULL,'2026-06-24 21:14:30','2026-06-24 21:14:56'),('6862c015-942a-4d82-990a-c602881234b9','ddani@gmail.com','$2b$10$3c03zNAMh3TdKleXJJhpXeRAG0oGZv3nmXu/pLJFJ0rK1KK13hF9O','2CF20B',0,1,'user','active',NULL,NULL,'2026-06-29 05:51:59','2026-06-29 05:52:17'),('6ccab45d-b1e2-4e49-9a10-90fa9f07f2d2','Asfk@dfg.com','$2b$10$.iEK0ATHrw6H69cApPkvv.QcWNfw.pijLqroJlYYIN/plAmcWvcba','6C9263',0,0,'user','active',NULL,NULL,'2026-07-02 07:10:52','2026-07-02 07:10:52'),('707e8883-6fc2-4be0-84e6-cd24f28bddbd','6yr4r52cg7@privaterelay.appleid.com','$2b$10$PiOCCrlZjNa2PswiRDkGOezxzSbcI.thLn23XzQ8J61NIokAY1T0u','363BD8',1,1,'user','active',NULL,NULL,'2026-07-02 13:59:21','2026-07-02 13:59:28'),('71f8f10a-31f8-493c-b221-0edb8e1f47fd','john@abc.com','$2b$10$YTdOzZnjUltcbG4s/jGbTeTBHK8yqlVyUwgOhIqOTh1MaDEZXy1K.','AA8C50',0,0,'user','active','4b5b23475440bf5e6f5a2bdacb7e2908e90eaf72d0786cda6e96a7b541bd12d7','2026-07-03 07:38:08','2026-07-03 07:18:08','2026-07-03 07:18:08'),('74e3ae7f-87d6-495b-b81c-05e7d8dc82c4','kardejadas@gmail.com','$2b$10$zQJ2exNLCMK8keAq3YKHBOTgpmHwtWXlkU6T/QI5u6PJ0U2ZekvaC','CB574F',0,0,'user','active','b5fdc8b57a126c6d469f79e87253c5b6af7fc4d029ff64df4968fff22027b963','2026-07-02 11:40:01','2026-07-02 11:20:01','2026-07-02 11:20:01'),('7c884423-3d8b-41e5-af18-6666d53ddd99','afu@gmaul.com','$2b$10$XIXknx0cdxPO1V.IMikujOyYahqUrQLaYaPS10tUnRXsnHjO7dYA6','8BCA49',0,0,'user','active',NULL,NULL,'2026-07-02 06:53:54','2026-07-02 06:53:54'),('816a6566-7fb0-4a46-a2aa-f17079767586','hfufjf@bjoi.com','$2b$10$UjkHxbgp.CTk/snBbC7WMeR6XGU6mzx42HEG880Ba.m0czGlH1hh6','EE3E36',0,0,'user','active',NULL,NULL,'2026-07-01 05:41:45','2026-07-01 05:41:45'),('822e6879-34f9-476a-84fd-fe09dcd60eaa','ttest@gmail.com','$2b$10$zoJyDyXviCGbGBhr4T/4H.ZeK2hSixTeHQOMDSY7OV9eIfGsV9Xdu','CA2168',0,1,'user','active',NULL,NULL,'2026-06-29 05:53:18','2026-06-29 05:53:27'),('829d351c-d2db-417e-8184-748ec074e7d6','usama@codesteam.com','$2b$10$pOL1gaK.kHGvuEb8H2ed8OADk2NDyNba3PT/RK7GERjoLblkYeywy','AF95AD',0,1,'user','active','28917c851ef51cf115f2e0c178a3abfaa5dc380041c0370a0e6711603c3be5a7','2026-07-02 09:02:02','2026-07-01 06:33:33','2026-07-02 08:32:02'),('9436a3d9-54ba-4dba-8793-90a45ed999f4','danihere64@gmail.com','$2b$10$1/D5SJErnUJvXLQRpljpKOB7st3oTAzS7r6V.ZterQeoDhVH43.DO','EBB4C9',1,1,'user','active',NULL,NULL,'2026-07-03 05:12:31','2026-07-03 05:12:49'),('95b18071-b853-4d70-b37f-fe26286ef025','jorshanbanze@gmail.com','$2b$10$6DwWHErYWwH/4YBVgNwA1eHHvKdJDPqojgbd90V/7q0yiIX5uylhW','C08812',0,0,'user','active','cd53550d224779a90e78fbb84f9c2aeec485c04e4288abd74c2999604ecebdaa','2026-07-14 14:57:13','2026-07-14 14:37:13','2026-07-14 14:37:13'),('9a274228-3432-4fb9-bf8c-6c8ec1beac87','fbasesoftarena83@gmail.com','$2b$10$9G7PW1HxxmgvdrmfY3GareLZcDarjjiye18fVWNzkvEtRXod0YwNu','C77639',1,1,'user','active',NULL,NULL,'2026-07-14 14:39:27','2026-07-14 14:57:00'),('a90f00ba-5259-4380-94ee-42e764b7fb9e','abc@xyz.com','$2b$10$2foqjd..B.G//xG.I8Srd.EImah3QpYtUmU.j.x3ubTnvW4I3uhZK','21307B',0,0,'user','active',NULL,NULL,'2026-07-02 06:55:23','2026-07-02 06:55:23'),('c32682d0-27dc-4072-959f-dd888e925bd4','aggyh@msil.com','$2b$10$9h5PmanRKWEpENaHKuYFguYkIE2HMH5Wrh.wkQbPhhIG/w2IHyE2u','4C3636',0,0,'user','active','8fb9f87e989d3f297e2a208a1c66a98d056d2a7da7c8188aa6a18645eb48977e','2026-07-06 08:04:15','2026-07-06 07:44:15','2026-07-06 07:44:15'),('c4f8df19-b40d-4318-879e-08a165f35cea','james@jack.com','$2b$10$kFmBznUmCSe96L8FwH3YluVxnkq.WPYoZ1DexE6l5D/YOLvm0FTkC','DD8A10',0,1,'user','active','9ad3f1a363faac8f1080e5009513a4955ef81fbdff4053a118323ce6ad5401fe','2026-07-02 11:33:24','2026-07-02 11:13:24','2026-07-02 11:13:49'),('e304ca99-06fb-4c5d-818c-48ea20ad3aeb','usama@codesteem.com','$2b$10$/dE4Sek1eghUOFM5FI3j/OBof3lQBO3SYpq6UjtDyichyETQiwfBm','1FE563',0,1,'user','active',NULL,NULL,'2026-06-29 07:20:22','2026-07-06 07:28:31'),('eec74c80-8802-4d81-9229-00d8c15e04c9','testinge@wel.com','$2b$10$gGarK7rASc55xdQlqhvdNu8BZcqTX4R6wVqAAGpzFpPyg/sGgY2oa','E78915',0,1,'user','active',NULL,NULL,'2026-06-30 06:33:23','2026-06-30 06:33:37'),('f46d6ea4-7b74-490a-b74e-e46cddf3cdf8','a3@gmail.com','$2b$10$A9EbZgcExoxeJR6rmH1qm.MAXhMEPfEM.lSdO8blSINjoJmaeei6C','F96166',0,1,'user','active',NULL,NULL,'2026-07-02 07:55:41','2026-07-02 07:55:47'),('f96faa96-c0d1-48ad-b6e5-28e2220364e2','a2@gmail.com','$2b$10$20Dgg5yELvqXT56IKqB38.Rw6znlvaZaBtlq6DcBnUKd7o8pzqfES','B5C270',0,1,'user','active',NULL,NULL,'2026-07-02 07:49:09','2026-07-02 07:49:17'),('fb6a60a0-b9ae-46dd-9310-3d24460ceedd','nexcodeverse@gmail.com','$2b$10$QFEuRsP6eJ2vDtMUiqe6m.1LCJyWDAGuT1JS0eoIfSRslBvRRckTi','5C1F23',1,1,'user','active',NULL,NULL,'2026-07-02 11:22:03','2026-07-02 11:23:12');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `waitlistUsers`
--

DROP TABLE IF EXISTS `waitlistUsers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `waitlistUsers` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `waitlistUsers`
--

LOCK TABLES `waitlistUsers` WRITE;
/*!40000 ALTER TABLE `waitlistUsers` DISABLE KEYS */;
INSERT INTO `waitlistUsers` VALUES ('0ff118da-0963-4d1e-9fcf-ee0dd74539ce','fbasesoftarena83@gmail.com','Android','Fitness gaming','F19EB5','2F5643',0,NULL,'2026-05-11 14:40:38','2026-05-11 14:40:38'),('1bea5e0c-00fb-42b9-9616-6f3e86d6eb50','amohsan12345678@gmail.com','iPhone','Workout form correction','2F5643',NULL,2,NULL,'2026-05-08 17:36:53','2026-05-11 14:40:38'),('3e1579ae-8260-491f-af1a-74a91310ad85','mohsancode@gmail.com','Android','Workout form correction','1AF80D','2F5643',0,NULL,'2026-05-11 14:24:37','2026-05-11 14:24:37'),('6df06382-11bf-499b-bc28-e0e4df832dee','asfk@dfg.com','iPhone','Workout form correction','5D4E88',NULL,0,NULL,'2026-07-02 13:06:56','2026-07-02 13:06:56'),('d7f38228-0437-4a0b-a58e-8901b9f04267','musmangul99@gmail.com','iPhone','Workout form correction','D0A0D8',NULL,0,NULL,'2026-05-12 12:13:07','2026-05-12 12:13:07'),('f05008a3-a2df-42b1-a1b5-434488ab66dc','codo@dfg.com','Android','Fitness gaming','E7969B',NULL,0,NULL,'2026-07-02 12:32:56','2026-07-02 12:32:56');
/*!40000 ALTER TABLE `waitlistUsers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `waitlistusers`
--

DROP TABLE IF EXISTS `waitlistusers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `waitlistusers` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `waitlistusers`
--

LOCK TABLES `waitlistusers` WRITE;
/*!40000 ALTER TABLE `waitlistusers` DISABLE KEYS */;
INSERT INTO `waitlistusers` VALUES ('5484508b-6f6c-4fe5-b986-3b9510587a4e','mohsan.webdev@gmail.com','Android','Recovery & mobility','BA151D','6A7D55',0,NULL,'2026-05-01 17:03:22','2026-05-01 17:03:22'),('63ed9a88-b30d-4f9f-bdb0-da84c46c1b17','mohsancode@gmail.com','Android','Workout form correction','AB1A82',NULL,2,NULL,'2026-05-01 13:56:16','2026-05-01 15:28:32'),('6ad25e41-6cc2-483c-994b-a7f04642bc03','tenaco5723@kynninc.com','Android','Workout form correction','6A7D55','AB1A82',1,NULL,'2026-05-01 15:28:32','2026-05-01 17:03:22'),('798df966-8697-4b48-8460-37392a2cedfb','musmangul99@gmail.com','iPhone','Fitness gaming','E9CE8C','370297',0,NULL,'2026-05-01 15:48:05','2026-05-01 15:48:05'),('e2070a6d-067f-474c-b9d0-f27eda9b96c4','amohsan12345678@gmail.com','Android','Fitness gaming','370297','AB1A82',1,NULL,'2026-05-01 14:21:13','2026-05-01 15:48:05');
/*!40000 ALTER TABLE `waitlistusers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workout_sessions`
--

DROP TABLE IF EXISTS `workout_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workout_sessions` (
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
  CONSTRAINT `workout_sessions_ibfk_70` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `workout_sessions_ibfk_71` FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `workout_sessions_ibfk_72` FOREIGN KEY (`challenge_id`) REFERENCES `challenges` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workout_sessions`
--

LOCK TABLES `workout_sessions` WRITE;
/*!40000 ALTER TABLE `workout_sessions` DISABLE KEYS */;
INSERT INTO `workout_sessions` VALUES ('0345e69b-41f7-4234-b0b6-c574216d47dc','707e8883-6fc2-4be0-84e6-cd24f28bddbd','0112ee81-a37f-42fa-9f54-42cef106cace','train',NULL,100,3,1,6,NULL,130,'[\"Move Through The Full Range\"]',NULL,'2026-07-14 17:31:11','2026-07-14 17:31:12','2026-07-14 17:31:12'),('03921b4d-6c6c-4963-a744-1aa1d3579c79','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','0f9206c3-a0f4-464e-95d8-14fa3084c032','train',NULL,100,10,1,17,NULL,200,'[\"Knee tracking\"]',NULL,'2026-07-20 11:28:28','2026-07-20 11:28:49','2026-07-20 11:28:49'),('04684d7c-3b97-4e2a-a3ef-d9d866a77bc9','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','0f9206c3-a0f4-464e-95d8-14fa3084c032','train',NULL,100,10,1,64,NULL,200,'[\"Knee tracking\", \"Back posture\"]',NULL,'2026-07-20 11:29:46','2026-07-20 11:30:08','2026-07-20 11:30:08'),('049ae719-49f6-4b4f-bb3d-2e3ad248576d','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,100,2,1,51,NULL,100,'[\"Hold Position. Keep Smooth Control.\", \"Body Detected. Move Through The Full Rep Range.\", \"Get Ready. Keep Smooth Control.\"]',NULL,'2026-06-30 12:32:01','2026-06-30 12:32:03','2026-06-30 12:32:03'),('050781eb-db51-4c32-bdf9-6c2086812d7c','707e8883-6fc2-4be0-84e6-cd24f28bddbd','c421248c-706c-46fe-b73e-d016937bfdfa','train',NULL,100,10,1,110,NULL,200,'[\"Wrong Exercise Perform Dumbbell Crunches, Not Pushup\", \"Back posture\", \"Hold Crunch Position Settle Before Reps Count\"]',NULL,'2026-07-16 15:16:10','2026-07-16 15:16:11','2026-07-16 15:16:11'),('07083c88-4e47-42d7-b7ce-7034b1c7887e','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','4ad754fd-05c7-448c-8c33-9d089ad454ad','train',NULL,52,1,1,22,NULL,62,'[\"Camera setup\", \"Back posture\", \"Knee tracking\"]',NULL,'2026-07-06 15:02:14','2026-07-06 15:02:15','2026-07-06 15:02:15'),('0751242c-703b-48dd-a8b7-d2bf9934dc80','707e8883-6fc2-4be0-84e6-cd24f28bddbd','32d3d42f-e926-4904-a550-d49fa7bdaf62','train',NULL,52,2,1,28,NULL,72,'[\"Press To Full Extension\", \"Press Both Arms Evenly. Keep Smooth Control.\", \"Hold Position. Keep Smooth Control.\"]',NULL,'2026-07-03 14:37:56','2026-07-03 14:37:57','2026-07-03 14:37:57'),('09d8a306-24ab-48e6-8f1e-e256e3a86778','0ac73e72-8181-4598-9585-4847c2782f56','888594f4-f2ca-4038-b088-d8b4da1212e8','train',NULL,78,8,1,44,NULL,78,'[\"Body Detected. Move Through The Full Rep Range.\", \"Hold Position\", \"Back posture\"]',NULL,'2026-06-29 12:48:16','2026-06-29 12:48:17','2026-06-29 12:48:17'),('0a16e595-79c0-4a25-8238-6ed5223d844d','0ac73e72-8181-4598-9585-4847c2782f56','888594f4-f2ca-4038-b088-d8b4da1212e8','train',NULL,52,2,1,23,NULL,52,'[\"Body Detected. Move Through The Full Rep Range.\", \"Camera setup\"]',NULL,'2026-06-29 08:41:39','2026-06-29 08:41:41','2026-06-29 08:41:41'),('0b4e988d-6f1d-4b7f-9681-d3b9a5b34a96','2b831991-3d20-4dd4-8864-21e813f51617','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,78,21,1,63,NULL,78,'[\"Body Detected. Move Through The Full Rep Range.\", \"Reach Full Extension. Keep Smooth Control.\", \"Camera setup\"]',NULL,'2026-06-24 11:08:25','2026-06-24 11:08:26','2026-06-24 11:08:26'),('0be984cd-b8ce-4a82-8841-50cf16409dfe','2b831991-3d20-4dd4-8864-21e813f51617','c144ba27-8353-4411-b80f-a56747999111','train',NULL,52,4,1,108,NULL,52,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"Hold Position\"]',NULL,'2026-06-24 12:22:51','2026-06-24 12:22:53','2026-06-24 12:22:53'),('0c6c9c8e-4b47-4230-a220-214d0e5be84d','0ac73e72-8181-4598-9585-4847c2782f56','94f19831-9b37-40ac-8129-5aa2ce7ec0aa','train',NULL,49,0,1,47,NULL,49,'[\"No Body Detected\", \"Body Detected. Move Through The Full Rep Range.\", \"Shoulder position\"]',NULL,'2026-06-29 08:44:04','2026-06-29 08:44:06','2026-06-29 08:44:06'),('0c871f4c-8b3a-45e4-9d6f-2779042eefb0','707e8883-6fc2-4be0-84e6-cd24f28bddbd','c421248c-706c-46fe-b73e-d016937bfdfa','train',NULL,100,10,1,77,NULL,200,'[\"Hold Crunch Position Settle Before Reps Count\", \"Wrong Exercise Perform Dumbbell Crunches, Not Pushup\", \"Wrong Exercise Perform Dumbbell Crunches, Not Jumpingjack\"]',NULL,'2026-07-14 15:04:49','2026-07-14 15:04:51','2026-07-14 15:04:51'),('0d884d7e-1825-460a-9a0d-12206d0e16fa','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','0f9206c3-a0f4-464e-95d8-14fa3084c032','train',NULL,100,10,1,37,NULL,200,'[\"Knee tracking\"]',NULL,'2026-07-20 11:31:59','2026-07-20 11:32:21','2026-07-20 11:32:21'),('0e083654-ea72-4bef-a8f4-0d1d3bcc336b','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,75,0,1,10,NULL,75,'[\"Back posture\", \"Lower Fully. Keep Smooth Control.\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-29 15:23:00','2026-06-29 15:23:01','2026-06-29 15:23:01'),('0e439c09-6f56-4487-b64c-ac24efc9a8ba','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','94f19831-9b37-40ac-8129-5aa2ce7ec0aa','train',NULL,49,14,1,110,NULL,119,'[\"Keep Body Straight. Keep Smooth Control.\", \"Camera setup\", \"No Body Detected. Keep Smooth Control.\"]',NULL,'2026-07-06 13:42:24','2026-07-06 13:42:25','2026-07-06 13:42:25'),('0e5fa26e-e054-44b2-9d1e-b162dd94e129','707e8883-6fc2-4be0-84e6-cd24f28bddbd','1c98c98d-e943-489d-b792-7e7b20394e36','train',NULL,100,10,1,94,NULL,180,'[\"Shoulder position\", \"Correct: Stop The Other Movement And Return To Your Assigned Exercise\"]',NULL,'2026-07-14 16:14:33','2026-07-14 16:14:34','2026-07-14 16:14:34'),('10f598fa-8b38-464a-b4d7-bfa371adbf63','707e8883-6fc2-4be0-84e6-cd24f28bddbd','36977cbc-7ae7-4d27-beb0-e2d2889126c1','train',NULL,46,0,1,132,NULL,46,'[\"Stance control\", \"Back posture\", \"Camera setup\"]',NULL,'2026-07-03 11:19:49','2026-07-03 11:19:51','2026-07-03 11:19:51'),('11bd6720-68c4-47d7-9f40-5dfdabf3c104','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,49,0,1,20,NULL,49,'[\"Shoulder position\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-29 06:11:37','2026-06-29 06:11:39','2026-06-29 06:11:39'),('1300ae4c-3159-4bd8-a2ea-3a410f4b1e4f','0ac73e72-8181-4598-9585-4847c2782f56','32d3d42f-e926-4904-a550-d49fa7bdaf62','train',NULL,65,4,1,42,NULL,65,'[\"Body Detected. Move Through The Full Rep Range.\", \"Press Both Arms Evenly. Keep Smooth Control.\", \"Press To Full Extension\"]',NULL,'2026-06-29 16:20:40','2026-06-29 16:20:42','2026-06-29 16:20:42'),('13399aeb-9748-44f1-850f-3e1ee804bc4e','0ac73e72-8181-4598-9585-4847c2782f56','eeefad65-8dc5-4b90-b29d-3527d4294555','train',NULL,78,0,1,45,NULL,78,'[\"Body Detected. Move Through The Full Rep Range.\", \"Back posture\", \"Hold Position\"]',NULL,'2026-06-29 15:33:12','2026-06-29 15:33:13','2026-06-29 15:33:13'),('13539d48-3fb8-4771-854d-56ea92c83f8d','0ac73e72-8181-4598-9585-4847c2782f56','c421248c-706c-46fe-b73e-d016937bfdfa','train',NULL,100,3,1,22,NULL,130,'[\"Back posture\", \"Hold Crunch Position Settle Before Reps Count\"]',NULL,'2026-07-17 10:11:54','2026-07-17 10:11:55','2026-07-17 10:11:55'),('13f09426-bf60-4924-91ab-2a472b7dd62d','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,85,28,1,101,NULL,85,'[\"Clean movement\"]',NULL,'2026-07-08 11:13:46','2026-07-08 11:13:48','2026-07-08 11:13:48'),('16bd8737-e9b8-4e7b-80d8-1856d57b3a21','0ac73e72-8181-4598-9585-4847c2782f56','578b3dbd-dad4-40f2-a363-ae50b52cdd52','train',NULL,52,0,1,38,NULL,52,'[\"No completed reps\"]',NULL,'2026-07-10 16:41:39','2026-07-10 16:41:41','2026-07-10 16:41:41'),('17345995-70a1-40a0-a11e-301c60e2c9d0','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,49,0,1,25,NULL,49,'[\"Body Detected. Move Through The Full Rep Range.\", \"Shoulder position\", \"No Body Detected\"]',NULL,'2026-06-29 09:31:14','2026-06-29 09:31:16','2026-06-29 09:31:16'),('1774c883-a628-4092-beac-f196ae390cef','0ac73e72-8181-4598-9585-4847c2782f56','e27c9e80-2eff-45c5-83df-993abb888df5','train',NULL,1,3,1,25,NULL,1,'[\"Body Detected. Move Through The Full Rep Range.\", \"Hold Position. Keep Smooth Control.\", \"Press Overhead Fully. Keep Smooth Control.\"]',NULL,'2026-06-30 12:33:48','2026-06-30 12:33:50','2026-06-30 12:33:50'),('1871d66e-5965-4c78-a812-86b8ff03d04d','707e8883-6fc2-4be0-84e6-cd24f28bddbd','c421248c-706c-46fe-b73e-d016937bfdfa','train',NULL,100,4,1,35,NULL,140,'[\"Knee tracking\"]',NULL,'2026-07-08 15:04:59','2026-07-08 15:05:00','2026-07-08 15:05:00'),('197e383b-d0da-4695-b4b3-5e662cb149e7','0ac73e72-8181-4598-9585-4847c2782f56','4ad754fd-05c7-448c-8c33-9d089ad454ad','train',NULL,1,0,1,31,NULL,1,'[\"Camera setup\", \"Correct: Stop The Other Movement And Return To Your Assigned Exercise\"]',NULL,'2026-07-17 10:25:35','2026-07-17 10:25:37','2026-07-17 10:25:37'),('1b0e4b34-a9a9-41cf-9b19-a87442abfb37','0ac73e72-8181-4598-9585-4847c2782f56','c421248c-706c-46fe-b73e-d016937bfdfa','train',NULL,82,0,1,605,NULL,82,'[\"Back posture\", \"Hold Crunch Position Settle Before Reps Count\"]',NULL,'2026-07-10 17:22:49','2026-07-10 17:22:52','2026-07-10 17:22:52'),('1ba413a0-902d-459a-b3c2-6821233eac2c','e304ca99-06fb-4c5d-818c-48ea20ad3aeb','36977cbc-7ae7-4d27-beb0-e2d2889126c1','train',NULL,52,0,1,22,NULL,52,'[\"Camera setup\", \"No Body Detected\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-29 11:18:26','2026-06-29 11:18:47','2026-06-29 11:18:47'),('1bc8e67a-8023-4435-8c4c-0e3b132014a1','707e8883-6fc2-4be0-84e6-cd24f28bddbd','3a52c682-5111-4698-8ffa-45d70b004522','train',NULL,52,0,1,1,NULL,52,'[\"Camera setup\"]',NULL,'2026-07-06 16:02:20','2026-07-06 16:02:21','2026-07-06 16:02:21'),('1d2be887-b26d-401b-aba2-d6a1bc8536d6','0ac73e72-8181-4598-9585-4847c2782f56','eeefad65-8dc5-4b90-b29d-3527d4294555','train',NULL,52,5,1,67,NULL,52,'[\"Body Detected. Move Through The Full Rep Range.\", \"Camera setup\", \"No Body Detected\"]',NULL,'2026-06-29 08:43:05','2026-06-29 08:43:07','2026-06-29 08:43:07'),('1df0330a-5726-40f7-bbb1-99a627d1eb15','0ac73e72-8181-4598-9585-4847c2782f56','0eafe471-1d5c-4b5e-a513-e03d39e3d46f','train',NULL,78,0,1,49,NULL,78,'[\"Back posture\", \"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-30 07:53:34','2026-06-30 07:53:35','2026-06-30 07:53:35'),('1eff3235-c2d8-4ec8-9fd0-ec9e01645f67','0ac73e72-8181-4598-9585-4847c2782f56','0eafe471-1d5c-4b5e-a513-e03d39e3d46f','train',NULL,52,0,1,20,NULL,52,'[\"Back posture\", \"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\"]',NULL,'2026-06-30 11:43:12','2026-06-30 11:43:19','2026-06-30 11:43:19'),('1f53924e-91c7-4405-8a3f-390548d2a6ed','0ac73e72-8181-4598-9585-4847c2782f56','c421248c-706c-46fe-b73e-d016937bfdfa','train',NULL,82,4,1,17,NULL,82,'[\"Camera setup\", \"Hold Position. Keep Smooth Control.\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-07-01 05:46:47','2026-07-01 05:46:49','2026-07-01 05:46:49'),('1f99a6b0-6df7-4246-8c6e-b350bc2f5ee5','2b831991-3d20-4dd4-8864-21e813f51617','c144ba27-8353-4411-b80f-a56747999111','train',NULL,49,0,1,5,NULL,49,'[\"Shoulder position\", \"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-26 14:33:42','2026-06-26 14:33:44','2026-06-26 14:33:44'),('21ab5fde-2ca3-4c08-9bc3-39d5f392c9ad','e304ca99-06fb-4c5d-818c-48ea20ad3aeb','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,5,1,28,NULL,52,'[\"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\", \"Camera setup\"]',NULL,'2026-06-29 11:05:00','2026-06-29 11:05:21','2026-06-29 11:05:21'),('221d7d84-8513-403c-9f9f-b8bc6ce3c8ab','0ac73e72-8181-4598-9585-4847c2782f56','f3922cdc-a715-4382-9d1b-4f58a3c5f249','train',NULL,85,10,1,55,NULL,85,'[\"Move Through The Full Range\"]',NULL,'2026-07-14 16:34:47','2026-07-14 16:34:49','2026-07-14 16:34:49'),('2247a9f9-6809-4871-b371-6b9538b1805e','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,49,0,1,18,NULL,49,'[\"Body Detected. Move Through The Full Rep Range.\", \"Shoulder position\"]',NULL,'2026-06-29 08:41:06','2026-06-29 08:41:08','2026-06-29 08:41:08'),('2329a847-06dd-48bb-9826-4d0312bbbc81','0ac73e72-8181-4598-9585-4847c2782f56','c144ba27-8353-4411-b80f-a56747999111','train',NULL,49,5,1,67,NULL,49,'[\"Body Detected. Move Through The Full Rep Range.\", \"Camera setup\", \"Shoulder position\"]',NULL,'2026-06-30 06:32:06','2026-06-30 06:32:07','2026-06-30 06:32:07'),('23ef1982-08bd-40af-9698-2042f989d399','0ac73e72-8181-4598-9585-4847c2782f56','c144ba27-8353-4411-b80f-a56747999111','train',NULL,49,0,1,5,NULL,49,'[\"Shoulder position\"]',NULL,'2026-07-08 17:11:58','2026-07-08 17:12:00','2026-07-08 17:12:00'),('26858ade-51a1-4d6b-a02a-913988b9da3a','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','0f9206c3-a0f4-464e-95d8-14fa3084c032','train',NULL,100,10,1,9,NULL,200,'[\"Knee tracking\"]',NULL,'2026-07-20 11:36:51','2026-07-20 11:37:12','2026-07-20 11:37:12'),('2a8472de-4b67-4911-87dd-f41cfaf8b611','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,49,0,1,58,NULL,49,'[\"Shoulder position\", \"Body Detected. Move Through The Full Rep Range.\", \"Back posture\"]',NULL,'2026-06-29 13:01:18','2026-06-29 13:01:20','2026-06-29 13:01:20'),('2aa850e1-cb6e-4f2f-8122-f0645267e22b','707e8883-6fc2-4be0-84e6-cd24f28bddbd','32d3d42f-e926-4904-a550-d49fa7bdaf62','train',NULL,100,6,1,95,NULL,160,'[\"Press To Full Extension\", \"Press Both Arms Evenly\"]',NULL,'2026-07-08 16:26:36','2026-07-08 16:26:37','2026-07-08 16:26:37'),('2accc0ac-d887-4a2c-8a4b-9a41a66428e4','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,75,0,1,75,NULL,75,'[\"Shoulder position\", \"Back posture\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-29 13:19:57','2026-06-29 13:19:58','2026-06-29 13:19:58'),('2bdd79aa-2c3c-4316-aa20-68af4e1c9650','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,17,NULL,52,'[\"Camera setup\"]',NULL,'2026-07-06 13:53:46','2026-07-06 13:53:47','2026-07-06 13:53:47'),('2be62316-26ec-49bc-b56a-5797ced0adc6','54d44b92-0af3-4a2d-b3aa-89fc15cb764b','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,6,NULL,52,'[\"Camera setup\", \"No Body Detected\", \"Hold Position. Keep Smooth Control.\"]',NULL,'2026-07-02 07:40:13','2026-07-02 07:40:33','2026-07-02 07:40:33'),('2c3669a2-d20e-42a4-a876-e498c39f40cf','0ac73e72-8181-4598-9585-4847c2782f56','0112ee81-a37f-42fa-9f54-42cef106cace','train',NULL,81,3,1,69,NULL,81,'[\"Move Through The Full Range\", \"Correct: Lift Arms Higher Through A Pain Free Range\"]',NULL,'2026-07-14 16:12:47','2026-07-14 16:12:49','2026-07-14 16:12:49'),('2c8514a1-f3cd-4902-abe2-657863972fa7','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,85,28,1,100,NULL,85,'[\"Clean movement\"]',NULL,'2026-07-08 11:13:44','2026-07-08 11:13:55','2026-07-08 11:13:55'),('2cabc8d3-491b-4f8c-8289-25a4a63435f2','707e8883-6fc2-4be0-84e6-cd24f28bddbd','0eafe471-1d5c-4b5e-a513-e03d39e3d46f','train',NULL,100,10,1,45,NULL,200,'[\"Clean movement\"]',NULL,'2026-07-17 12:49:05','2026-07-17 12:49:06','2026-07-17 12:49:06'),('2cbdc603-1f8c-4c59-81fa-bd2238a99dfc','707e8883-6fc2-4be0-84e6-cd24f28bddbd','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,75,0,1,120,NULL,75,'[\"Lower Fully. Keep Smooth Control.\", \"Back posture\", \"Hold Position. Keep Smooth Control.\"]',NULL,'2026-07-03 14:37:18','2026-07-03 14:37:19','2026-07-03 14:37:19'),('2e0fbda9-c788-4fdb-982b-ba3a62bdcc6d','0ac73e72-8181-4598-9585-4847c2782f56','888594f4-f2ca-4038-b088-d8b4da1212e8','train',NULL,52,0,1,39,NULL,52,'[\"No Body Detected\", \"Body Detected. Move Through The Full Rep Range.\", \"Camera setup\"]',NULL,'2026-06-29 06:40:48','2026-06-29 06:40:50','2026-06-29 06:40:50'),('2e1aa244-3e1c-496e-8224-b031088821f6','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,52,0,1,16,NULL,52,'[\"No Body Detected\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-29 09:31:42','2026-06-29 09:31:44','2026-06-29 09:31:44'),('2e2f40c1-bbae-4d57-a30b-1e01c53c6021','707e8883-6fc2-4be0-84e6-cd24f28bddbd','32d3d42f-e926-4904-a550-d49fa7bdaf62','train',NULL,100,6,1,96,NULL,160,'[\"Press To Full Extension\", \"Press Both Arms Evenly\"]',NULL,'2026-07-08 16:26:37','2026-07-08 16:26:38','2026-07-08 16:26:38'),('2e3b1a13-5605-4efb-ae9b-784db1d6fd4c','0ac73e72-8181-4598-9585-4847c2782f56','888594f4-f2ca-4038-b088-d8b4da1212e8','train',NULL,100,2,1,17,NULL,100,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"Hold Position. Keep Smooth Control.\"]',NULL,'2026-07-01 06:12:45','2026-07-01 06:12:47','2026-07-01 06:12:47'),('2e973789-007e-454f-89bf-193e50d19b76','2b831991-3d20-4dd4-8864-21e813f51617','0a9e0ed6-81d9-4395-a0ed-8454af7792df','train',NULL,78,0,1,52,NULL,78,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"Pose Detection Failed\"]',NULL,'2026-06-24 11:05:37','2026-06-24 11:05:43','2026-06-24 11:05:43'),('2f86417f-f2a3-4e78-af19-a628100a37ee','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,4432,NULL,52,'[\"Camera setup\", \"Hold Position\", \"Back posture\"]',NULL,'2026-06-29 12:29:23','2026-06-29 12:29:26','2026-06-29 12:29:26'),('2fd727ad-1172-4403-96fd-a8cfbf6fe240','2b831991-3d20-4dd4-8864-21e813f51617','36977cbc-7ae7-4d27-beb0-e2d2889126c1','train',NULL,52,0,1,166,NULL,52,'[\"Hold Position\", \"Camera setup\", \"Pose Detection Failed\"]',NULL,'2026-06-24 17:59:07','2026-06-24 17:59:08','2026-06-24 17:59:08'),('30816392-313b-4782-8a5b-27cb0f5e7b1f','0ac73e72-8181-4598-9585-4847c2782f56','e27c9e80-2eff-45c5-83df-993abb888df5','train',NULL,100,2,1,211,NULL,100,'[\"Body Detected. Move Through The Full Rep Range.\", \"Hold Position\", \"Shoulder position\"]',NULL,'2026-06-30 08:08:08','2026-06-30 08:08:09','2026-06-30 08:08:09'),('3135d782-862a-4fb6-9501-1cb155ad9ef8','0ac73e72-8181-4598-9585-4847c2782f56','1c98c98d-e943-489d-b792-7e7b20394e36','train',NULL,68,0,1,22,NULL,68,'[\"Shoulder position\", \"Body Detected. Move Through The Full Rep Range.\", \"Hold Position. Keep Smooth Control.\"]',NULL,'2026-07-01 06:02:10','2026-07-01 06:02:12','2026-07-01 06:02:12'),('31aa635c-cb40-478f-b976-37affe38f705','49f86a6b-ba79-436f-9895-a64f4735b5f4','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,2,1,43,NULL,72,'[\"Hold Position. Keep Smooth Control.\", \"Camera setup\", \"Back posture\"]',NULL,'2026-07-03 09:45:06','2026-07-03 09:45:07','2026-07-03 09:45:07'),('31e35f55-5f28-4ddf-8f76-af314f168e06','707e8883-6fc2-4be0-84e6-cd24f28bddbd','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,65,7,1,105,NULL,65,'[\"Back posture\", \"Lower Fully\"]',NULL,'2026-07-08 15:23:20','2026-07-08 15:23:21','2026-07-08 15:23:21'),('32d5116c-968d-443a-ae78-fa405e862510','707e8883-6fc2-4be0-84e6-cd24f28bddbd','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,100,56,1,204,NULL,660,'[\"Open Arms And Legs Wider\"]',NULL,'2026-07-08 14:19:39','2026-07-08 14:19:40','2026-07-08 14:19:40'),('32f38218-fc75-4e27-bf8d-910105fcfb94','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,19,NULL,52,'[\"Open Arms And Legs Wider\"]',NULL,'2026-07-08 11:17:24','2026-07-08 11:17:26','2026-07-08 11:17:26'),('32fc447a-c9ba-400e-938c-1e4d6cc8f14a','707e8883-6fc2-4be0-84e6-cd24f28bddbd','4ad754fd-05c7-448c-8c33-9d089ad454ad','train',NULL,100,3,1,146,NULL,130,'[\"Correct: Sit Hips Lower Thigh Parallel To Floor\", \"Correct: Stop The Other Movement And Return To Your Assigned Exercise\", \"Use Single Leg Squat Form Lift One Leg Off The Floor\"]',NULL,'2026-07-10 13:08:02','2026-07-10 13:08:03','2026-07-10 13:08:03'),('332fb983-b4d7-436d-aee0-18e6b1a1ef98','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','0f9206c3-a0f4-464e-95d8-14fa3084c032','train',NULL,96,11,1,0,NULL,96,'[\"Back posture\"]',NULL,'2026-07-20 11:40:04','2026-07-20 11:40:25','2026-07-20 11:40:25'),('347ba734-8512-4ca1-a22f-ae5731121c39','0ac73e72-8181-4598-9585-4847c2782f56','94f19831-9b37-40ac-8129-5aa2ce7ec0aa','train',NULL,100,0,1,42,NULL,100,'[\"Correct: Fix The Red Highlighted Body Parts, Then Repeat The Rep\", \"Shoulder position\", \"Wrong Exercise Perform Pushup, Not Squat\"]',NULL,'2026-07-10 16:42:59','2026-07-10 16:43:01','2026-07-10 16:43:01'),('34e95007-c3f5-4d36-862b-90628ebd54b2','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','0f9206c3-a0f4-464e-95d8-14fa3084c032','train',NULL,100,10,1,57,NULL,130,'[\"Clean movement\"]',NULL,'2026-07-20 11:39:18','2026-07-20 11:39:39','2026-07-20 11:39:39'),('360153e5-9c21-450a-aca8-5243c8c5b38f','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,75,0,1,14,NULL,75,'[\"Hold Position\", \"Back posture\", \"Camera setup\"]',NULL,'2026-06-29 12:47:22','2026-06-29 12:47:23','2026-06-29 12:47:23'),('36f01dcf-2922-446b-bd49-e3cc12eefc01','0ac73e72-8181-4598-9585-4847c2782f56','e27c9e80-2eff-45c5-83df-993abb888df5','train',NULL,78,0,1,64,NULL,78,'[\"Body Detected. Move Through The Full Rep Range.\", \"Press Overhead Fully. Keep Smooth Control.\", \"Rep Not Counted Correct Highlighted Form\"]',NULL,'2026-06-29 15:32:03','2026-06-29 15:32:04','2026-06-29 15:32:04'),('3737dc8c-ec30-4430-a8d8-d4a969b0e4b6','0ac73e72-8181-4598-9585-4847c2782f56','0eafe471-1d5c-4b5e-a513-e03d39e3d46f','train',NULL,52,0,1,22,NULL,52,'[\"Back posture\", \"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\"]',NULL,'2026-06-30 11:43:14','2026-06-30 11:43:16','2026-06-30 11:43:16'),('374b2201-ee91-4fda-995c-5fff3222a806','707e8883-6fc2-4be0-84e6-cd24f28bddbd','94f19831-9b37-40ac-8129-5aa2ce7ec0aa','train',NULL,100,5,1,25,NULL,150,'[\"Shoulder position\"]',NULL,'2026-07-09 11:12:45','2026-07-09 11:12:46','2026-07-09 11:12:46'),('37f05841-9101-4757-99b6-0d21b21826ec','2b831991-3d20-4dd4-8864-21e813f51617','c421248c-706c-46fe-b73e-d016937bfdfa','train',NULL,52,0,1,176,NULL,52,'[\"Camera setup\", \"Hold Position\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-24 13:32:45','2026-06-24 13:32:46','2026-06-24 13:32:46'),('3badddde-3478-4696-ab0c-3c41f843f79e','0ac73e72-8181-4598-9585-4847c2782f56','0f9206c3-a0f4-464e-95d8-14fa3084c032','train',NULL,100,10,1,23,NULL,200,'[\"Clean movement\"]',NULL,'2026-07-20 12:14:41','2026-07-20 12:14:43','2026-07-20 12:14:43'),('40af56d7-e689-43a6-a1d0-a9db6f93e52a','2b831991-3d20-4dd4-8864-21e813f51617','0a9e0ed6-81d9-4395-a0ed-8454af7792df','train',NULL,78,0,1,58,NULL,78,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"Pose Detection Failed\"]',NULL,'2026-06-24 11:05:42','2026-06-24 11:05:44','2026-06-24 11:05:44'),('42e21acb-c8a5-409b-8f2d-c7eb750945de','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','c144ba27-8353-4411-b80f-a56747999111','train',NULL,100,2,1,104,NULL,120,'[\"Lift Hips Into Pike Position\", \"Camera setup\", \"Shoulder position\"]',NULL,'2026-07-06 14:04:05','2026-07-06 14:04:06','2026-07-06 14:04:06'),('42faa58f-efbd-4956-baa9-e1ec9bd423ab','0ac73e72-8181-4598-9585-4847c2782f56','4ad754fd-05c7-448c-8c33-9d089ad454ad','train',NULL,73,0,1,22,NULL,73,'[\"Camera setup\", \"Correct: Stop The Other Movement And Return To Your Assigned Exercise\", \"Knee tracking\"]',NULL,'2026-07-10 16:53:31','2026-07-10 16:53:33','2026-07-10 16:53:33'),('4396293c-fd3b-4d01-a882-0e41c8900d68','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,49,0,1,22,NULL,49,'[\"Body Detected. Move Through The Full Rep Range.\", \"Shoulder position\", \"No Body Detected\"]',NULL,'2026-06-30 11:47:03','2026-06-30 11:47:05','2026-06-30 11:47:05'),('43f16404-f36d-448c-875d-0e54f3afaa24','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,75,0,1,21,NULL,75,'[\"Back posture\", \"Hold Position\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-30 09:24:12','2026-06-30 09:24:13','2026-06-30 09:24:13'),('44d84c6a-e7a2-4470-998c-255c19fa1dbc','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,75,0,1,22,NULL,75,'[\"Back posture\", \"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-29 15:23:30','2026-06-29 15:23:31','2026-06-29 15:23:31'),('45dc0c63-7a65-4904-9cd4-47cded8d7d93','707e8883-6fc2-4be0-84e6-cd24f28bddbd','c144ba27-8353-4411-b80f-a56747999111','train',NULL,78,4,1,36,NULL,118,'[\"Lift Hips Into Pike Position\"]',NULL,'2026-07-08 14:28:29','2026-07-08 14:28:32','2026-07-08 14:28:32'),('489df6a8-1709-47ea-ab81-834dd6b61e6b','707e8883-6fc2-4be0-84e6-cd24f28bddbd','0112ee81-a37f-42fa-9f54-42cef106cace','train',NULL,100,10,1,75,NULL,200,'[\"Pose Detection Failed\", \"Move Through The Full Range\"]',NULL,'2026-07-14 17:30:21','2026-07-14 17:30:22','2026-07-14 17:30:22'),('4a52e517-1f29-453b-abba-f35acfba3052','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,4433,NULL,52,'[\"Camera setup\", \"Hold Position\", \"Back posture\"]',NULL,'2026-06-29 12:29:24','2026-06-29 12:29:26','2026-06-29 12:29:26'),('4b56b590-f5d5-4e3f-b92e-8677cbeb6419','707e8883-6fc2-4be0-84e6-cd24f28bddbd','e27c9e80-2eff-45c5-83df-993abb888df5','train',NULL,100,12,1,72,NULL,220,'[\"Press Overhead Fully\"]',NULL,'2026-07-08 15:25:35','2026-07-08 15:25:37','2026-07-08 15:25:37'),('4da039bf-7f42-485c-9315-e5e4c4a8be0a','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,16,1,283,NULL,52,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"Hold Position\"]',NULL,'2026-06-30 05:36:58','2026-06-30 05:36:59','2026-06-30 05:36:59'),('4e07dbc9-63ee-4814-bc83-3527a10f5f1d','0ac73e72-8181-4598-9585-4847c2782f56','c144ba27-8353-4411-b80f-a56747999111','train',NULL,82,2,1,26,NULL,82,'[\"Back posture\"]',NULL,'2026-07-10 16:32:36','2026-07-10 16:32:38','2026-07-10 16:32:38'),('4f4dede4-df0c-4b4e-9d33-caf813499205','0ac73e72-8181-4598-9585-4847c2782f56','559bfc32-4d6b-4a8e-aad3-c465f89d13e0','train',NULL,52,2,1,25,NULL,52,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\"]',NULL,'2026-06-29 08:44:39','2026-06-29 08:44:41','2026-06-29 08:44:41'),('4fa896a1-52f5-43c3-9121-19539f91b424','2b831991-3d20-4dd4-8864-21e813f51617','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,52,2,1,77,NULL,52,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"Use A Fuller Range. Keep Smooth Control.\"]',NULL,'2026-06-24 11:22:26','2026-06-24 11:22:27','2026-06-24 11:22:27'),('5092f7d6-abd5-4d56-ad8b-fd98da3f15b1','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,100,0,1,17,NULL,100,'[\"No Body Detected\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-29 06:39:56','2026-06-29 06:39:58','2026-06-29 06:39:58'),('51490d98-aff7-4fe6-a782-f52cebdb9209','0ac73e72-8181-4598-9585-4847c2782f56','e27c9e80-2eff-45c5-83df-993abb888df5','train',NULL,49,1,1,158,NULL,49,'[\"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\", \"Shoulder position\"]',NULL,'2026-06-30 12:03:58','2026-06-30 12:04:01','2026-06-30 12:04:01'),('518a0eb2-cac9-4df4-9a41-75517322c306','49f86a6b-ba79-436f-9895-a64f4735b5f4','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,7,1,39,NULL,122,'[\"Hold Position. Keep Smooth Control.\", \"Back posture\", \"Camera setup\"]',NULL,'2026-07-03 09:35:29','2026-07-03 09:35:30','2026-07-03 09:35:30'),('51f564d6-43e5-4d38-885c-caa5a955f977','2b831991-3d20-4dd4-8864-21e813f51617','36977cbc-7ae7-4d27-beb0-e2d2889126c1','train',NULL,52,0,1,8,NULL,52,'[\"Camera setup\", \"Hold Position\"]',NULL,'2026-06-24 18:56:27','2026-06-24 18:56:28','2026-06-24 18:56:28'),('54988a91-21cf-474b-930b-280df1e2efa7','9a274228-3432-4fb9-bf8c-6c8ec1beac87','36977cbc-7ae7-4d27-beb0-e2d2889126c1','train',NULL,52,0,1,6,NULL,52,'[\"Camera setup\"]',NULL,'2026-07-14 14:57:23','2026-07-14 14:57:24','2026-07-14 14:57:24'),('56161285-5c92-40a2-aaa0-6f350ad84daa','0ac73e72-8181-4598-9585-4847c2782f56','eeefad65-8dc5-4b90-b29d-3527d4294555','train',NULL,52,3,1,15,NULL,52,'[\"Body Detected. Move Through The Full Rep Range.\", \"Camera setup\"]',NULL,'2026-06-30 11:58:48','2026-06-30 11:58:50','2026-06-30 11:58:50'),('56f1b728-a5c9-4699-98e9-ed2d79a6aeab','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,52,0,1,54,NULL,52,'[\"Hold Position\", \"Body Detected. Move Through The Full Rep Range.\", \"Shoulder position\"]',NULL,'2026-06-30 09:25:16','2026-06-30 09:25:17','2026-06-30 09:25:17'),('58ddbd99-048c-4c19-9559-f22ca4e1b0e4','0ac73e72-8181-4598-9585-4847c2782f56','4ad754fd-05c7-448c-8c33-9d089ad454ad','train',NULL,29,2,1,117,NULL,29,'[\"Stance control\", \"Shoulder position\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-07-01 09:25:43','2026-07-01 09:25:45','2026-07-01 09:25:45'),('58f0719c-809a-4cfe-b36d-515305308dc0','707e8883-6fc2-4be0-84e6-cd24f28bddbd','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,53,0,1,53,NULL,53,'[\"Back posture\", \"Shoulder position\", \"Correct: Fix The Red Highlighted Body Parts, Then Repeat The Rep\"]',NULL,'2026-07-09 11:05:06','2026-07-09 11:05:07','2026-07-09 11:05:07'),('5941bfbf-25fe-4768-b755-b625bae82dfd','707e8883-6fc2-4be0-84e6-cd24f28bddbd','c144ba27-8353-4411-b80f-a56747999111','train',NULL,100,2,1,19,NULL,120,'[\"Clean movement\"]',NULL,'2026-07-13 09:27:09','2026-07-13 09:27:10','2026-07-13 09:27:10'),('5b7ba983-1025-4305-8603-e40abb2cb717','0ac73e72-8181-4598-9585-4847c2782f56','1c98c98d-e943-489d-b792-7e7b20394e36','train',NULL,52,0,1,228,NULL,52,'[\"Camera setup\", \"Arm path\", \"Hold Position\"]',NULL,'2026-06-29 14:36:03','2026-06-29 14:36:05','2026-06-29 14:36:05'),('5bac9f8f-752a-4957-b3df-483114c757a8','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,49,0,1,59,NULL,49,'[\"Shoulder position\", \"Body Detected. Move Through The Full Rep Range.\", \"Lower Fully. Keep Smooth Control.\"]',NULL,'2026-06-29 06:11:09','2026-06-29 06:11:11','2026-06-29 06:11:11'),('5d4ee2e8-66b9-4f54-826b-ee204be5313c','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,65,0,1,22,NULL,65,'[\"Body Detected. Move Through The Full Rep Range.\", \"Hold Position\", \"Back posture\"]',NULL,'2026-06-29 16:19:49','2026-06-29 16:19:50','2026-06-29 16:19:50'),('5d7ef60a-ef5b-4ebd-b084-2fb7ee11b733','707e8883-6fc2-4be0-84e6-cd24f28bddbd','559bfc32-4d6b-4a8e-aad3-c465f89d13e0','train',NULL,78,6,1,36,NULL,78,'[\"Back posture\"]',NULL,'2026-07-08 15:27:03','2026-07-08 15:27:04','2026-07-08 15:27:04'),('5e3c80ed-ca63-41c2-a10a-8c50da3a36fa','707e8883-6fc2-4be0-84e6-cd24f28bddbd','0eafe471-1d5c-4b5e-a513-e03d39e3d46f','train',NULL,78,5,1,174,NULL,128,'[\"Back posture\"]',NULL,'2026-07-17 11:29:29','2026-07-17 11:29:30','2026-07-17 11:29:30'),('5f3ee22c-80cb-48b6-bf0f-89f140ff71fd','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,13,NULL,52,'[\"No Body Detected. Keep Smooth Control.\", \"Back posture\", \"Hold Position. Keep Smooth Control.\"]',NULL,'2026-07-03 15:23:17','2026-07-03 15:23:19','2026-07-03 15:23:19'),('5fc9c08f-0688-450e-9ba3-70078d989f74','0ac73e72-8181-4598-9585-4847c2782f56','e27c9e80-2eff-45c5-83df-993abb888df5','train',NULL,100,0,1,98,NULL,100,'[\"Body Detected. Move Through The Full Rep Range.\", \"Hold Position\", \"Rep Not Counted Correct Highlighted Form\"]',NULL,'2026-06-30 09:27:09','2026-06-30 09:27:13','2026-06-30 09:27:13'),('62710b14-d102-4446-b79b-6ca919c3d8d5','0ac73e72-8181-4598-9585-4847c2782f56','c421248c-706c-46fe-b73e-d016937bfdfa','train',NULL,78,0,1,32,NULL,78,'[\"Camera setup\"]',NULL,'2026-07-08 17:13:56','2026-07-08 17:13:58','2026-07-08 17:13:58'),('62e6d3f2-62d9-4d9d-b480-d5eac3c66043','0ac73e72-8181-4598-9585-4847c2782f56','888594f4-f2ca-4038-b088-d8b4da1212e8','train',NULL,78,1,1,47,NULL,78,'[\"Body Detected. Move Through The Full Rep Range.\", \"Hold Position\", \"Camera setup\"]',NULL,'2026-06-29 15:25:39','2026-06-29 15:25:40','2026-06-29 15:25:40'),('63eea48e-6f94-4239-afc5-a18a10186138','707e8883-6fc2-4be0-84e6-cd24f28bddbd','c421248c-706c-46fe-b73e-d016937bfdfa','train',NULL,55,3,1,112,NULL,85,'[\"Knee tracking\"]',NULL,'2026-07-08 14:54:39','2026-07-08 14:54:40','2026-07-08 14:54:40'),('6503c60a-8a4c-4f5b-a6c6-c0a38bbed7a0','0ac73e72-8181-4598-9585-4847c2782f56','7e0ae5f4-75c3-4ba0-8224-5472d9667281','train',NULL,52,0,1,73,NULL,52,'[\"Keep Hips Level\", \"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\"]',NULL,'2026-07-01 06:14:29','2026-07-01 06:14:31','2026-07-01 06:14:31'),('655c744d-fc84-4a13-a9be-492a8cf26e09','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,82,7,1,17,NULL,82,'[\"Camera setup\"]',NULL,'2026-07-08 10:50:58','2026-07-08 10:51:00','2026-07-08 10:51:00'),('660a031d-7dfd-4fd9-99e3-81dcc7e4d3cf','49f86a6b-ba79-436f-9895-a64f4735b5f4','0f9206c3-a0f4-464e-95d8-14fa3084c032','train',NULL,100,10,1,30,NULL,200,'[\"Back posture\", \"Knee tracking\"]',NULL,'2026-07-20 11:00:47','2026-07-20 11:00:48','2026-07-20 11:00:48'),('67eac9ca-fd0f-4caa-883d-dc1a0980d090','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,3,1,56,NULL,52,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\"]',NULL,'2026-06-24 19:45:12','2026-06-24 19:45:15','2026-06-24 19:45:15'),('69ee96f3-9aa5-4146-b929-d8cc39b95776','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,49,0,1,56,NULL,49,'[\"Lower Fully. Keep Smooth Control.\", \"No Body Detected\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-29 07:56:37','2026-06-29 07:56:39','2026-06-29 07:56:39'),('6ba37c29-f981-4917-9ffc-6822120547d7','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,49,4,1,218,NULL,49,'[\"Hold Position\", \"Lower Fully. Keep Smooth Control.\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-30 10:58:48','2026-06-30 10:58:50','2026-06-30 10:58:50'),('6cdee2ef-8b31-4cc0-a77e-8f9b95cf7b3d','707e8883-6fc2-4be0-84e6-cd24f28bddbd','4ad754fd-05c7-448c-8c33-9d089ad454ad','train',NULL,60,8,1,158,NULL,60,'[\"Show Standing Leg From Hip To Ankle\", \"Correct: Lift The Non Working Leg Clear Off The Ground\", \"Depth control\"]',NULL,'2026-07-17 10:50:10','2026-07-17 10:50:12','2026-07-17 10:50:12'),('6f43aee2-ced7-4f44-b2e2-7935cf31442a','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,4432,NULL,52,'[\"Camera setup\", \"Hold Position\", \"Back posture\"]',NULL,'2026-06-29 12:29:23','2026-06-29 12:29:26','2026-06-29 12:29:26'),('6f50b47c-fad1-4a85-bf82-d2ca4e01e312','707e8883-6fc2-4be0-84e6-cd24f28bddbd','69a3e913-9c45-4e9b-94aa-e2a6773bbbd8','train',NULL,100,10,1,31,NULL,190,'[\"Shoulder position\", \"Knee tracking\", \"Correct: Keep Pelvis Level Don\'t Let One Hip Drop\"]',NULL,'2026-07-17 15:56:30','2026-07-17 15:56:31','2026-07-17 15:56:31'),('6fdf3111-0a49-40ef-a65e-ef5025a188ed','2b831991-3d20-4dd4-8864-21e813f51617','36977cbc-7ae7-4d27-beb0-e2d2889126c1','train',NULL,16,1,1,76,NULL,16,'[\"Stance control\", \"Hold Position\", \"Camera setup\"]',NULL,'2026-06-24 18:36:54','2026-06-24 18:36:55','2026-06-24 18:36:55'),('71134c16-43c8-46c9-99e8-f8d3e1e28005','0ac73e72-8181-4598-9585-4847c2782f56','888594f4-f2ca-4038-b088-d8b4da1212e8','train',NULL,52,0,1,16,NULL,52,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-29 14:19:54','2026-06-29 14:19:55','2026-06-29 14:19:55'),('72baccb8-961c-403e-951d-7a12431a50d5','0ac73e72-8181-4598-9585-4847c2782f56','0eafe471-1d5c-4b5e-a513-e03d39e3d46f','train',NULL,61,0,1,15,NULL,61,'[\"Back posture\", \"No Body Detected\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-30 11:42:24','2026-06-30 11:42:26','2026-06-30 11:42:26'),('72e556a9-f9dd-46f9-ab76-37f84431176d','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,52,0,1,78,NULL,52,'[\"Camera setup\", \"Back posture\", \"Lower Fully. Keep Smooth Control.\"]',NULL,'2026-06-29 14:19:26','2026-06-29 14:19:27','2026-06-29 14:19:27'),('7547a3a9-08b0-479b-b6df-202948d13044','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,75,0,1,65,NULL,75,'[\"Body Detected. Move Through The Full Rep Range.\", \"Shoulder position\", \"No Body Detected\"]',NULL,'2026-06-29 08:36:23','2026-06-29 08:36:25','2026-06-29 08:36:25'),('771141a4-e184-4904-bdfb-268be72a24af','707e8883-6fc2-4be0-84e6-cd24f28bddbd','c144ba27-8353-4411-b80f-a56747999111','train',NULL,100,4,1,39,NULL,140,'[\"Lift Hips Into Pike Position\"]',NULL,'2026-07-08 14:28:32','2026-07-08 14:28:33','2026-07-08 14:28:33'),('77901fa4-a565-4e40-aed7-cd692ef3a241','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','c144ba27-8353-4411-b80f-a56747999111','train',NULL,52,1,1,50,NULL,62,'[\"Camera setup\", \"Lift Hips Into Pike Position\"]',NULL,'2026-07-06 15:01:11','2026-07-06 15:01:12','2026-07-06 15:01:12'),('77e17383-7dca-4115-991a-8b5e549ab014','2b831991-3d20-4dd4-8864-21e813f51617','0a9e0ed6-81d9-4395-a0ed-8454af7792df','train',NULL,78,0,1,52,NULL,78,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"Pose Detection Failed\"]',NULL,'2026-06-24 11:05:37','2026-06-24 11:05:43','2026-06-24 11:05:43'),('77e2e1a6-fae0-4b87-b139-978457a5287d','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,52,2,1,22,NULL,52,'[\"Back posture\", \"Hold Position\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-30 13:40:12','2026-06-30 13:40:13','2026-06-30 13:40:13'),('7801fc42-3eb9-44d3-8ce9-18d8921af869','0ac73e72-8181-4598-9585-4847c2782f56','e27c9e80-2eff-45c5-83df-993abb888df5','train',NULL,49,6,1,57,NULL,49,'[\"Body Detected. Move Through The Full Rep Range.\", \"Shoulder position\", \"Press Overhead Fully. Keep Smooth Control.\"]',NULL,'2026-06-29 08:37:38','2026-06-29 08:37:40','2026-06-29 08:37:40'),('796fa09e-c370-4086-b888-37f400b87ad4','0ac73e72-8181-4598-9585-4847c2782f56','888594f4-f2ca-4038-b088-d8b4da1212e8','train',NULL,52,1,1,163,NULL,52,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\"]',NULL,'2026-06-30 11:58:16','2026-06-30 11:58:23','2026-06-30 11:58:23'),('7a8878cf-31b2-44f0-8e18-6fab40ae1687','f96faa96-c0d1-48ad-b6e5-28e2220364e2','4ad754fd-05c7-448c-8c33-9d089ad454ad','train',NULL,34,2,1,36,NULL,34,'[\"Stance control\", \"Body Detected. Move Through The Full Rep Range.\", \"Hold Position. Keep Smooth Control.\"]',NULL,'2026-07-02 07:50:58','2026-07-02 07:51:00','2026-07-02 07:51:00'),('7b11a20b-ef8b-4a27-845b-89572c64a796','707e8883-6fc2-4be0-84e6-cd24f28bddbd','0112ee81-a37f-42fa-9f54-42cef106cace','train',NULL,60,10,1,0,NULL,60,'[\"Move Through The Full Range\"]',NULL,'2026-07-14 17:30:54','2026-07-14 17:30:56','2026-07-14 17:30:56'),('7ca3a81d-4512-4da5-a92b-64db555573cc','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,75,0,1,106,NULL,75,'[\"Hold Position\", \"Back posture\", \"Camera setup\"]',NULL,'2026-06-29 12:46:54','2026-06-29 12:46:56','2026-06-29 12:46:56'),('7d5d3d58-0d5c-43eb-809a-ffe3e31d1b7e','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','0f9206c3-a0f4-464e-95d8-14fa3084c032','train',NULL,100,3,1,6,NULL,130,'[\"Clean movement\"]',NULL,'2026-07-20 11:37:18','2026-07-20 11:37:38','2026-07-20 11:37:38'),('7db4b3f5-43dc-4f81-a476-eb082f298d05','0ac73e72-8181-4598-9585-4847c2782f56','b3eefecf-4962-4522-af3e-0eae954ef892','train',NULL,100,10,1,26,NULL,200,'[\"Camera setup\"]',NULL,'2026-07-20 11:55:54','2026-07-20 11:55:55','2026-07-20 11:55:55'),('7f458226-2cbd-4ead-9a65-7d66c9a69895','0ac73e72-8181-4598-9585-4847c2782f56','888594f4-f2ca-4038-b088-d8b4da1212e8','train',NULL,100,1,1,124,NULL,100,'[\"Body Detected. Move Through The Full Rep Range.\", \"Camera setup\", \"Back posture\"]',NULL,'2026-06-30 08:00:26','2026-06-30 08:00:27','2026-06-30 08:00:27'),('7fd86981-76e9-4551-80db-a6ad766d20ec','2b831991-3d20-4dd4-8864-21e813f51617','0a9e0ed6-81d9-4395-a0ed-8454af7792df','train',NULL,78,0,1,57,NULL,78,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"Pose Detection Failed\"]',NULL,'2026-06-24 11:05:42','2026-06-24 11:05:43','2026-06-24 11:05:43'),('7fdb34ea-0d29-4515-8d66-708bc041a76d','61522823-cabf-426f-939c-86b4a293d0e7','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,39,NULL,52,'[\"Hold Position\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-24 21:15:40','2026-06-24 21:15:41','2026-06-24 21:15:41'),('806437a2-2926-4682-9be3-8735f9776368','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,82,0,1,41,NULL,82,'[\"Shoulder position\", \"Body Detected. Move Through The Full Rep Range.\", \"Lower Fully. Keep Smooth Control.\"]',NULL,'2026-06-29 06:24:23','2026-06-29 06:24:25','2026-06-29 06:24:25'),('80984095-a728-4081-8850-146abc11c8f2','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,49,6,1,76,NULL,49,'[\"Hold Position\", \"Back posture\", \"Lower Fully. Keep Smooth Control.\"]',NULL,'2026-06-30 13:39:37','2026-06-30 13:39:38','2026-06-30 13:39:38'),('81b9d599-5323-43b0-95e9-f16e72f6b1c6','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,9,1,131,NULL,52,'[\"Body Detected. Move Through The Full Rep Range.\", \"Hold Position\", \"Camera setup\"]',NULL,'2026-06-29 14:50:59','2026-06-29 14:51:00','2026-06-29 14:51:00'),('82329dcd-64ec-423b-9731-5f77fb5d3d91','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,100,0,1,69,NULL,100,'[\"Pose Detection Failed\", \"Camera setup\", \"Get Ready. Keep Smooth Control.\"]',NULL,'2026-06-29 16:19:13','2026-06-29 16:19:14','2026-06-29 16:19:14'),('82ba69c4-751b-4715-a48f-d5394e57a9df','707e8883-6fc2-4be0-84e6-cd24f28bddbd','1c98c98d-e943-489d-b792-7e7b20394e36','train',NULL,77,5,1,32,NULL,127,'[\"Lower Fully\", \"Arm path\"]',NULL,'2026-07-08 15:30:03','2026-07-08 15:30:04','2026-07-08 15:30:04'),('82fe491f-5259-4b45-ae6d-90293534d625','0ac73e72-8181-4598-9585-4847c2782f56','3a52c682-5111-4698-8ffa-45d70b004522','train',NULL,82,9,1,43,NULL,82,'[\"Body Detected. Move Through The Full Rep Range.\", \"Hold Position. Keep Smooth Control.\", \"Lower Your Hips\"]',NULL,'2026-07-01 06:17:34','2026-07-01 06:17:36','2026-07-01 06:17:36'),('8690e761-981f-4a8d-9c6b-9c87b597f9ca','0ac73e72-8181-4598-9585-4847c2782f56','32d3d42f-e926-4904-a550-d49fa7bdaf62','train',NULL,1,2,1,22,NULL,1,'[\"Hold Position. Keep Smooth Control.\", \"Body Detected. Move Through The Full Rep Range.\", \"Shoulder position\"]',NULL,'2026-07-01 06:12:04','2026-07-01 06:12:06','2026-07-01 06:12:06'),('86d4e6c9-8301-4e4e-9c87-7301d088faeb','2698e971-2b31-4c49-a815-af0e66ecc0eb','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,10,NULL,52,'[\"No Body Detected. Keep Smooth Control.\", \"Camera setup\", \"Hold Position. Keep Smooth Control.\"]',NULL,'2026-07-03 17:37:32','2026-07-03 17:37:33','2026-07-03 17:37:33'),('8792010c-b897-41e1-9e85-a2d83b5a88b8','0ac73e72-8181-4598-9585-4847c2782f56','559bfc32-4d6b-4a8e-aad3-c465f89d13e0','train',NULL,52,4,1,64,NULL,92,'[\"Camera setup\", \"Back posture\"]',NULL,'2026-07-08 11:28:06','2026-07-08 11:28:09','2026-07-08 11:28:09'),('8a97dede-c9c5-4158-8123-bbe1546a8b4f','0ac73e72-8181-4598-9585-4847c2782f56','509880db-396c-428e-908c-59e76e79152b','train',NULL,100,9,1,47,NULL,100,'[\"Body Detected. Move Through The Full Rep Range.\", \"Shoulder position\", \"Arm path\"]',NULL,'2026-07-01 06:16:27','2026-07-01 06:16:29','2026-07-01 06:16:29'),('8ad0dc7f-5890-4a70-8860-342290778852','0ac73e72-8181-4598-9585-4847c2782f56','888594f4-f2ca-4038-b088-d8b4da1212e8','train',NULL,78,4,1,34,NULL,78,'[\"Body Detected. Move Through The Full Rep Range.\", \"Back posture\", \"Hold Position\"]',NULL,'2026-06-29 16:21:26','2026-06-29 16:21:27','2026-06-29 16:21:27'),('8b388a08-ac0d-48e3-aa09-08544dbabd81','707e8883-6fc2-4be0-84e6-cd24f28bddbd','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,55,0,1,65,NULL,55,'[\"No completed reps\"]',NULL,'2026-07-08 15:21:20','2026-07-08 15:21:21','2026-07-08 15:21:21'),('8b712174-f648-4b61-a60f-98ddc9d22076','0ac73e72-8181-4598-9585-4847c2782f56','0a9e0ed6-81d9-4395-a0ed-8454af7792df','train',NULL,52,0,1,28,NULL,52,'[\"No Body Detected\", \"Back posture\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-30 11:44:02','2026-06-30 11:44:07','2026-06-30 11:44:07'),('8bf7f37d-bef7-49fd-a39b-85c18dfe5afa','49f86a6b-ba79-436f-9895-a64f4735b5f4','0f9206c3-a0f4-464e-95d8-14fa3084c032','train',NULL,100,10,1,41,NULL,200,'[\"Clean movement\"]',NULL,'2026-07-20 11:49:15','2026-07-20 11:49:16','2026-07-20 11:49:16'),('8c8ffff4-9bec-41c0-a0ac-cdd0f4bc74a1','0ac73e72-8181-4598-9585-4847c2782f56','888594f4-f2ca-4038-b088-d8b4da1212e8','train',NULL,52,5,1,39,NULL,52,'[\"Body Detected. Move Through The Full Rep Range.\", \"Camera setup\", \"Back posture\"]',NULL,'2026-06-29 13:02:12','2026-06-29 13:02:13','2026-06-29 13:02:13'),('8e7aeb34-6c6a-4843-ba1a-6584934d7101','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,49,4,1,157,NULL,49,'[\"Shoulder position\", \"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\"]',NULL,'2026-06-29 11:52:11','2026-06-29 11:52:13','2026-06-29 11:52:13'),('8f504a18-3c5a-49fc-a502-db6e04d5fa8d','0ac73e72-8181-4598-9585-4847c2782f56','509880db-396c-428e-908c-59e76e79152b','train',NULL,52,9,1,47,NULL,52,'[\"Body Detected. Move Through The Full Rep Range.\", \"Shoulder position\", \"Arm path\"]',NULL,'2026-07-01 06:16:27','2026-07-01 06:16:29','2026-07-01 06:16:29'),('90d96dbc-c70c-40cc-a8c4-3ffef3a79901','707e8883-6fc2-4be0-84e6-cd24f28bddbd','94f19831-9b37-40ac-8129-5aa2ce7ec0aa','train',NULL,100,3,1,21,NULL,130,'[\"Wrong Exercise Perform Push Up, Not Squat\"]',NULL,'2026-07-14 16:22:31','2026-07-14 16:22:32','2026-07-14 16:22:32'),('91dbe122-b0f2-41a3-9084-f79437e393c7','49f86a6b-ba79-436f-9895-a64f4735b5f4','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,100,10,1,47,NULL,200,'[\"Camera setup\", \"Hold Position. Keep Smooth Control.\", \"Back posture\"]',NULL,'2026-07-03 09:44:04','2026-07-03 09:44:05','2026-07-03 09:44:05'),('927e16a6-99ee-4a9b-a035-1353814c12ab','9436a3d9-54ba-4dba-8793-90a45ed999f4','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,52,0,1,15,NULL,52,'[\"Hold Position. Keep Smooth Control.\", \"Back posture\", \"Camera setup\"]',NULL,'2026-07-03 05:19:40','2026-07-03 05:19:42','2026-07-03 05:19:42'),('950fb28f-f776-487d-81f3-f402cf1f3c75','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,4,1,21,NULL,52,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-29 08:40:32','2026-06-29 08:40:34','2026-06-29 08:40:34'),('968e007f-6117-4294-90b4-a2ccda95cf5b','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,55,10,1,115,NULL,55,'[\"Body Detected. Move Through The Full Rep Range.\", \"Hold Position\", \"Pose Detection Failed\"]',NULL,'2026-06-29 15:30:19','2026-06-29 15:30:20','2026-06-29 15:30:20'),('969568da-c93f-4772-bbec-7e8cd19a63c4','0ac73e72-8181-4598-9585-4847c2782f56','32d3d42f-e926-4904-a550-d49fa7bdaf62','train',NULL,65,6,1,61,NULL,65,'[\"Body Detected. Move Through The Full Rep Range.\", \"Press Both Arms Evenly. Keep Smooth Control.\", \"Press To Full Extension\"]',NULL,'2026-06-29 15:24:43','2026-06-29 15:24:44','2026-06-29 15:24:44'),('97596c3b-612e-489c-bef6-058183b73437','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,4433,NULL,52,'[\"Camera setup\", \"Hold Position\", \"Back posture\"]',NULL,'2026-06-29 12:29:24','2026-06-29 12:29:26','2026-06-29 12:29:26'),('9924d8de-5b03-489b-a378-f4af83db5e56','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','559bfc32-4d6b-4a8e-aad3-c465f89d13e0','train',NULL,85,7,1,42,NULL,85,'[\"Camera setup\", \"Back posture\"]',NULL,'2026-07-06 13:50:48','2026-07-06 13:50:49','2026-07-06 13:50:49'),('99c4f530-cbc4-458d-baeb-f5cc773cab16','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,52,0,1,18,NULL,52,'[\"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\", \"Lower Fully. Keep Smooth Control.\"]',NULL,'2026-06-29 06:51:41','2026-06-29 06:51:42','2026-06-29 06:51:42'),('9a1d1bda-17bc-447a-a73f-2998ce785b80','5a90ba96-9815-48bf-b1b5-da33e20826da','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,4,NULL,52,'[\"Hold Position. Keep Smooth Control.\", \"No Body Detected\"]',NULL,'2026-07-02 07:38:04','2026-07-02 07:38:24','2026-07-02 07:38:24'),('9cff36ff-c2e9-4884-a589-1d46275614d4','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,1,2,1,96,NULL,1,'[\"Body Detected. Move Through The Full Rep Range.\", \"Hold Position. Keep Smooth Control.\", \"Shoulder position\"]',NULL,'2026-07-02 08:34:04','2026-07-02 08:34:06','2026-07-02 08:34:06'),('9e9e646f-412c-46f9-bcfe-2e6e181e8e35','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,0,NULL,52,'[\"No completed reps\"]',NULL,'2026-06-24 19:43:11','2026-06-24 19:43:13','2026-06-24 19:43:13'),('a10a111f-3915-4b49-ba48-b7db6e6dd9aa','2b831991-3d20-4dd4-8864-21e813f51617','c144ba27-8353-4411-b80f-a56747999111','train',NULL,52,0,1,36,NULL,52,'[\"Body Detected. Move Through The Full Rep Range.\", \"Keep Body Straight. Keep Smooth Control.\", \"Camera setup\"]',NULL,'2026-06-24 11:59:57','2026-06-24 11:59:58','2026-06-24 11:59:58'),('a1eda0a8-2d12-4623-8407-03596c2877d2','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,82,0,1,36,NULL,82,'[\"No Body Detected\", \"Lower Fully. Keep Smooth Control.\", \"Shoulder position\"]',NULL,'2026-06-29 06:39:28','2026-06-29 06:39:30','2026-06-29 06:39:30'),('a3135dd5-d7b0-46a2-b43d-6cdba68a76e9','0ac73e72-8181-4598-9585-4847c2782f56','e27c9e80-2eff-45c5-83df-993abb888df5','train',NULL,49,0,1,43,NULL,49,'[\"Body Detected. Move Through The Full Rep Range.\", \"Shoulder position\", \"Rep Not Counted Correct Highlighted Form\"]',NULL,'2026-06-29 06:12:35','2026-06-29 06:12:37','2026-06-29 06:12:37'),('a33f5ceb-500b-42b3-bfd1-219a06e3e590','829d351c-d2db-417e-8184-748ec074e7d6','c144ba27-8353-4411-b80f-a56747999111','train',NULL,49,0,1,12,NULL,49,'[\"Camera setup\", \"Shoulder position\", \"Hold Position. Keep Smooth Control.\"]',NULL,'2026-07-01 08:03:29','2026-07-01 08:03:49','2026-07-01 08:03:49'),('a37cd083-b13a-44af-9251-9fcf556f4be0','707e8883-6fc2-4be0-84e6-cd24f28bddbd','94f19831-9b37-40ac-8129-5aa2ce7ec0aa','train',NULL,52,1,1,36,NULL,62,'[\"No Body Detected. Keep Smooth Control.\", \"Camera setup\", \"Hold Position. Keep Smooth Control.\"]',NULL,'2026-07-06 11:15:25','2026-07-06 11:15:26','2026-07-06 11:15:26'),('a40e995c-6e73-48d5-8b3a-6ed2f3f6f25f','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,100,0,1,99,NULL,100,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"Hold Position\"]',NULL,'2026-06-29 14:32:01','2026-06-29 14:32:02','2026-06-29 14:32:02'),('a447acb4-d4ff-4550-84fb-90caacc30732','707e8883-6fc2-4be0-84e6-cd24f28bddbd','c144ba27-8353-4411-b80f-a56747999111','train',NULL,100,10,1,58,NULL,200,'[\"Correct: Stop The Other Movement And Return To Your Assigned Exercise\", \"Arm path\"]',NULL,'2026-07-14 16:06:28','2026-07-14 16:06:29','2026-07-14 16:06:29'),('a48554d0-94c7-426d-acf2-a1554011e682','0ac73e72-8181-4598-9585-4847c2782f56','94f19831-9b37-40ac-8129-5aa2ce7ec0aa','train',NULL,100,2,1,11,NULL,100,'[\"Body Detected. Move Through The Full Rep Range.\", \"Camera setup\", \"Hold Position\"]',NULL,'2026-06-30 09:30:26','2026-06-30 09:30:27','2026-06-30 09:30:27'),('a4de8a08-c765-4fca-bc7f-979f5acd18c7','0ac73e72-8181-4598-9585-4847c2782f56','36977cbc-7ae7-4d27-beb0-e2d2889126c1','train',NULL,52,8,1,64,NULL,52,'[\"Body Detected. Move Through The Full Rep Range.\", \"Camera setup\", \"Stance control\"]',NULL,'2026-06-29 08:45:57','2026-06-29 08:45:59','2026-06-29 08:45:59'),('a5ecbd6e-7d51-4026-b043-9b17bc00c8c6','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,52,4,1,1669,NULL,52,'[\"Body Detected. Move Through The Full Rep Range.\", \"Camera setup\", \"Hold Position\"]',NULL,'2026-06-29 08:56:24','2026-06-29 08:56:25','2026-06-29 08:56:25'),('a7a06641-0c7a-4675-a1e4-185c14d64fda','2b831991-3d20-4dd4-8864-21e813f51617','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,94,3,1,50,NULL,94,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"Back posture\"]',NULL,'2026-06-24 11:06:52','2026-06-24 11:06:53','2026-06-24 11:06:53'),('a7a1600d-55da-465d-bb16-d4cd3d8c75fa','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,100,4,1,37,NULL,100,'[\"Body Detected. Move Through The Full Rep Range.\", \"Hold Position. Keep Smooth Control.\", \"Arm path\"]',NULL,'2026-06-30 12:32:51','2026-06-30 12:32:53','2026-06-30 12:32:53'),('a8b46cb5-21f8-495e-a04e-3326cf287d1f','2b831991-3d20-4dd4-8864-21e813f51617','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,52,16,1,91,NULL,52,'[\"Camera setup\", \"Hold Position\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-24 12:32:43','2026-06-24 12:32:46','2026-06-24 12:32:46'),('a9266062-3797-4b12-8f18-e4ae3ad53107','707e8883-6fc2-4be0-84e6-cd24f28bddbd','eeefad65-8dc5-4b90-b29d-3527d4294555','train',NULL,78,4,1,33,NULL,78,'[\"Back posture\"]',NULL,'2026-07-08 15:27:50','2026-07-08 15:27:51','2026-07-08 15:27:51'),('a95b0d87-32d7-4377-bbc0-7897d8ae0372','707e8883-6fc2-4be0-84e6-cd24f28bddbd','0eafe471-1d5c-4b5e-a513-e03d39e3d46f','train',NULL,100,10,1,124,NULL,190,'[\"Back posture\"]',NULL,'2026-07-17 11:21:37','2026-07-17 11:21:38','2026-07-17 11:21:38'),('a9b8a751-c00f-4c4f-8e0e-2d5d10635b2d','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,8,1,108,NULL,52,'[\"Body Detected. Move Through The Full Rep Range.\", \"Camera setup\", \"Pose Detection Failed\"]',NULL,'2026-06-29 13:00:05','2026-06-29 13:00:08','2026-06-29 13:00:08'),('aa3e1722-a780-45cc-8874-4ebdeecf868f','707e8883-6fc2-4be0-84e6-cd24f28bddbd','0112ee81-a37f-42fa-9f54-42cef106cace','train',NULL,100,3,1,4,NULL,130,'[\"Move Through The Full Range\"]',NULL,'2026-07-14 16:25:05','2026-07-14 16:25:06','2026-07-14 16:25:06'),('aaf4f7b6-1065-4474-ad29-0316a681e86d','0ac73e72-8181-4598-9585-4847c2782f56','f3922cdc-a715-4382-9d1b-4f58a3c5f249','train',NULL,82,10,1,34,NULL,82,'[\"Move Through The Full Range\"]',NULL,'2026-07-14 16:35:36','2026-07-14 16:35:38','2026-07-14 16:35:38'),('ab419181-a1e9-4a92-9817-3afd731ea7c3','707e8883-6fc2-4be0-84e6-cd24f28bddbd','32d3d42f-e926-4904-a550-d49fa7bdaf62','train',NULL,100,5,1,45,NULL,150,'[\"Press To Full Extension\", \"Press Both Arms Evenly\"]',NULL,'2026-07-08 15:24:14','2026-07-08 15:24:15','2026-07-08 15:24:15'),('abe8a96c-c107-4da3-ac8b-0f6ce951c99b','5a90ba96-9815-48bf-b1b5-da33e20826da','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,4,NULL,52,'[\"Hold Position. Keep Smooth Control.\", \"Camera setup\"]',NULL,'2026-07-02 07:36:56','2026-07-02 07:37:16','2026-07-02 07:37:16'),('adcf2488-5147-46ff-bdc5-91c687075b09','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,82,30,1,88,NULL,82,'[\"Camera setup\"]',NULL,'2026-07-08 10:59:35','2026-07-08 10:59:38','2026-07-08 10:59:38'),('af242c36-26ab-46f2-acac-baa485fcff04','707e8883-6fc2-4be0-84e6-cd24f28bddbd','559bfc32-4d6b-4a8e-aad3-c465f89d13e0','train',NULL,1,0,1,3,NULL,1,'[\"Shoulder position\"]',NULL,'2026-07-09 16:03:28','2026-07-09 16:03:30','2026-07-09 16:03:30'),('af639dbd-4aec-4b4e-af0f-2c8f7351f485','707e8883-6fc2-4be0-84e6-cd24f28bddbd','0112ee81-a37f-42fa-9f54-42cef106cace','train',NULL,100,0,1,7,NULL,100,'[\"Move Through The Full Range\"]',NULL,'2026-07-09 10:29:23','2026-07-09 10:29:24','2026-07-09 10:29:24'),('afc464fb-d533-4e69-be7b-c928b66dee14','707e8883-6fc2-4be0-84e6-cd24f28bddbd','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,4,1,59,NULL,92,'[\"Open Arms And Legs Wider\"]',NULL,'2026-07-08 12:55:29','2026-07-08 12:55:30','2026-07-08 12:55:30'),('b00bfa8f-50f6-4fdc-ae1f-d24aa90cf48c','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,4433,NULL,52,'[\"Camera setup\", \"Hold Position\", \"Back posture\"]',NULL,'2026-06-29 12:29:23','2026-06-29 12:29:31','2026-06-29 12:29:31'),('b18e3be9-18fe-42ee-b818-3281fdb659ce','61522823-cabf-426f-939c-86b4a293d0e7','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,1,NULL,52,'[\"Hold Position\"]',NULL,'2026-06-24 21:15:59','2026-06-24 21:16:00','2026-06-24 21:16:00'),('b23975d5-843f-4fc0-91fc-85df39efca9e','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,49,0,1,34,NULL,49,'[\"No Body Detected\", \"Lower Fully. Keep Smooth Control.\", \"Shoulder position\"]',NULL,'2026-06-29 09:10:18','2026-06-29 09:10:20','2026-06-29 09:10:20'),('b27c6ebf-3ae3-434f-8492-3baced42c33c','707e8883-6fc2-4be0-84e6-cd24f28bddbd','c144ba27-8353-4411-b80f-a56747999111','train',NULL,100,4,1,37,NULL,140,'[\"Lift Hips Into Pike Position\"]',NULL,'2026-07-08 14:28:30','2026-07-08 14:28:32','2026-07-08 14:28:32'),('b3653841-47fe-4ea6-a9f3-67dc12ba4efc','707e8883-6fc2-4be0-84e6-cd24f28bddbd','3a52c682-5111-4698-8ffa-45d70b004522','train',NULL,100,10,1,40,NULL,200,'[\"Shoulder position\", \"Arm path\"]',NULL,'2026-07-14 16:19:43','2026-07-14 16:19:44','2026-07-14 16:19:44'),('b36b23bc-ec3c-4571-85a3-4ffc25c45bd8','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,3,1,16,NULL,52,'[\"Open Arms And Legs Wider\"]',NULL,'2026-07-08 11:14:38','2026-07-08 11:14:40','2026-07-08 11:14:40'),('b3cec54f-ee54-435a-9e9d-ba28b3603a4c','9436a3d9-54ba-4dba-8793-90a45ed999f4','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,37,NULL,52,'[\"Camera setup\", \"Hold Position\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-07-03 05:14:47','2026-07-03 05:14:48','2026-07-03 05:14:48'),('b40cb99e-f88f-4a8f-b954-6e13f9e8c9f4','707e8883-6fc2-4be0-84e6-cd24f28bddbd','36977cbc-7ae7-4d27-beb0-e2d2889126c1','train',NULL,50,4,1,31,NULL,90,'[\"Shoulder position\", \"Don\'t Move Arms Behind\", \"Camera setup\"]',NULL,'2026-07-08 15:26:17','2026-07-08 15:26:18','2026-07-08 15:26:18'),('b5083344-386a-4bea-8cf8-8e64daa63d32','9436a3d9-54ba-4dba-8793-90a45ed999f4','94f19831-9b37-40ac-8129-5aa2ce7ec0aa','train',NULL,49,3,1,116,NULL,79,'[\"Camera setup\", \"Shoulder position\", \"Keep Body Straight\"]',NULL,'2026-07-10 10:52:08','2026-07-10 10:52:29','2026-07-10 10:52:29'),('b55735cf-c9dc-4485-a58f-33b5c52d32cc','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,100,0,1,64,NULL,100,'[\"Body Detected. Move Through The Full Rep Range.\", \"Shoulder position\", \"No Body Detected\"]',NULL,'2026-06-30 11:46:31','2026-06-30 11:46:33','2026-06-30 11:46:33'),('b5c11a1a-6113-4fe6-b91a-3e89fa4829a9','e304ca99-06fb-4c5d-818c-48ea20ad3aeb','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,5,1,28,NULL,52,'[\"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\", \"Camera setup\"]',NULL,'2026-06-29 11:05:01','2026-06-29 11:05:21','2026-06-29 11:05:21'),('b7679921-5b0f-4ab2-a8df-790892b96a16','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,152,NULL,52,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"Pose Detection Failed\"]',NULL,'2026-06-29 14:17:56','2026-06-29 14:17:57','2026-06-29 14:17:57'),('b925c9e1-7fae-47e5-864a-34c0b24f26fe','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,80,0,1,22,NULL,80,'[\"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\", \"Shoulder position\"]',NULL,'2026-06-30 11:52:43','2026-06-30 11:52:46','2026-06-30 11:52:46'),('ba3cf6df-22a9-4c30-af22-4041959023ce','707e8883-6fc2-4be0-84e6-cd24f28bddbd','0112ee81-a37f-42fa-9f54-42cef106cace','train',NULL,100,10,1,82,NULL,200,'[\"Move Through The Full Range\", \"Raise Arms Up, Then Lower\"]',NULL,'2026-07-14 18:11:17','2026-07-14 18:11:19','2026-07-14 18:11:19'),('bbcab4b7-0571-4143-b5c6-dc86f0991970','2b831991-3d20-4dd4-8864-21e813f51617','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,52,12,1,83,NULL,52,'[\"Camera setup\", \"Hold Position\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-24 13:16:48','2026-06-24 13:16:50','2026-06-24 13:16:50'),('bf49b5ab-aea8-4ac4-956a-26fbeabfdf4a','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,100,0,1,25,NULL,100,'[\"No Body Detected\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-29 06:24:59','2026-06-29 06:25:01','2026-06-29 06:25:01'),('c180fc76-f105-4434-a915-33901ed56deb','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,12,1,201,NULL,52,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"Hold Position\"]',NULL,'2026-06-30 06:02:03','2026-06-30 06:02:04','2026-06-30 06:02:04'),('c32100b4-50a7-4ea2-ad46-062010477c0a','0ac73e72-8181-4598-9585-4847c2782f56','578b3dbd-dad4-40f2-a363-ae50b52cdd52','train',NULL,100,0,1,37,NULL,100,'[\"Correct: Stop The Other Movement And Return To Your Assigned Exercise\", \"Back posture\"]',NULL,'2026-07-10 16:40:54','2026-07-10 16:40:56','2026-07-10 16:40:56'),('c41e4cd3-83b9-47be-9324-567d488830d2','2b831991-3d20-4dd4-8864-21e813f51617','c144ba27-8353-4411-b80f-a56747999111','train',NULL,52,24,1,64,NULL,52,'[\"Body Detected. Move Through The Full Rep Range.\", \"Hold Position\", \"Camera setup\"]',NULL,'2026-06-24 13:29:34','2026-06-24 13:29:35','2026-06-24 13:29:35'),('c5a7fdf3-94f4-435b-a329-2ee25e673ee4','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,85,10,1,17,NULL,85,'[\"Stance control\"]',NULL,'2026-07-20 10:50:20','2026-07-20 10:50:22','2026-07-20 10:50:22'),('c71201af-36b4-4e7b-8261-29d916df77c8','0ac73e72-8181-4598-9585-4847c2782f56','0f9206c3-a0f4-464e-95d8-14fa3084c032','train',NULL,100,10,1,43,NULL,200,'[\"Knee tracking\"]',NULL,'2026-07-20 10:48:55','2026-07-20 10:48:57','2026-07-20 10:48:57'),('c838f7cd-ebf9-428f-8c58-ed5f480240d8','5a90ba96-9815-48bf-b1b5-da33e20826da','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,1,0,1,1,NULL,1,'[\"No Body Detected\", \"Hold Position. Keep Smooth Control.\"]',NULL,'2026-07-02 07:37:38','2026-07-02 07:37:58','2026-07-02 07:37:58'),('ce0d774e-771e-45da-9266-5dc20734ddde','2b831991-3d20-4dd4-8864-21e813f51617','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,52,20,1,119,NULL,52,'[\"Camera setup\", \"Hold Position\", \"Body Detected. Move Through The Full Rep Range.\"]',NULL,'2026-06-24 12:43:33','2026-06-24 12:43:34','2026-06-24 12:43:34'),('ced2033c-367e-4d4a-bcff-80976fe3da3c','707e8883-6fc2-4be0-84e6-cd24f28bddbd','eeefad65-8dc5-4b90-b29d-3527d4294555','train',NULL,52,12,1,56,NULL,92,'[\"Correct: Stop The Other Movement And Return To Your Assigned Exercise\", \"Back posture\"]',NULL,'2026-07-10 14:46:03','2026-07-10 14:46:05','2026-07-10 14:46:05'),('cedefd2a-fe83-4646-b89c-7694b2badf02','e304ca99-06fb-4c5d-818c-48ea20ad3aeb','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,14,NULL,52,'[\"Camera setup\"]',NULL,'2026-06-29 11:07:10','2026-06-29 11:07:30','2026-06-29 11:07:30'),('cf5077e2-c093-443c-bb1c-8ddde6a4e690','0ac73e72-8181-4598-9585-4847c2782f56','c144ba27-8353-4411-b80f-a56747999111','train',NULL,85,0,1,35,NULL,85,'[\"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\", \"Shoulder position\"]',NULL,'2026-06-30 11:38:46','2026-06-30 11:38:48','2026-06-30 11:38:48'),('d0260bba-4a30-4462-9e6a-2ecbcb1982fa','0ac73e72-8181-4598-9585-4847c2782f56','e27c9e80-2eff-45c5-83df-993abb888df5','train',NULL,78,7,1,30,NULL,78,'[\"Body Detected. Move Through The Full Rep Range.\", \"Press Overhead Fully. Keep Smooth Control.\", \"Hold Position\"]',NULL,'2026-06-29 16:22:06','2026-06-29 16:22:07','2026-06-29 16:22:07'),('d1148186-3f50-493c-85f7-c9fcfb3ca92e','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,13,NULL,52,'[\"Hold Position. Keep Smooth Control.\", \"Back posture\", \"No Body Detected. Keep Smooth Control.\"]',NULL,'2026-07-04 09:47:09','2026-07-04 09:47:11','2026-07-04 09:47:11'),('d197ebae-4b0f-45ee-a95a-ea67804727a0','707e8883-6fc2-4be0-84e6-cd24f28bddbd','3a52c682-5111-4698-8ffa-45d70b004522','train',NULL,40,27,1,121,NULL,310,'[\"Shoulder position\", \"Arm path\", \"Correct: Drop Hips Body Should Be One Straight Plank Line\"]',NULL,'2026-07-09 15:08:30','2026-07-09 15:08:31','2026-07-09 15:08:31'),('d1b897dd-34d5-4fff-9cbe-69796eacb8cc','0ac73e72-8181-4598-9585-4847c2782f56','559bfc32-4d6b-4a8e-aad3-c465f89d13e0','train',NULL,52,2,1,23,NULL,52,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\"]',NULL,'2026-06-29 08:44:38','2026-06-29 08:44:40','2026-06-29 08:44:40'),('d1d02b40-2dbc-4f29-b080-d1b30cb5b4ae','707e8883-6fc2-4be0-84e6-cd24f28bddbd','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,75,0,1,56,NULL,75,'[\"Camera setup\", \"Hold Position. Keep Smooth Control.\", \"Get Ready. Keep Smooth Control.\"]',NULL,'2026-07-03 14:57:02','2026-07-03 14:57:03','2026-07-03 14:57:03'),('d40c784e-15f7-49c3-9cdc-3e555cf68f0b','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','0f9206c3-a0f4-464e-95d8-14fa3084c032','train',NULL,100,10,1,28,NULL,190,'[\"Clean movement\"]',NULL,'2026-07-20 11:39:56','2026-07-20 11:40:17','2026-07-20 11:40:17'),('d52c7380-d9fd-4d43-8e0e-063fbfb07100','2b831991-3d20-4dd4-8864-21e813f51617','888594f4-f2ca-4038-b088-d8b4da1212e8','train',NULL,100,2,1,47,NULL,100,'[\"Body Detected. Move Through The Full Rep Range.\", \"Hold Position\", \"Camera setup\"]',NULL,'2026-06-24 18:37:57','2026-06-24 18:37:58','2026-06-24 18:37:58'),('d52e1c88-e36e-464a-8102-1f706137598d','0ac73e72-8181-4598-9585-4847c2782f56','32d3d42f-e926-4904-a550-d49fa7bdaf62','train',NULL,65,6,1,60,NULL,65,'[\"Body Detected. Move Through The Full Rep Range.\", \"Press Both Arms Evenly. Keep Smooth Control.\", \"Press To Full Extension\"]',NULL,'2026-06-29 15:24:42','2026-06-29 15:24:43','2026-06-29 15:24:43'),('d55cab76-881a-4d37-8a10-c6ca652dbfbb','0ac73e72-8181-4598-9585-4847c2782f56','1c98c98d-e943-489d-b792-7e7b20394e36','train',NULL,49,7,1,120,NULL,49,'[\"Shoulder position\", \"Body Detected. Move Through The Full Rep Range.\", \"Lower Fully. Keep Smooth Control.\"]',NULL,'2026-06-29 08:40:01','2026-06-29 08:40:03','2026-06-29 08:40:03'),('d573dd84-ac0f-4976-bfb6-f09d4f0eb371','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,100,0,1,26,NULL,100,'[\"Shoulder position\", \"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\"]',NULL,'2026-06-30 12:05:11','2026-06-30 12:05:13','2026-06-30 12:05:13'),('d598147a-81fa-4a18-a4b4-09dc11c87fd9','707e8883-6fc2-4be0-84e6-cd24f28bddbd','0eafe471-1d5c-4b5e-a513-e03d39e3d46f','train',NULL,65,4,1,42,NULL,65,'[\"Back posture\", \"Depth control\"]',NULL,'2026-07-08 15:30:57','2026-07-08 15:30:58','2026-07-08 15:30:58'),('d5dc5cec-01fe-4285-ba98-a1db111e7432','49f86a6b-ba79-436f-9895-a64f4735b5f4','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,55,0,1,32,NULL,55,'[\"Camera setup\", \"Back posture\", \"Hold Position. Keep Smooth Control.\"]',NULL,'2026-07-03 09:48:31','2026-07-03 09:48:32','2026-07-03 09:48:32'),('d738f6aa-ba9c-4bc9-b4ce-a9eb4a83e460','2b831991-3d20-4dd4-8864-21e813f51617','36977cbc-7ae7-4d27-beb0-e2d2889126c1','train',NULL,52,2,1,178,NULL,52,'[\"Stance control\", \"Hold Position\", \"Back posture\"]',NULL,'2026-06-24 18:56:11','2026-06-24 18:56:13','2026-06-24 18:56:13'),('d8573a28-1f91-4841-a391-0e71a3d680c6','0ac73e72-8181-4598-9585-4847c2782f56','509880db-396c-428e-908c-59e76e79152b','train',NULL,100,6,1,56,NULL,100,'[\"Body Detected. Move Through The Full Rep Range.\", \"Shoulder position\", \"Hold Position\"]',NULL,'2026-06-30 07:26:09','2026-06-30 07:26:10','2026-06-30 07:26:10'),('d86cc969-30de-4f61-b7b4-9b55762d7e69','707e8883-6fc2-4be0-84e6-cd24f28bddbd','0112ee81-a37f-42fa-9f54-42cef106cace','train',NULL,100,10,1,129,NULL,160,'[\"Move Through The Full Range\"]',NULL,'2026-07-14 17:37:25','2026-07-14 17:37:26','2026-07-14 17:37:26'),('d93279ae-34cb-4f00-bae1-9510ddf8c8e0','707e8883-6fc2-4be0-84e6-cd24f28bddbd','888594f4-f2ca-4038-b088-d8b4da1212e8','train',NULL,100,4,1,41,NULL,140,'[\"Back posture\"]',NULL,'2026-07-08 16:24:34','2026-07-08 16:24:35','2026-07-08 16:24:35'),('db175411-8ca6-48d6-874a-35c8c65073b1','0ac73e72-8181-4598-9585-4847c2782f56','0a9e0ed6-81d9-4395-a0ed-8454af7792df','train',NULL,52,8,1,77,NULL,52,'[\"Camera setup\", \"Back posture\", \"Hold Position\"]',NULL,'2026-07-01 05:28:54','2026-07-01 05:28:55','2026-07-01 05:28:55'),('db2f2a5f-6dcc-4e8a-8b71-30fc720f5b8d','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,100,6,1,158,NULL,100,'[\"Body Detected. Move Through The Full Rep Range.\", \"Hold Position\", \"Get Ready. Keep Smooth Control.\"]',NULL,'2026-06-30 04:58:17','2026-06-30 04:58:19','2026-06-30 04:58:19'),('dd4d4cb7-76f8-4644-974f-14da61b2c3d5','707e8883-6fc2-4be0-84e6-cd24f28bddbd','36977cbc-7ae7-4d27-beb0-e2d2889126c1','train',NULL,91,0,1,55,NULL,91,'[\"Camera setup\", \"Shoulder position\", \"Don\'t Move Arms Behind\"]',NULL,'2026-07-07 10:26:10','2026-07-07 10:26:12','2026-07-07 10:26:12'),('dd6fc5d5-7e7c-4f95-81f2-44a3e87df9ac','707e8883-6fc2-4be0-84e6-cd24f28bddbd','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,100,0,1,24,NULL,100,'[\"No completed reps\"]',NULL,'2026-07-08 09:52:33','2026-07-08 09:52:34','2026-07-08 09:52:34'),('dd881aea-d2c8-4454-ac0a-9f2a607e5bd9','5a90ba96-9815-48bf-b1b5-da33e20826da','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,1,0,1,1,NULL,1,'[\"Hold Position. Keep Smooth Control.\"]',NULL,'2026-07-02 07:37:05','2026-07-02 07:37:25','2026-07-02 07:37:25'),('ddb89d84-4a77-42e8-b0e6-24496a507fd9','0ac73e72-8181-4598-9585-4847c2782f56','94f19831-9b37-40ac-8129-5aa2ce7ec0aa','train',NULL,98,34,1,260,NULL,298,'[\"Keep Body Straight\", \"Keep Neck Neutral\", \"Shoulder position\"]',NULL,'2026-07-08 11:23:52','2026-07-08 11:23:54','2026-07-08 11:23:54'),('ddeaf9e5-7435-4872-86d0-48644a786798','0ac73e72-8181-4598-9585-4847c2782f56','578b3dbd-dad4-40f2-a363-ae50b52cdd52','train',NULL,52,0,1,37,NULL,52,'[\"No completed reps\"]',NULL,'2026-07-10 16:41:37','2026-07-10 16:41:40','2026-07-10 16:41:40'),('deda6b65-86c0-4339-acd6-f9975c18e68f','0ac73e72-8181-4598-9585-4847c2782f56','eeefad65-8dc5-4b90-b29d-3527d4294555','train',NULL,80,2,1,17,NULL,80,'[\"Camera setup\", \"Hold Position\", \"Get Ready. Keep Smooth Control.\"]',NULL,'2026-07-01 05:35:31','2026-07-01 05:35:32','2026-07-01 05:35:32'),('e0983362-f9c5-44b4-acee-77a71750f07e','707e8883-6fc2-4be0-84e6-cd24f28bddbd','c144ba27-8353-4411-b80f-a56747999111','train',NULL,100,3,1,18,NULL,130,'[\"Correct: Stop The Other Movement And Return To Your Assigned Exercise\"]',NULL,'2026-07-16 15:13:06','2026-07-16 15:13:08','2026-07-16 15:13:08'),('e22fb67b-dc77-4051-a88d-41a2f353f6d9','707e8883-6fc2-4be0-84e6-cd24f28bddbd','0eafe471-1d5c-4b5e-a513-e03d39e3d46f','train',NULL,78,10,1,91,NULL,88,'[\"Back posture\", \"Correct: Stop The Other Movement And Return To Your Assigned Exercise\"]',NULL,'2026-07-14 16:11:31','2026-07-14 16:11:32','2026-07-14 16:11:32'),('e45d71c8-0499-4e9a-83b7-edc7c0fc532b','829d351c-d2db-417e-8184-748ec074e7d6','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,86,11,1,146,NULL,86,'[\"Body Detected. Move Through The Full Rep Range.\", \"Hold Position. Keep Smooth Control.\", \"No Body Detected\"]',NULL,'2026-07-01 08:11:27','2026-07-01 08:11:47','2026-07-01 08:11:47'),('e54dd429-0526-4a7b-bcc1-c154e0f0e082','707e8883-6fc2-4be0-84e6-cd24f28bddbd','58af8f17-6402-4ea7-9365-0384b70fb1e7','train',NULL,100,10,1,69,NULL,200,'[\"Shoulder position\", \"Back posture\", \"Knee tracking\"]',NULL,'2026-07-17 17:01:43','2026-07-17 17:01:44','2026-07-17 17:01:44'),('e9a0aa79-75a7-4d70-af6a-8394b7f9ca8a','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,4,1,18,NULL,52,'[\"Camera setup\", \"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\"]',NULL,'2026-06-29 09:32:09','2026-06-29 09:32:11','2026-06-29 09:32:11'),('eb21edba-db47-46f1-8b4a-9ab8f7f7ae7f','0ac73e72-8181-4598-9585-4847c2782f56','ed5b0bfb-5098-4f1e-a811-e4f01bec9e76','train',NULL,85,10,1,38,NULL,85,'[\"Clean movement\"]',NULL,'2026-07-20 13:07:44','2026-07-20 13:07:46','2026-07-20 13:07:46'),('eb80592a-1031-4bf2-aec4-cae984af98b5','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,49,0,1,59,NULL,49,'[\"Shoulder position\", \"Body Detected. Move Through The Full Rep Range.\", \"Back posture\"]',NULL,'2026-06-30 12:06:21','2026-06-30 12:06:24','2026-06-30 12:06:24'),('ee707720-0bc7-4021-acc1-e733a686b512','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,100,0,1,16,NULL,100,'[\"Camera setup\"]',NULL,'2026-07-06 13:57:28','2026-07-06 13:57:29','2026-07-06 13:57:29'),('eef0a78e-99ce-491d-bc97-299f176a3ead','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,49,0,1,47,NULL,49,'[\"Shoulder position\", \"Body Detected. Move Through The Full Rep Range.\", \"Lower Fully. Keep Smooth Control.\"]',NULL,'2026-06-29 07:18:22','2026-06-29 07:18:24','2026-06-29 07:18:24'),('ef9c6d22-7778-4e60-bd3a-87f78d4b08a4','2b831991-3d20-4dd4-8864-21e813f51617','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,52,7,1,171,NULL,52,'[\"Body Detected. Move Through The Full Rep Range.\", \"Camera setup\", \"Hold Position\"]',NULL,'2026-06-24 17:53:43','2026-06-24 17:53:44','2026-06-24 17:53:44'),('efff4c4e-424f-4e19-840e-a8265ccff967','fb6a60a0-b9ae-46dd-9310-3d24460ceedd','c144ba27-8353-4411-b80f-a56747999111','train',NULL,100,4,1,60,NULL,140,'[\"Camera setup\", \"Shoulder position\"]',NULL,'2026-07-06 13:58:54','2026-07-06 13:58:55','2026-07-06 13:58:55'),('f05f66dc-f015-49b3-8776-ffbafe3a5fe1','0e4c5a12-0a9e-4f6e-9a87-51ea53b17e7d','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,100,5,1,68,NULL,150,'[\"Body Detected. Move Through The Full Rep Range.\", \"Hold Position. Keep Smooth Control.\", \"Get Ready. Keep Smooth Control.\"]',NULL,'2026-07-02 08:43:00','2026-07-02 08:43:02','2026-07-02 08:43:02'),('f08cd94a-c81c-46e0-861d-16bf1e032a38','54d44b92-0af3-4a2d-b3aa-89fc15cb764b','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,5,NULL,52,'[\"Camera setup\", \"No Body Detected\", \"Hold Position. Keep Smooth Control.\"]',NULL,'2026-07-02 07:40:12','2026-07-02 07:40:33','2026-07-02 07:40:33'),('f40e7215-fdd5-42b3-a3c8-6ef2bc958846','e304ca99-06fb-4c5d-818c-48ea20ad3aeb','888594f4-f2ca-4038-b088-d8b4da1212e8','train',NULL,52,3,1,50,NULL,52,'[\"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\", \"Camera setup\"]',NULL,'2026-06-29 11:06:18','2026-06-29 11:06:39','2026-06-29 11:06:39'),('f5df1c36-3959-4d5f-bd8b-da54336f02f6','0ac73e72-8181-4598-9585-4847c2782f56','4ad754fd-05c7-448c-8c33-9d089ad454ad','train',NULL,58,4,1,85,NULL,58,'[\"Stance control\", \"Shoulder position\", \"Camera setup\"]',NULL,'2026-07-01 09:31:37','2026-07-01 09:31:39','2026-07-01 09:31:39'),('f76d5412-11c2-4a57-87b1-dfed47bdb90a','0ac73e72-8181-4598-9585-4847c2782f56','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,75,0,1,108,NULL,75,'[\"Hold Position\", \"Back posture\", \"Camera setup\"]',NULL,'2026-06-29 12:46:55','2026-06-29 12:46:56','2026-06-29 12:46:56'),('f97614cb-bda7-4ce3-a4ca-5c3429e7d16e','707e8883-6fc2-4be0-84e6-cd24f28bddbd','0a9e0ed6-81d9-4395-a0ed-8454af7792df','train',NULL,82,1,1,58,NULL,82,'[\"Back posture\"]',NULL,'2026-07-17 14:25:36','2026-07-17 14:25:38','2026-07-17 14:25:38'),('fa788437-a1c1-4271-ad5a-082f2ff0b238','0ac73e72-8181-4598-9585-4847c2782f56','6387ae2e-1272-4a17-b263-475dd4f8e562','train',NULL,100,0,1,37,NULL,100,'[\"Body Detected. Move Through The Full Rep Range.\", \"No Body Detected\", \"Lower Fully. Keep Smooth Control.\"]',NULL,'2026-06-29 07:57:25','2026-06-29 07:57:27','2026-06-29 07:57:27'),('fcace739-9c46-4c35-9509-675f44945dd8','707e8883-6fc2-4be0-84e6-cd24f28bddbd','58134982-b74b-4599-87b0-31e28dbe5996','train',NULL,100,10,1,78,NULL,200,'[\"Arm path\", \"Shoulder position\"]',NULL,'2026-07-16 15:54:49','2026-07-16 15:54:50','2026-07-16 15:54:50'),('fcbfede6-b25c-4d38-8bf0-2949982b737c','0ac73e72-8181-4598-9585-4847c2782f56','f68763ea-aae8-4a0d-8559-5b3ee922f07b','train',NULL,52,0,1,4431,NULL,52,'[\"Camera setup\", \"Hold Position\", \"Back posture\"]',NULL,'2026-06-29 12:29:21','2026-06-29 12:29:26','2026-06-29 12:29:26'),('fd205cf0-25a2-4eb6-b959-5f9d61485edb','0ac73e72-8181-4598-9585-4847c2782f56','4ad754fd-05c7-448c-8c33-9d089ad454ad','train',NULL,1,0,1,90,NULL,1,'[\"Camera setup\", \"Correct: Stop The Other Movement And Return To Your Assigned Exercise\"]',NULL,'2026-07-17 10:40:23','2026-07-17 10:40:25','2026-07-17 10:40:25'),('fe742b3c-67ac-44cd-a559-713c54d663aa','0ac73e72-8181-4598-9585-4847c2782f56','c421248c-706c-46fe-b73e-d016937bfdfa','train',NULL,52,0,1,11,NULL,52,'[\"Back posture\"]',NULL,'2026-07-10 16:33:40','2026-07-10 16:33:42','2026-07-10 16:33:42');
/*!40000 ALTER TABLE `workout_sessions` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-20 14:30:17
