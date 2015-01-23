COPY (
  SELECT
    sites.abbr AS "Abbreviation",
    hostname
    FROM hosts
    INNER JOIN sites ON hosts.site_id = sites.id
    WHERE canonical_host_id IS NULL
    ORDER BY sites.abbr, hostname
) TO STDOUT WITH DELIMITER ',' CSV HEADER;
