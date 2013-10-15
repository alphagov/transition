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
