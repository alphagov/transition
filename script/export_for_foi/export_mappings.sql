COPY (
  SELECT
    sites.abbr AS "Abbreviation",
    path AS "Old Path",
    CASE type WHEN 'unresolved' THEN 410 WHEN 'archive' THEN 410 WHEN 'redirect' THEN 301 END AS "HTTP status",
    new_url AS "Redirect URL",
    archive_url AS "Custom Archive URL",
    suggested_url AS "Suggested URL"
    FROM mappings
    INNER JOIN sites ON mappings.site_id = sites.id
    WHERE sites.global_type IS NULL
    ORDER BY sites.abbr, path
) TO STDOUT WITH DELIMITER ',' CSV HEADER;
