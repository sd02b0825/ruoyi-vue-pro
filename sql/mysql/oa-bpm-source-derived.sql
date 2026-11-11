-- 根据本项目 OA、BPM 数据对象及单元测试建表定义生成，适用于 MySQL 8.x。
-- OA 的 48 张表取自 yudao-module-oa/src/test/resources/sql/create_tables.sql；
-- BPM 的 6 张基础表取自 yudao-module-bpm/src/test/resources/sql/create_tables.sql，
-- 另 2 张缺失表按对应 DO 字段生成。Flowable ACT_/FLW_ 引擎表由应用启动时自动创建。
-- 超长 H2 VARCHAR 字段转为 MEDIUMTEXT，避免 MySQL 单行长度限制；未参与索引。
-- 建表使用 IF NOT EXISTS；BPM 多租户拦截器需要 tenant_id，脚本末尾会幂等补齐 8 张 BPM 自定义表的租户列。
-- 仅新增缺失表和缺失租户列，不更新已有业务数据。
CREATE TABLE IF NOT EXISTS `oa_attendance` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `type` tinyint NOT NULL,
  `status` tinyint NOT NULL,
  `attendance_time` datetime NOT NULL,
  `attendance_ip` varchar(64),
  `remark` varchar(500),
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_schedule` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type` tinyint NOT NULL,
  `priority` tinyint NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` varchar(1000),
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `remind` bit(1) NOT NULL DEFAULT b'0',
  `reminded` bit(1) NOT NULL DEFAULT b'0',
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_schedule_participant` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `schedule_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `read_status` bit(1) NOT NULL DEFAULT b'0',
  `read_time` datetime,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_schedule_id_user_id` (`schedule_id`, `user_id`, `deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_plan` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type` tinyint NOT NULL,
  `status` tinyint NOT NULL,
  `title` varchar(100) NOT NULL,
  `label` varchar(255),
  `content` text NOT NULL,
  `summary` text,
  `comment` text,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `file_urls` MEDIUMTEXT,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_work_report` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `no` varchar(64) NOT NULL,
  `type` tinyint NOT NULL,
  `status` tinyint NOT NULL,
  `dept_id` bigint,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `title` varchar(255) NOT NULL,
  `summary` text,
  `plan` text,
  `problem` text,
  `work_items` MEDIUMTEXT,
  `plan_items` MEDIUMTEXT,
  `file_urls` MEDIUMTEXT,
  `remark` varchar(1000),
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `work_report_idx_no` (`tenant_id`, `no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_note_category` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `name` varchar(255) NOT NULL,
  `sort` int NOT NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_note` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `category_id` bigint,
  `type` tinyint NOT NULL,
  `priority` tinyint NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text,
  `favorite` bit(1) NOT NULL DEFAULT b'0',
  `file_urls` MEDIUMTEXT,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_note_receiver` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `note_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_note_id_user_id` (`note_id`, `user_id`, `deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_contact_category` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `name` varchar(50) NOT NULL,
  `sort` int NOT NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_contact` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `category_id` bigint,
  `name` varchar(50) NOT NULL,
  `pinyin` varchar(100),
  `sex` tinyint,
  `mobile` varchar(20),
  `email` varchar(100),
  `address` varchar(255),
  `company_name` varchar(100),
  `company_phone` varchar(30),
  `avatar` varchar(512),
  `remark` varchar(500),
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_contact_share` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `contact_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `category_id` bigint,
  `handle_status` bit(1) NOT NULL DEFAULT b'0',
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_task` (
  `publish_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type` tinyint NOT NULL,
  `status` tinyint NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` MEDIUMTEXT NOT NULL,
  `comment` varchar(1000),
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `top` bit(1) NOT NULL DEFAULT b'0',
  `canceled` bit(1) NOT NULL DEFAULT b'0',
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_task_receiver` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `status` tinyint NOT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_task_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `status` tinyint,
  `content` varchar(1000),
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_announcement` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type` tinyint NOT NULL,
  `priority` tinyint NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text,
  `url` varchar(512),
  `top` bit(1) NOT NULL DEFAULT b'0',
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_announcement_receiver` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `announcement_id` bigint NOT NULL,
  `receiver_user_id` bigint NOT NULL,
  `read_status` bit(1) NOT NULL DEFAULT b'0',
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `announcement_receiver_idx_announcement_id_receiver_user_id` (`announcement_id`, `receiver_user_id`, `deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_discussion` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `type` tinyint NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text,
  `file_urls` MEDIUMTEXT,
  `visit_count` int NOT NULL DEFAULT 0,
  `vote_multiple` bit(1),
  `vote_start_time` datetime,
  `vote_end_time` datetime,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_discussion_reply` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `discussion_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `parent_id` bigint NOT NULL DEFAULT 0,
  `reply_user_id` bigint,
  `content` text NOT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_discussion_like` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `discussion_id` bigint,
  `reply_id` bigint,
  `user_id` bigint NOT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_vote_option` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `discussion_id` bigint NOT NULL,
  `title` varchar(200) NOT NULL,
  `color` varchar(20),
  `sort` int NOT NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_vote_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `discussion_id` bigint NOT NULL,
  `option_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `vote_record_idx_option_id_user_id` (`option_id`, `user_id`, `deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_mail_provider` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `imap` json NOT NULL,
  `smtp` json NOT NULL,
  `status` tinyint NOT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_seal` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `dept_id` bigint NOT NULL,
  `no` varchar(64) NOT NULL,
  `name` varchar(128) NOT NULL,
  `type` int NOT NULL,
  `category` int DEFAULT NULL,
  `keeper_user_id` bigint NOT NULL,
  `keeper_dept_id` bigint NOT NULL,
  `status` int NOT NULL DEFAULT 0,
  `purchase_time` datetime DEFAULT NULL,
  `enable_time` datetime DEFAULT NULL,
  `disable_time` datetime DEFAULT NULL,
  `pic_url` MEDIUMTEXT DEFAULT NULL,
  `sort` int NOT NULL DEFAULT 0,
  `remark` varchar(500) DEFAULT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `seal_idx_no` (`tenant_id`, `no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='印章';

CREATE TABLE IF NOT EXISTS `oa_seal_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `no` varchar(64) NOT NULL,
  `user_id` bigint NOT NULL,
  `dept_id` bigint DEFAULT NULL,
  `seal_id` bigint NOT NULL,
  `seal_no` varchar(64) NOT NULL,
  `seal_name` varchar(128) NOT NULL,
  `seal_type` tinyint DEFAULT NULL COMMENT '印章类型快照',
  `keeper_dept_id` bigint DEFAULT NULL COMMENT '保管部门编号快照',
  `keeper_user_id` bigint NOT NULL,
  `reason` varchar(500) NOT NULL,
  `type` tinyint NOT NULL,
  `mode` tinyint NOT NULL,
  `document_title` varchar(255) DEFAULT NULL,
  `document_type` varchar(64) DEFAULT NULL,
  `document_count` int NOT NULL,
  `contract_price` decimal(18,2) DEFAULT NULL,
  `contract_party` varchar(255) DEFAULT NULL,
  `expected_use_time` datetime NOT NULL,
  `actual_use_time` datetime DEFAULT NULL,
  `expected_return_time` datetime DEFAULT NULL,
  `actual_return_time` datetime DEFAULT NULL,
  `use_status` tinyint NOT NULL DEFAULT 0,
  `status` tinyint NOT NULL DEFAULT -1,
  `process_instance_id` varchar(64) DEFAULT NULL,
  `urgent` bit(1) NOT NULL DEFAULT b'0',
  `file_urls` MEDIUMTEXT DEFAULT NULL,
  `remark` varchar(500) DEFAULT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `seal_apply_idx_no` (`tenant_id`, `no`),
  KEY `seal_apply_idx_process_instance` (`tenant_id`, `process_instance_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用印申请';

CREATE TABLE IF NOT EXISTS `oa_mail_account` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `provider_id` bigint NOT NULL,
  `mail` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` text NOT NULL,
  `default_status` bit(1) NOT NULL,
  `status` tinyint NOT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_mail_folder` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `account_id` bigint NOT NULL,
  `name` varchar(255) NOT NULL,
  `type` varchar(20) NOT NULL,
  `uid_validity` bigint DEFAULT NULL,
  `sync_time` datetime DEFAULT NULL,
  `available` bit(1) NOT NULL DEFAULT b'1',
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `mail_folder_idx_account_folder` (`tenant_id`, `account_id`, `name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_mail_message` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `account_id` bigint NOT NULL,
  `folder_id` bigint NOT NULL,
  `uid_validity` bigint NOT NULL,
  `uid` bigint NOT NULL,
  `subject` longtext NOT NULL,
  `content` MEDIUMTEXT DEFAULT NULL,
  `reply_tos` MEDIUMTEXT DEFAULT NULL,
  `attachments` MEDIUMTEXT DEFAULT NULL,
  `sender` text,
  `recipients` MEDIUMTEXT,
  `ccs` MEDIUMTEXT,
  `receive_time` datetime DEFAULT NULL,
  `read_status` bit(1) NOT NULL DEFAULT b'0',
  `has_attach` bit(1) NOT NULL DEFAULT b'0',
  `size` int DEFAULT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_file_node` (
  `id` bigint AUTO_INCREMENT PRIMARY KEY,
  `parent_id` bigint NOT NULL DEFAULT 0,
  `type` tinyint NOT NULL,
  `name` varchar(255) NOT NULL,
  `extension` varchar(64),
  `category` tinyint,
  `size` bigint DEFAULT 0,
  `url` MEDIUMTEXT,
  `dept_id` bigint,
  `status` tinyint NOT NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) DEFAULT b'0',
  `tenant_id` bigint DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_file_permission` (
  `id` bigint AUTO_INCREMENT PRIMARY KEY,
  `node_id` bigint NOT NULL,
  `subject_type` tinyint NOT NULL,
  `subject_id` bigint NOT NULL,
  `level` tinyint NOT NULL,
  `inherit` bit(1) NOT NULL,
  `expire_time` datetime,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) DEFAULT b'0',
  `tenant_id` bigint DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_file_favorite` (
  `id` bigint AUTO_INCREMENT PRIMARY KEY,
  `node_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) DEFAULT b'0',
  `tenant_id` bigint DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_vehicle` (
  `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `no` varchar(32) NOT NULL,
  `name` varchar(128) NOT NULL,
  `type` varchar(64) NOT NULL,
  `category` varchar(64),
  `brand_model` varchar(128),
  `seat_count` int NOT NULL,
  `bare_price` decimal(18,2) NOT NULL DEFAULT 0,
  `compulsory_insurance_expire_time` datetime,
  `commercial_insurance_expire_time` datetime,
  `inspection_expire_time` datetime,
  `pic_url` MEDIUMTEXT,
  `dept_id` bigint,
  `status` tinyint NOT NULL DEFAULT 0,
  `sort` int NOT NULL DEFAULT 0,
  `remark` varchar(500),
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  KEY `vehicle_idx_no` (`tenant_id`, `no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_vehicle_return` (
  `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `no` varchar(64) NOT NULL,
  `apply_id` bigint NOT NULL,
  `vehicle_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `dept_id` bigint,
  `actual_start_time` datetime,
  `start_location` varchar(255),
  `reason` varchar(500),
  `passenger` varchar(500),
  `actual_return_time` datetime,
  `return_location` varchar(255),
  `status` tinyint NOT NULL DEFAULT -1,
  `process_instance_id` varchar(64),
  `file_urls` MEDIUMTEXT DEFAULT NULL,
  `remark` varchar(500),
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  KEY `vehicle_return_idx_process_instance` (`tenant_id`, `process_instance_id`),
  KEY `vehicle_return_idx_no` (`tenant_id`, `no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_vehicle_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `no` varchar(64) NOT NULL,
  `vehicle_id` bigint,
  `vehicle_no` varchar(32),
  `user_id` bigint NOT NULL,
  `dept_id` bigint,
  `start_time` datetime,
  `end_time` datetime,
  `start_location` varchar(255),
  `end_location` varchar(255),
  `reason` varchar(500),
  `passenger` varchar(500),
  `status` tinyint NOT NULL DEFAULT -1,
  `return_status` tinyint NOT NULL DEFAULT 0,
  `process_instance_id` varchar(64),
  `file_urls` MEDIUMTEXT DEFAULT NULL,
  `remark` varchar(500),
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  KEY `vehicle_apply_idx_no` (`tenant_id`, `no`),
  KEY `vehicle_apply_idx_process_instance` (`tenant_id`, `process_instance_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_supply_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `dept_id` bigint NOT NULL,
  `name` varchar(128) NOT NULL,
  `no` varchar(64) DEFAULT NULL,
  `category` int NOT NULL,
  `manage_type` int NOT NULL,
  `model` varchar(128),
  `unit` varchar(32),
  `reference_price` decimal(18,2),
  `stock_quantity` int NOT NULL DEFAULT 0,
  `min_stock_quantity` int NOT NULL DEFAULT 0,
  `pic_url` MEDIUMTEXT,
  `status` int NOT NULL DEFAULT 0,
  `sort` int NOT NULL DEFAULT 0,
  `remark` varchar(500),
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `supply_item_idx_no` (`tenant_id`, `no`, `deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_supply_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `no` varchar(64) NOT NULL,
  `dept_id` bigint NOT NULL,
  `apply_time` datetime,
  `use_type` int,
  `pickup_method` int,
  `reason` varchar(500),
  `status` int NOT NULL DEFAULT -1,
  `process_instance_id` varchar(64),
  `file_urls` MEDIUMTEXT,
  `remark` varchar(500),
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `supply_apply_idx_no` (`tenant_id`, `no`, `deleted`),
  KEY `supply_apply_idx_creator` (`tenant_id`, `creator`, `deleted`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_supply_apply_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `apply_id` bigint NOT NULL,
  `item_id` bigint NOT NULL,
  `item_name` varchar(128) NOT NULL,
  `model` varchar(128),
  `unit` varchar(32),
  `manage_type` int NOT NULL,
  `apply_quantity` int,
  `issued_quantity` int NOT NULL DEFAULT 0,
  `returned_quantity` int NOT NULL DEFAULT 0,
  `status` int NOT NULL DEFAULT -1,
  `issue_user_id` bigint,
  `issue_time` datetime,
  `issue_remark` varchar(500),
  `return_remark` varchar(500),
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `supply_apply_item_idx_apply_id` (`tenant_id`, `apply_id`, `deleted`, `id`),
  KEY `supply_apply_item_idx_item_id` (`tenant_id`, `item_id`, `deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_meeting_room` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `location` varchar(255) NOT NULL,
  `type` tinyint NOT NULL,
  `manager_user_id` bigint NOT NULL,
  `status` tinyint NOT NULL,
  `pic_url` MEDIUMTEXT,
  `seat_count` int,
  `equipments` MEDIUMTEXT,
  `allow_booking` bit(1) NOT NULL,
  `need_approval` bit(1) NOT NULL,
  `booking_scope` tinyint NOT NULL,
  `booking_user_ids` MEDIUMTEXT,
  `sort` int NOT NULL,
  `remark` varchar(200),
  `file_urls` MEDIUMTEXT,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_meeting_room_booking` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `no` varchar(64) NOT NULL,
  `room_id` bigint NOT NULL,
  `title` varchar(200) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `moderator_user_id` bigint NOT NULL,
  `attendee_user_ids` MEDIUMTEXT,
  `reminder_type` tinyint NOT NULL,
  `reminded` bit(1) NOT NULL DEFAULT b'0',
  `description` varchar(500),
  `dept_id` bigint,
  `status` tinyint NOT NULL,
  `process_instance_id` varchar(64),
  `need_approval` bit(1),
  `use_status` tinyint NOT NULL,
  `remark` varchar(500),
  `file_urls` MEDIUMTEXT,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `meeting_room_booking_idx_no` (`tenant_id`, `no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_reimbursement` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `urgency` int DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `witness_user_id` bigint DEFAULT NULL,
  `customer_name` varchar(255) DEFAULT NULL,
  `payment_method` int DEFAULT NULL,
  `invoice_count` int DEFAULT NULL,
  `total_price` decimal(18,2) DEFAULT NULL,
  `status` int DEFAULT NULL,
  `process_instance_id` varchar(255) DEFAULT NULL,
  `items` MEDIUMTEXT DEFAULT NULL,
  `file_urls` MEDIUMTEXT DEFAULT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT 0,
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_overtime_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `urgency` int DEFAULT NULL,
  `type` int DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `days` decimal(10,1) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `status` int DEFAULT NULL,
  `process_instance_id` varchar(255) DEFAULT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT 0,
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_leave_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `urgency` int DEFAULT NULL,
  `type` int DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `days` int DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `status` int DEFAULT NULL,
  `process_instance_id` varchar(255) DEFAULT NULL,
  `file_urls` MEDIUMTEXT DEFAULT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT 0,
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_regular_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `urgency` int DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `days` int DEFAULT NULL,
  `experience` varchar(255) DEFAULT NULL,
  `understanding` varchar(255) DEFAULT NULL,
  `growth` varchar(255) DEFAULT NULL,
  `deficiency` varchar(255) DEFAULT NULL,
  `improvement` varchar(255) DEFAULT NULL,
  `suggestion` varchar(255) DEFAULT NULL,
  `status` int DEFAULT NULL,
  `process_instance_id` varchar(255) DEFAULT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT 0,
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_resign_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `urgency` int DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `handover_user_id` bigint DEFAULT NULL,
  `unfinished_work` text DEFAULT NULL,
  `has_pending_reimbursement` bit(1) DEFAULT NULL,
  `suggestion` varchar(255) DEFAULT NULL,
  `status` int DEFAULT NULL,
  `process_instance_id` varchar(255) DEFAULT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT 0,
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_official_doc_template` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `authority_name` varchar(255) NOT NULL,
  `font_size` int NOT NULL,
  `no_prefix` varchar(64) NULL,
  `seal_pic_url` MEDIUMTEXT NULL,
  `separator_type` int NOT NULL,
  `status` int NOT NULL,
  `sort` int NOT NULL,
  `remark` varchar(500) NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_official_doc_send` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `no` varchar(64) NULL,
  `template_id` bigint NOT NULL,
  `title` varchar(255) NOT NULL,
  `no_prefix` varchar(64) NULL,
  `year` int NULL,
  `sequence` int NULL,
  `document_no` varchar(64) NULL,
  `secrecy_level` int NOT NULL,
  `urgency_level` int NOT NULL,
  `disclosure_type` int NOT NULL,
  `issue_time` datetime NOT NULL,
  `send_dept_id` bigint NOT NULL,
  `main_dept_ids` MEDIUMTEXT NOT NULL,
  `copy_dept_ids` MEDIUMTEXT NULL,
  `signer_user_id` bigint NULL,
  `content` text NULL,
  `file_urls` MEDIUMTEXT NULL,
  `formal_file_url` MEDIUMTEXT NULL,
  `remark` varchar(500) NULL,
  `status` int NULL,
  `process_instance_id` varchar(64) NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_official_doc_receive` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `no` varchar(64) NULL,
  `send_id` bigint NULL,
  `receive_type` int NOT NULL,
  `title` varchar(255) NULL,
  `document_no` varchar(64) NULL,
  `secrecy_level` int NULL,
  `urgency_level` int NULL,
  `receive_time` datetime NULL,
  `receive_dept_id` bigint NOT NULL,
  `handler_user_id` bigint NULL,
  `instruction` text NULL,
  `result` text NULL,
  `deadline_time` datetime NULL,
  `summary` text NULL,
  `remark` varchar(500) NULL,
  `file_urls` MEDIUMTEXT NULL,
  `formal_file_url` MEDIUMTEXT NULL,
  `handle_status` int NULL,
  `status` int NULL,
  `process_instance_id` varchar(64) NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `oa_travel_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `no` varchar(64) NOT NULL,
  `dept_id` bigint DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `days` int DEFAULT NULL,
  `companion` varchar(500) DEFAULT NULL,
  `estimated_price` decimal(18,2) DEFAULT NULL,
  `reimburse_status` tinyint NOT NULL DEFAULT 0,
  `status` tinyint NOT NULL DEFAULT -1,
  `process_instance_id` varchar(64) DEFAULT NULL,
  `remark` text DEFAULT NULL,
  `items` MEDIUMTEXT DEFAULT NULL,
  `file_urls` MEDIUMTEXT DEFAULT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT 0,
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `travel_apply_idx_no` (`tenant_id`, `no`)
) COMMENT='出差申请';

CREATE TABLE IF NOT EXISTS `oa_travel_reimbursement` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `no` varchar(64) NOT NULL,
  `dept_id` bigint DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `days` int DEFAULT NULL,
  `travel_apply_id` bigint DEFAULT NULL,
  `total_price` decimal(18,2) DEFAULT NULL,
  `pay_status` tinyint NOT NULL DEFAULT 0,
  `status` tinyint NOT NULL DEFAULT -1,
  `process_instance_id` varchar(64) DEFAULT NULL,
  `remark` text DEFAULT NULL,
  `items` MEDIUMTEXT DEFAULT NULL,
  `file_urls` MEDIUMTEXT DEFAULT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT 0,
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `travel_reimbursement_idx_no` (`tenant_id`, `no`)
) COMMENT='出差报销';

CREATE TABLE IF NOT EXISTS `bpm_user_group` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(63) NOT NULL,
  `description` varchar(255) NOT NULL,
  `status` tinyint NOT NULL,
  `user_ids` varchar(255) NOT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) COMMENT '用户组';

CREATE TABLE IF NOT EXISTS `bpm_category` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(63) NOT NULL,
  `code` varchar(63) NOT NULL,
  `description` varchar(255) NOT NULL,
  `status` tinyint NOT NULL,
  `sort` int NOT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) COMMENT '分类';

CREATE TABLE IF NOT EXISTS `bpm_form` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(63) NOT NULL,
  `status` tinyint NOT NULL,
  `fields` varchar(255) NOT NULL,
  `conf` varchar(255) NOT NULL,
  `remark` varchar(255),
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) COMMENT '动态表单';

CREATE TABLE IF NOT EXISTS `bpm_process_expression` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(63) NOT NULL,
  `status` tinyint NOT NULL,
  `expression` varchar(255) NOT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) COMMENT '流程表达式';

CREATE TABLE IF NOT EXISTS `bpm_process_listener` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(63) NOT NULL,
  `status` tinyint NOT NULL,
  `type` varchar(30) NOT NULL,
  `event` varchar(30) NOT NULL,
  `value_type` varchar(30) NOT NULL,
  `value` varchar(255) NOT NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) COMMENT '流程监听器';

CREATE TABLE IF NOT EXISTS `bpm_oa_leave` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `type` tinyint NOT NULL,
  `reason` varchar(255) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `day` bigint NOT NULL,
  `status` tinyint NOT NULL,
  `process_instance_id` varchar(64) DEFAULT '',
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) COMMENT 'OA 请假申请';

CREATE TABLE IF NOT EXISTS `bpm_process_definition_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号', `process_definition_id` varchar(64) DEFAULT NULL COMMENT '流程定义编号',
  `model_id` varchar(64) DEFAULT NULL COMMENT '流程模型编号', `model_type` tinyint DEFAULT NULL COMMENT '流程模型类型',
  `category` varchar(63) DEFAULT NULL COMMENT '流程分类编码', `icon` varchar(255) DEFAULT NULL COMMENT '图标',
  `description` text DEFAULT NULL COMMENT '描述', `form_type` tinyint DEFAULT NULL COMMENT '表单类型', `form_id` bigint DEFAULT NULL COMMENT '动态表单编号',
  `form_conf` mediumtext DEFAULT NULL COMMENT '表单配置', `form_fields` mediumtext DEFAULT NULL COMMENT '表单字段',
  `form_custom_create_path` varchar(255) DEFAULT NULL COMMENT '自定义表单提交路径', `form_custom_view_path` varchar(255) DEFAULT NULL COMMENT '自定义表单查看路径',
  `simple_model` mediumtext DEFAULT NULL COMMENT '仿钉钉流程模型数据', `visible` bit(1) DEFAULT NULL COMMENT '是否可见', `sort` bigint DEFAULT NULL COMMENT '排序值',
  `start_user_ids` mediumtext DEFAULT NULL COMMENT '可发起用户编号', `start_dept_ids` mediumtext DEFAULT NULL COMMENT '可发起部门编号',
  `manager_user_ids` mediumtext DEFAULT NULL COMMENT '可管理用户编号', `allow_cancel_running_process` bit(1) DEFAULT NULL COMMENT '是否允许撤销审批中的申请',
  `allow_withdraw_task` bit(1) DEFAULT NULL COMMENT '是否允许审批人撤回任务', `process_id_rule` mediumtext DEFAULT NULL COMMENT '流程编号规则',
  `auto_approval_type` tinyint DEFAULT NULL COMMENT '自动审批类型', `title_setting` mediumtext DEFAULT NULL COMMENT '标题设置', `summary_setting` mediumtext DEFAULT NULL COMMENT '摘要设置',
  `process_before_trigger_setting` mediumtext DEFAULT NULL COMMENT '流程前置通知配置', `process_after_trigger_setting` mediumtext DEFAULT NULL COMMENT '流程后置通知配置',
  `task_before_trigger_setting` mediumtext DEFAULT NULL COMMENT '任务前置通知配置', `task_after_trigger_setting` mediumtext DEFAULT NULL COMMENT '任务后置通知配置',
  `print_template_setting` mediumtext DEFAULT NULL COMMENT '打印模板配置', `creator` varchar(64) DEFAULT '', `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '', `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP, `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`), KEY `idx_process_definition_id` (`process_definition_id`), KEY `idx_model_id` (`model_id`), KEY `idx_category` (`category`)
) COMMENT='流程定义扩展信息' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `bpm_process_instance_copy` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号', `start_user_id` bigint DEFAULT NULL COMMENT '流程发起人编号',
  `process_instance_name` varchar(255) DEFAULT NULL COMMENT '流程实例名称', `process_instance_id` varchar(64) DEFAULT NULL COMMENT '流程实例编号',
  `process_definition_id` varchar(64) DEFAULT NULL COMMENT '流程定义编号', `category` varchar(63) DEFAULT NULL COMMENT '流程分类',
  `activity_id` varchar(64) DEFAULT NULL COMMENT '流程活动编号', `activity_name` varchar(255) DEFAULT NULL COMMENT '流程活动名称',
  `task_id` varchar(64) DEFAULT NULL COMMENT '任务编号', `user_id` bigint DEFAULT NULL COMMENT '被抄送用户编号', `reason` text DEFAULT NULL COMMENT '抄送意见',
  `creator` varchar(64) DEFAULT '', `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP, `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP, `deleted` bit(1) NOT NULL DEFAULT b'0', `tenant_id` bigint NOT NULL DEFAULT 0, PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`), KEY `idx_process_instance_id` (`process_instance_id`), KEY `idx_task_id` (`task_id`)
) COMMENT='流程抄送记录' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BPM MyBatis 多租户拦截器会为自定义表 SQL 注入 tenant_id；兼容已按单元测试 DDL 创建的旧表。
SET @oa_bpm_tenant_sql = IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'bpm_user_group' AND column_name = 'tenant_id') = 0, 'ALTER TABLE `bpm_user_group` ADD COLUMN `tenant_id` bigint NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE oa_bpm_tenant_stmt FROM @oa_bpm_tenant_sql;
EXECUTE oa_bpm_tenant_stmt;
DEALLOCATE PREPARE oa_bpm_tenant_stmt;
SET @oa_bpm_tenant_sql = IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'bpm_category' AND column_name = 'tenant_id') = 0, 'ALTER TABLE `bpm_category` ADD COLUMN `tenant_id` bigint NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE oa_bpm_tenant_stmt FROM @oa_bpm_tenant_sql;
EXECUTE oa_bpm_tenant_stmt;
DEALLOCATE PREPARE oa_bpm_tenant_stmt;
SET @oa_bpm_tenant_sql = IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'bpm_form' AND column_name = 'tenant_id') = 0, 'ALTER TABLE `bpm_form` ADD COLUMN `tenant_id` bigint NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE oa_bpm_tenant_stmt FROM @oa_bpm_tenant_sql;
EXECUTE oa_bpm_tenant_stmt;
DEALLOCATE PREPARE oa_bpm_tenant_stmt;
SET @oa_bpm_tenant_sql = IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'bpm_process_expression' AND column_name = 'tenant_id') = 0, 'ALTER TABLE `bpm_process_expression` ADD COLUMN `tenant_id` bigint NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE oa_bpm_tenant_stmt FROM @oa_bpm_tenant_sql;
EXECUTE oa_bpm_tenant_stmt;
DEALLOCATE PREPARE oa_bpm_tenant_stmt;
SET @oa_bpm_tenant_sql = IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'bpm_process_listener' AND column_name = 'tenant_id') = 0, 'ALTER TABLE `bpm_process_listener` ADD COLUMN `tenant_id` bigint NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE oa_bpm_tenant_stmt FROM @oa_bpm_tenant_sql;
EXECUTE oa_bpm_tenant_stmt;
DEALLOCATE PREPARE oa_bpm_tenant_stmt;
SET @oa_bpm_tenant_sql = IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'bpm_oa_leave' AND column_name = 'tenant_id') = 0, 'ALTER TABLE `bpm_oa_leave` ADD COLUMN `tenant_id` bigint NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE oa_bpm_tenant_stmt FROM @oa_bpm_tenant_sql;
EXECUTE oa_bpm_tenant_stmt;
DEALLOCATE PREPARE oa_bpm_tenant_stmt;
SET @oa_bpm_tenant_sql = IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'bpm_process_definition_info' AND column_name = 'tenant_id') = 0, 'ALTER TABLE `bpm_process_definition_info` ADD COLUMN `tenant_id` bigint NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE oa_bpm_tenant_stmt FROM @oa_bpm_tenant_sql;
EXECUTE oa_bpm_tenant_stmt;
DEALLOCATE PREPARE oa_bpm_tenant_stmt;
SET @oa_bpm_tenant_sql = IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'bpm_process_instance_copy' AND column_name = 'tenant_id') = 0, 'ALTER TABLE `bpm_process_instance_copy` ADD COLUMN `tenant_id` bigint NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE oa_bpm_tenant_stmt FROM @oa_bpm_tenant_sql;
EXECUTE oa_bpm_tenant_stmt;
DEALLOCATE PREPARE oa_bpm_tenant_stmt;
