Then(/^I should see "([^"]*)"$/) do |text|
  expect(page).to have_content(text)
end

Then(/^I should see the header "([^"]*)"$/) do |header_text|
  expect(page).to have_selector('h1,h2,h3,h4,h5,h6', text: header_text)
end

Then(/^I should see a table with class "([^"]*)" containing (\d+) rows?$/) do |classname, row_count|
  expect(page).to have_selector("table.#{classname} tbody tr", count: row_count)
end

Then(/^I should see a link to the URL (.*)$/) do |href|
  expect(page).to have_link('', href: href)
end

Then(/^I should see a link to the (.*) site's mappings$/) do |site_abbr|
  expect(page).to have_link('', href: site_mappings_path(site_abbr))
end

Then(/^I should see a link to the organisation (.*)$/) do |org_abbr|
  expect(page).to have_link('', href: organisation_path(org_abbr))
end

Then(/^I should see a link to page ([0-9]+)$/) do |page_number|
  expect(page).to have_link(page_number)
end

Then(/^I should see (\d+) as the current page$/) do |page_number|
  expect(page).to have_selector('span.page.current', text: page_number)
end

Then(/^the page title should be "([^"]*)"$/) do |title|
  expect(page).to have_title(title)
end