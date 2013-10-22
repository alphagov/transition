CREATE TABLE `hits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host_id` int(11) NOT NULL,
  `path` varchar(1024) COLLATE utf8_bin NOT NULL,
  `path_hash` varchar(40) COLLATE utf8_bin NOT NULL,
  `http_status` varchar(3) COLLATE utf8_bin NOT NULL,
  `count` int(11) NOT NULL,
  `hit_on` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_hits_on_host_id_and_path_hash_and_hit_on_and_http_status` (`host_id`,`path_hash`,`hit_on`,`http_status`),
  KEY `index_hits_on_host_id` (`host_id`),
  KEY `index_hits_on_host_id_and_hit_on` (`host_id`,`hit_on`),
  KEY `index_hits_on_host_id_and_http_status` (`host_id`,`http_status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE `hits_staging` (
  `hostname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `path` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `http_status` varchar(3) COLLATE utf8_unicode_ci DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  `hit_on` date DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `hosts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `hostname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ttl` int(11) DEFAULT NULL,
  `cname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `live_cname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_hosts_on_host` (`hostname`),
  KEY `index_hosts_on_site_id` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `mappings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `path` varchar(1024) COLLATE utf8_unicode_ci NOT NULL,
  `path_hash` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `http_status` varchar(3) COLLATE utf8_unicode_ci NOT NULL,
  `new_url` text COLLATE utf8_unicode_ci,
  `suggested_url` text COLLATE utf8_unicode_ci,
  `archive_url` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_mappings_on_site_id_and_path_hash` (`site_id`,`path_hash`),
  KEY `index_mappings_on_site_id_and_http_status` (`site_id`,`http_status`),
  KEY `index_mappings_on_site_id` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `mappings_staging` (
  `old_url` mediumtext COLLATE utf8_unicode_ci,
  `new_url` mediumtext COLLATE utf8_unicode_ci,
  `http_status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `host` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `path` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `path_hash` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `suggested_url` mediumtext COLLATE utf8_unicode_ci,
  `archive_url` mediumtext COLLATE utf8_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `organisations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `abbr` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `launch_date` date DEFAULT NULL,
  `homepage` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `furl` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `css` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ga_profile_id` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_organisations_on_abbr` (`abbr`),
  KEY `index_organisations_on_title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `sites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organisation_id` int(11) DEFAULT NULL,
  `abbr` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `query_params` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tna_timestamp` datetime DEFAULT NULL,
  `homepage` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `global_http_status` varchar(3) COLLATE utf8_unicode_ci DEFAULT NULL,
  `global_new_url` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sites_on_site` (`abbr`),
  KEY `index_sites_on_organisation_id` (`organisation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `uid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `permissions` text COLLATE utf8_unicode_ci,
  `remotely_signed_out` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

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
