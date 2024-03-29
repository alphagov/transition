When(/^I visit the home page$/) do
  visit "/"
end

When(/^I visit the path (.*)$/) do |path|
  visit path
end

When(/^I visit the associated site$/) do
  visit site_path(@site)
end

When(/^I visit the associated site's hits$/) do
  visit site_hits_path(@site)
end

When(/^I visit the associated site's hits summary$/) do
  visit summary_site_hits_path(@site)
end

Given(/^I am on the Attorney General's office site's hits page$/) do
  visit site_hits_path(@site)
end

When(/^I visit the organisation's page$/) do
  visit organisation_path(@organisation)
end
