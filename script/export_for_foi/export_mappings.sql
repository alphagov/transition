COPY (
  SELECT
    sites.abbr AS "Abbreviation",
    path AS "Old Path",
    new_url AS "Redirect URL",
    suggested_url AS "Suggested URL",
    archive_url AS "Custom Archive URL",
    CASE type WHEN 'unresolved' THEN 410 WHEN 'archive' THEN 410 WHEN 'redirect' THEN 301 END AS http_status
    FROM mappings
    INNER JOIN sites ON mappings.site_id = sites.id
    WHERE sites.global_type IS NULL
    ORDER BY sites.abbr, path
) TO STDOUT WITH DELIMITER ',' CSV HEADER;
