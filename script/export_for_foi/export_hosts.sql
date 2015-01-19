COPY (
  SELECT sites.abbr, hostname
    FROM hosts
    INNER JOIN sites ON hosts.site_id = sites.id
) TO STDOUT WITH DELIMITER ',' CSV HEADER;
