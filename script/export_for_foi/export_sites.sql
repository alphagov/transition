COPY (
  SELECT
    abbr AS "Abbreviation",
    launch_date AS "Launch Date",
    homepage AS "New Homepage",
    query_params AS "Significant querystring parameters (colon separated)",
    CASE global_type WHEN 'unresolved' THEN 410 WHEN 'archive' THEN 410 WHEN 'redirect' THEN 301 END AS global_http_status,
    global_new_url AS "New URL for global 301",
    CASE global_redirect_append_path WHEN 'f' THEN 'false' WHEN 't' THEN 'true' END AS "Append requested path to new path? (for global 301)"
    FROM sites
    ORDER BY abbr
) TO STDOUT WITH DELIMITER ',' CSV HEADER;
