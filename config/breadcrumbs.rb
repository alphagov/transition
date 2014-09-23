crumb :root do
  link 'Organisations', organisations_path
end

crumb :organisation do |organisation|
  link organisation.title, organisation_path(organisation)
  parent :root
end

crumb :site do |site|
  link site.default_host.hostname, site_path(site)
  parent :organisation, site.organisation
end

crumb :hits do |site|
  link 'Analytics', site_mappings_path(site)
  parent :site, site
end

crumb :universal_hits do
  link 'Universal analytics', hits_path
  parent :root
end

crumb :mappings do |site|
  link 'Mappings', site_mappings_path(site)
  parent :site, site
end

crumb :filter_mappings do |site|
  link 'Filter mappings', site_mappings_path(site)
  parent :mappings, site
end

crumb :filtered_mappings do |site|
  link 'Filtered mappings', site_mappings_path(site)
  parent :mappings, site
end

crumb :new_mappings do |site|
  link 'Add mappings', new_site_bulk_add_batch_path(site)
  parent :mappings, site
end

crumb :new_mappings_confirmation do |site|
  link 'Confirm new mappings'
  parent :new_mappings, site
end

crumb :edit_mapping do |mapping|
  link 'Edit mapping', edit_site_mapping_path(mapping.site, mapping)
  parent :mappings, mapping.site
end

crumb :edit_site do |site|
  link 'Edit site', edit_site_path(site)
  parent :site, site
end

crumb :history do |mapping|
  link 'History', site_mapping_versions_path(mapping.site, mapping)
  parent :edit_mapping, mapping
end

crumb :edit_multiple_mappings do |site|
  link 'Edit multiple mappings', edit_multiple_site_mappings_path(site)
  parent :mappings, site
end

crumb :import_mappings do |site|
  link "Import mappings", new_site_import_batch_path(site)
  parent :site, site
end

crumb :preview_import_mappings do |site, batch|
  link "Preview import", preview_site_import_batch_path(site, batch)
  parent :import_mappings, site
end
