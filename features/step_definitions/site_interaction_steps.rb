When(/^I visit the page for the (.*) organisation$/) do |organisation_title|
  organisation = Organisation.find_by(title: organisation_title)
  visit organisation_path(organisation)
end

When(/^I visit this site page$/) do
  visit site_path(@site)
end

When(/^I edit this site's transition date$/) do
  click_link "Edit date"
  select("2014", from: "site_launch_date_1i")
  select("September", from: "site_launch_date_2i")
  select("20", from: "site_launch_date_3i")
  click_button "Save"
end

When(/^I fill in the new transition site fields/) do
  fill_in "Abbreviated name", with: "aaib"
  fill_in "TNA timestamp", with: "20141104112824"
  fill_in "Homepage", with: "https://www.gov.uk/government/organisations/air-accidents-investigation-branch"
  fill_in "Hostname", with: "www.aaib.gov.uk"
  fill_in "Homepage title", with: "Air accidents investigation branch"
  select "Government Office for Science"
  fill_in "Homepage full URL", with: "www.gov.uk/aaib"
  choose "Redirect"
  fill_in "Global new URL", with: "https://www.gov.uk/government/organisations/air-accidents-investigation-branch/about"
  fill_in "Query params", with: "file"
  check "Should the path the user supplied be appended to the URL for the global redirect?"
  choose "Via AKA"
  fill_in "Aliases", with: "aaib.gov.uk,aaib.com"
end

Then(/^I should be on the new transition site page for the (.*) organisation$/) do |organisation_title|
  organisation = Organisation.find_by(title: organisation_title)
  i_should_be_on_the_path new_organisation_site_path(organisation)
end

Then(/^I should be redirected to the new site$/) do
  i_should_be_on_the_path site_path(Site.last)
end

When(/^I delete this site$/) do
  click_link "Delete"
end

When(/^I confirm the deletion$/) do
  fill_in "delete_site_form[abbr_confirmation]", with: @site.abbr
  click_button I18n.t("site.confirm_destroy.confirm")
end

When(/^I fail to confirm the deletion$/) do
  fill_in "delete_site_form[abbr_confirmation]", with: "bogus"
  click_button I18n.t("site.confirm_destroy.confirm")
end
