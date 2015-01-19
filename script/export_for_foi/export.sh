#!/bin/bash

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo 'Started site export'
psql -d transition_development -f ./export_sites.sql > ./sites-$timestamp.csv
echo 'Finished site export'

echo 'Started hosts export'
psql -d transition_development -f ./export_hosts.sql > ./hosts-$timestamp.csv
echo 'Finished hosts export'

echo 'Started mappings export'
psql -d transition_development -f ./export_mappings.sql > ./mappings-$timestamp.csv
echo 'Finished mappings export'
