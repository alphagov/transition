crumb :root do
  link "Organisations", organisations_path
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

crumb :mappings do |site|
  link 'Mappings', site_mappings_path(site)
  parent :site, site
end

crumb :new_mapping do |mapping|
  link "New mapping"
  parent :mappings, mapping.site
end

crumb :new_mappings do |site|
  link "New mappings", new_multiple_site_mappings_path(site)
  parent :mappings, site
end

crumb :new_mappings_confirmation do |site|
  link "Confirm new mappings"
  parent :new_mappings, site
end

crumb :edit_mapping do |mapping|
  link "Edit mapping", edit_site_mapping_path(mapping.site, mapping)
  parent :mappings, mapping.site
end

crumb :history do |mapping|
  link "History", site_mapping_versions_path(mapping.site, mapping)
  parent :edit_mapping, mapping
end

crumb :edit_multiple_mappings do |site|
  link "Edit multiple mappings", edit_multiple_site_mappings_path(site)
  parent :mappings, site
end
