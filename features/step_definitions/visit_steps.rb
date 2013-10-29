When(/^I visit the home page$/) do
  visit '/'
end

When(/^I visit the path (.*)$/) do |path|
  visit path
end

When(/^I go to edit that mapping$/) do
  visit edit_site_mapping_path(@mapping.site, @mapping)
end

When(/^I visit the associated organisation$/) do
  visit organisation_path(@site.organisation)
end

When(/^I visit the associated site's hits$/) do
  visit site_hits_path(@site)
end

Given(/^I am on the Attorney General's office site's hits page$/) do
  visit site_hits_path(@site)
end
