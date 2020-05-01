Then(/^I should see "([^"]*)"$/) do |text|
  expect(page).to have_content(text)
end

Then(/^I should not see "([^"]*)"$/) do |content|
  expect(page).not_to have_content(content)
end

Then(/^there should be a tooltip which includes "([^"]*)"$/) do |text|
  expect(page).to have_selector("[title*='#{text}']")
end

Then(/^I should see a flash message "(.*?)"$/) do |text|
  expect(page).to have_selector("div.alert", text: text)
end

# Modals

Then(/^I should see an open modal window$/) do
  expect(page).to have_selector(".modal-backdrop")
  expect(page).to have_selector(".modal")
end

Then(/^I should see "([^"]*)" in (?:a|the) modal window$/) do |text|
  expect(page).to have_selector(".modal", text: text)
end

Then(/^I should not see a modal window$/) do
  expect(page).to_not have_selector(".modal")
end

# Title

Then(/^the page title should be "([^"]*)"$/) do |title|
  expect(page).to have_title(title)
end

# Links

Then(/^I should see a link to "([^"]*)"$/) do |title|
  expect(page).to have_link(title)
end

# Pagination

Then(/^I should see links top and bottom to page ([0-9]+)$/) do |page_number|
  expect(page).to have_link(page_number, count: 2)
end

Then(/^I should see (\d+) as the current page$/) do |page_number|
  expect(page).to have_selector("span.page.current", text: page_number)
end

# Google analytics tracking

Then(/^an automatic analytics event with "([^"]*)" will fire$/) do |contents|
  expect(page).to have_selector(
    "[data-module='auto-track-event'][data-track-label*='#{contents}']",
  )
end

# HTML structure

Then(/^I should see the header "([^"]*)"$/) do |header_text|
  expect(page).to have_selector("h1,h2,h3,h4,h5,h6", text: header_text)
end

Then(/^I should see an? ([^ ]*) table with (\d+) rows?$/) do |type, row_count|
  expect(page).to have_selector("table.#{type} tbody tr", count: row_count)
end

# Forms

Then(/^the "([^"]*)" value should be "([^"]*)"/) do |label, value|
  expect(page).to have_field(label, with: value)
end

# Status codes

Then(/^I should see our custom 404 page$/) do
  steps %(
    Then I should see "Page could not be found"
    And I should see a link to "GOV.UK Transition"
  )
end

Then(/^I should see our custom 500 page$/) do
  page.status_code.should eql(500)
  steps %(
    Then I should see "sorry, something went wrong"
    And I should see a link to "GOV.UK Transition"
  )
end

# Content-Type

Then(/^I should see JSON$/) do
  expect(page.response_headers["Content-Type"]).to include("application/json")
end
