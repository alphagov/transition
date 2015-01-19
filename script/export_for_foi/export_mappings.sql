COPY (
  SELECT sites.abbr, path, new_url, suggested_url, archive_url,
    CASE type WHEN 'unresolved' THEN 410 WHEN 'archive' THEN 410 WHEN 'redirect' THEN 301 END AS http_status
    FROM mappings
    INNER JOIN sites ON mappings.site_id = sites.id
    WHERE sites.global_type IS NULL
) TO STDOUT WITH DELIMITER ',' CSV HEADER;
