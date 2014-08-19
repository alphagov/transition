-- MySQL dump 10.13  Distrib 5.5.37, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: transition_development
-- ------------------------------------------------------
-- Server version	5.5.37-0ubuntu0.12.04.1-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `daily_hit_totals`
--

DROP TABLE IF EXISTS `daily_hit_totals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `daily_hit_totals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host_id` int(11) NOT NULL,
  `http_status` varchar(3) COLLATE utf8_unicode_ci NOT NULL,
  `count` int(11) NOT NULL,
  `total_on` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_daily_hit_totals_on_host_id_and_total_on_and_http_status` (`host_id`,`total_on`,`http_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hits`
--

DROP TABLE IF EXISTS `hits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host_id` int(11) NOT NULL,
  `path` varchar(1024) COLLATE utf8_bin NOT NULL,
  `path_hash` varchar(40) COLLATE utf8_bin NOT NULL,
  `http_status` varchar(3) COLLATE utf8_bin NOT NULL,
  `count` int(11) NOT NULL,
  `hit_on` date NOT NULL,
  `mapping_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_hits_on_host_id_and_path_hash_and_hit_on_and_http_status` (`host_id`,`path_hash`,`hit_on`,`http_status`),
  KEY `index_hits_on_host_id` (`host_id`),
  KEY `index_hits_on_host_id_and_hit_on` (`host_id`,`hit_on`),
  KEY `index_hits_on_host_id_and_http_status` (`host_id`,`http_status`),
  KEY `index_hits_on_mapping_id` (`mapping_id`),
  KEY `index_hits_on_path_hash` (`path_hash`),
  KEY `index_hits_on_host_id_and_path_hash` (`host_id`,`path_hash`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hits_staging`
--

DROP TABLE IF EXISTS `hits_staging`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hits_staging` (
  `hostname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `path` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `http_status` varchar(3) COLLATE utf8_unicode_ci DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  `hit_on` date DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `host_paths`
--

DROP TABLE IF EXISTS `host_paths`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `host_paths` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `path` varchar(2048) COLLATE utf8_bin DEFAULT NULL,
  `path_hash` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `c14n_path_hash` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `host_id` int(11) DEFAULT NULL,
  `mapping_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_host_paths_on_host_id_and_path_hash` (`host_id`,`path_hash`),
  KEY `index_host_paths_on_c14n_path_hash` (`c14n_path_hash`),
  KEY `index_host_paths_on_mapping_id` (`mapping_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hosts`
--

DROP TABLE IF EXISTS `hosts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hosts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `hostname` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `ttl` int(11) DEFAULT NULL,
  `cname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `live_cname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `ip_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `canonical_host_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_hosts_on_host` (`hostname`),
  KEY `index_hosts_on_site_id` (`site_id`),
  KEY `index_hosts_on_canonical_host_id` (`canonical_host_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `imported_hits_files`
--

DROP TABLE IF EXISTS `imported_hits_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `imported_hits_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filename` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content_hash` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mappings`
--

DROP TABLE IF EXISTS `mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `path` varchar(1024) COLLATE utf8_unicode_ci NOT NULL,
  `path_hash` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `new_url` text COLLATE utf8_unicode_ci,
  `suggested_url` text COLLATE utf8_unicode_ci,
  `archive_url` text COLLATE utf8_unicode_ci,
  `from_redirector` tinyint(1) DEFAULT '0',
  `type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `hit_count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_mappings_on_site_id_and_path_hash` (`site_id`,`path_hash`),
  KEY `index_mappings_on_site_id` (`site_id`),
  KEY `index_mappings_on_site_id_and_type` (`site_id`,`type`),
  KEY `index_mappings_on_hit_count` (`hit_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mappings_batch_entries`
--

DROP TABLE IF EXISTS `mappings_batch_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mappings_batch_entries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `path` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mappings_batch_id` int(11) DEFAULT NULL,
  `mapping_id` int(11) DEFAULT NULL,
  `processed` tinyint(1) DEFAULT '0',
  `klass` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `new_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mappings_batch_entries_on_mappings_batch_id` (`mappings_batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mappings_batches`
--

DROP TABLE IF EXISTS `mappings_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mappings_batches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_list` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `new_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `update_existing` tinyint(1) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `site_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'unqueued',
  `seen_outcome` tinyint(1) DEFAULT '0',
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `klass` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mappings_batches_on_user_id_and_site_id` (`user_id`,`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mappings_staging`
--

DROP TABLE IF EXISTS `mappings_staging`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mappings_staging` (
  `old_url` mediumtext COLLATE utf8_unicode_ci,
  `new_url` mediumtext COLLATE utf8_unicode_ci,
  `host` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `path` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `path_hash` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `suggested_url` mediumtext COLLATE utf8_unicode_ci,
  `archive_url` mediumtext COLLATE utf8_unicode_ci,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organisational_relationships`
--

DROP TABLE IF EXISTS `organisational_relationships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organisational_relationships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_organisation_id` int(11) DEFAULT NULL,
  `child_organisation_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_organisational_relationships_on_parent_organisation_id` (`parent_organisation_id`),
  KEY `index_organisational_relationships_on_child_organisation_id` (`child_organisation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organisations`
--

DROP TABLE IF EXISTS `organisations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organisations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `homepage` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `furl` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `css` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ga_profile_id` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `whitehall_slug` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `whitehall_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `abbreviation` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_organisations_on_whitehall_slug` (`whitehall_slug`),
  KEY `index_organisations_on_title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organisations_sites`
--

DROP TABLE IF EXISTS `organisations_sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organisations_sites` (
  `site_id` int(11) NOT NULL,
  `organisation_id` int(11) NOT NULL,
  UNIQUE KEY `index_organisations_sites_on_site_id_and_organisation_id` (`site_id`,`organisation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `data` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sites`
--

DROP TABLE IF EXISTS `sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organisation_id` int(11) NOT NULL,
  `abbr` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `query_params` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tna_timestamp` datetime NOT NULL,
  `homepage` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `global_new_url` text COLLATE utf8_unicode_ci,
  `managed_by_transition` tinyint(1) NOT NULL DEFAULT '1',
  `launch_date` date DEFAULT NULL,
  `special_redirect_strategy` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `global_redirect_append_path` tinyint(1) NOT NULL DEFAULT '0',
  `global_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `homepage_title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `homepage_furl` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sites_on_site` (`abbr`),
  KEY `index_sites_on_organisation_id` (`organisation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `taggings`
--

DROP TABLE IF EXISTS `taggings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) DEFAULT NULL,
  `taggable_id` int(11) DEFAULT NULL,
  `taggable_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tagger_id` int(11) DEFAULT NULL,
  `tagger_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `context` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `taggings_idx` (`tag_id`,`taggable_id`,`taggable_type`,`context`,`tagger_id`,`tagger_type`),
  KEY `index_taggings_on_taggable_type_and_taggable_id` (`taggable_type`,`taggable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `taggings_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_tags_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `uid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `permissions` text COLLATE utf8_unicode_ci,
  `remotely_signed_out` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `organisation_slug` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_robot` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `versions`
--

DROP TABLE IF EXISTS `versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `item_id` int(11) NOT NULL,
  `event` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `whodunnit` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `object_changes` text COLLATE utf8_unicode_ci,
  `object` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_versions_on_item_type_and_item_id` (`item_type`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `whitelisted_hosts`
--

DROP TABLE IF EXISTS `whitelisted_hosts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whitelisted_hosts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hostname` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_whitelisted_hosts_on_hostname` (`hostname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-08-15 11:13:20
INSERT INTO schema_migrations (version) VALUES ('20130910133049');

INSERT INTO schema_migrations (version) VALUES ('20130910135517');

INSERT INTO schema_migrations (version) VALUES ('20130913124740');

INSERT INTO schema_migrations (version) VALUES ('20130918110810');

INSERT INTO schema_migrations (version) VALUES ('20130925162249');

INSERT INTO schema_migrations (version) VALUES ('20130926082808');

INSERT INTO schema_migrations (version) VALUES ('20130927131427');

INSERT INTO schema_migrations (version) VALUES ('20131010115334');

INSERT INTO schema_migrations (version) VALUES ('20131010140146');

INSERT INTO schema_migrations (version) VALUES ('20131018160637');

INSERT INTO schema_migrations (version) VALUES ('20131023082026');

INSERT INTO schema_migrations (version) VALUES ('20131104141642');

INSERT INTO schema_migrations (version) VALUES ('20131106102619');

INSERT INTO schema_migrations (version) VALUES ('20131107192158');

INSERT INTO schema_migrations (version) VALUES ('20131107202738');

INSERT INTO schema_migrations (version) VALUES ('20131108121241');

INSERT INTO schema_migrations (version) VALUES ('20131112133657');

INSERT INTO schema_migrations (version) VALUES ('20131127140136');

INSERT INTO schema_migrations (version) VALUES ('20131127164943');

INSERT INTO schema_migrations (version) VALUES ('20131128120152');

INSERT INTO schema_migrations (version) VALUES ('20131128150000');

INSERT INTO schema_migrations (version) VALUES ('20131128155022');

INSERT INTO schema_migrations (version) VALUES ('20131202093544');

INSERT INTO schema_migrations (version) VALUES ('20131202174921');

INSERT INTO schema_migrations (version) VALUES ('20131203102650');

INSERT INTO schema_migrations (version) VALUES ('20131203115518');

INSERT INTO schema_migrations (version) VALUES ('20131231133153');

INSERT INTO schema_migrations (version) VALUES ('20140127151418');

INSERT INTO schema_migrations (version) VALUES ('20140127151419');

INSERT INTO schema_migrations (version) VALUES ('20140225152616');

INSERT INTO schema_migrations (version) VALUES ('20140225161453');

INSERT INTO schema_migrations (version) VALUES ('20140225175741');

INSERT INTO schema_migrations (version) VALUES ('20140227154306');

INSERT INTO schema_migrations (version) VALUES ('20140227154752');

INSERT INTO schema_migrations (version) VALUES ('20140228173250');

INSERT INTO schema_migrations (version) VALUES ('20140228174448');

INSERT INTO schema_migrations (version) VALUES ('20140331115315');

INSERT INTO schema_migrations (version) VALUES ('20140331121029');

INSERT INTO schema_migrations (version) VALUES ('20140404112839');

INSERT INTO schema_migrations (version) VALUES ('20140417100412');

INSERT INTO schema_migrations (version) VALUES ('20140422160500');

INSERT INTO schema_migrations (version) VALUES ('20140422184036');

INSERT INTO schema_migrations (version) VALUES ('20140502114341');

INSERT INTO schema_migrations (version) VALUES ('20140502160711');

INSERT INTO schema_migrations (version) VALUES ('20140507103006');

INSERT INTO schema_migrations (version) VALUES ('20140515135431');

INSERT INTO schema_migrations (version) VALUES ('20140520154514');

INSERT INTO schema_migrations (version) VALUES ('20140523100338');

INSERT INTO schema_migrations (version) VALUES ('20140528161617');

INSERT INTO schema_migrations (version) VALUES ('20140529130515');

INSERT INTO schema_migrations (version) VALUES ('20140529164329');

INSERT INTO schema_migrations (version) VALUES ('20140606155408');

INSERT INTO schema_migrations (version) VALUES ('20140611144610');

INSERT INTO schema_migrations (version) VALUES ('20140618092821');

INSERT INTO schema_migrations (version) VALUES ('20140618145219');

INSERT INTO schema_migrations (version) VALUES ('20140623135055');

INSERT INTO schema_migrations (version) VALUES ('20140724164511');

INSERT INTO schema_migrations (version) VALUES ('20140815095728');


