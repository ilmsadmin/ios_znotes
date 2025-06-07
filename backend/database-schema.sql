-- iOS ZNotes Database Schema
-- This file is for reference only - TypeORM will auto-create tables

-- Groups table for email domain-based organization
CREATE TABLE `groups` (
  `id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `domain` varchar(100) NOT NULL UNIQUE,
  `description` text,
  `adminId` varchar(36),
  `isActive` tinyint(1) DEFAULT 1,
  `createdAt` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `updatedAt` datetime(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_domain` (`domain`)
);

-- Users table with authentication and group membership
CREATE TABLE `users` (
  `id` varchar(36) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL UNIQUE,
  `password` varchar(255) NOT NULL,
  `role` varchar(50) DEFAULT 'user',
  `userRole` enum('user','group_admin','system_admin') DEFAULT 'user',
  `profileImage` varchar(255),
  `isEmailVerified` tinyint(1) DEFAULT 0,
  `emailVerificationToken` varchar(255),
  `resetPasswordToken` varchar(255),
  `resetPasswordExpiry` datetime,
  `emailDomain` varchar(100) NOT NULL,
  `groupId` varchar(36),
  `createdAt` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `updatedAt` datetime(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  `trashedDate` datetime,
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_email` (`email`),
  KEY `IDX_emailDomain` (`emailDomain`),
  FOREIGN KEY (`groupId`) REFERENCES `groups` (`id`) ON DELETE SET NULL
);

-- Personal notes table
CREATE TABLE `notes` (
  `id` varchar(36) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `tags` json,
  `authorId` varchar(36) NOT NULL,
  `createdAt` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `updatedAt` datetime(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  `trashedDate` datetime,
  PRIMARY KEY (`id`),
  KEY `IDX_authorId` (`authorId`),
  FOREIGN KEY (`authorId`) REFERENCES `users` (`id`) ON DELETE CASCADE
);

-- Tasks table with group-level visibility
CREATE TABLE `tasks` (
  `id` varchar(36) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `priority` enum('Low','Medium','High','Critical') DEFAULT 'Medium',
  `status` enum('To Do','In Progress','In Review','Done','Cancelled') DEFAULT 'To Do',
  `tags` json,
  `dueDate` datetime,
  `assigneeId` varchar(36),
  `createdById` varchar(36) NOT NULL,
  `createdAt` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `updatedAt` datetime(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  `trashedDate` datetime,
  PRIMARY KEY (`id`),
  KEY `IDX_assigneeId` (`assigneeId`),
  KEY `IDX_createdById` (`createdById`),
  FOREIGN KEY (`assigneeId`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  FOREIGN KEY (`createdById`) REFERENCES `users` (`id`) ON DELETE CASCADE
);

-- Issues table with comments support
CREATE TABLE `issues` (
  `id` varchar(36) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `priority` enum('Low','Medium','High','Critical') DEFAULT 'Medium',
  `status` enum('To Do','In Progress','In Review','Done','Cancelled') DEFAULT 'To Do',
  `tags` json,
  `reporterId` varchar(36) NOT NULL,
  `assigneeId` varchar(36),
  `createdAt` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `updatedAt` datetime(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  `trashedDate` datetime,
  PRIMARY KEY (`id`),
  KEY `IDX_reporterId` (`reporterId`),
  KEY `IDX_assigneeId` (`assigneeId`),
  FOREIGN KEY (`reporterId`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`assigneeId`) REFERENCES `users` (`id`) ON DELETE SET NULL
);

-- Comments for issues
CREATE TABLE `comments` (
  `id` varchar(36) NOT NULL,
  `content` text NOT NULL,
  `authorId` varchar(36) NOT NULL,
  `issueId` varchar(36) NOT NULL,
  `createdAt` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `IDX_authorId` (`authorId`),
  KEY `IDX_issueId` (`issueId`),
  FOREIGN KEY (`authorId`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`issueId`) REFERENCES `issues` (`id`) ON DELETE CASCADE
);

-- Assignments table for task/issue assignments
CREATE TABLE `assignments` (
  `id` varchar(36) NOT NULL,
  `type` enum('Task','Issue') NOT NULL,
  `itemId` varchar(36) NOT NULL,
  `personId` varchar(36) NOT NULL,
  `dueDate` datetime,
  `notes` text,
  `createdById` varchar(36) NOT NULL,
  `createdAt` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `updatedAt` datetime(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `IDX_itemId` (`itemId`),
  KEY `IDX_personId` (`personId`),
  KEY `IDX_createdById` (`createdById`),
  FOREIGN KEY (`personId`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`createdById`) REFERENCES `users` (`id`) ON DELETE CASCADE
);