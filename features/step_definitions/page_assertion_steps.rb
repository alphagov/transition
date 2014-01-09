Then(/^I should see "([^"]*)"$/) do |text|
  expect(page).to have_content(text)
end

Then(/^I should not see "([^"]*)"$/) do |content|
  expect(page).not_to have_content(content)
end

Then(/^there should be a tooltip "([^"]*)"$/) do |text|
  expect(page).to have_selector("[title='#{text}']")
end

Then(/^there should be a tooltip which includes "([^"]*)"$/) do |text|
  expect(page).to have_selector("[title*='#{text}']")
end

# Modals

Then(/^I should see an open modal window$/) do
  expect(page).to have_selector('.modal-backdrop')
  expect(page).to have_selector('.modal')
end

Then(/^I should see "([^"]*)" in (?:a|the) modal window$/) do |text|
  expect(page).to have_selector('.modal', text: text)
end

Then(/^I should not see "([^"]*)" in (?:a|the) modal window$/) do |text|
  expect(page).not_to have_selector('.modal', text: text)
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
  expect(page).to have_selector('span.page.current', text: page_number)
end

# HTML structure

Then(/^I should see the header "([^"]*)"$/) do |header_text|
  expect(page).to have_selector('h1,h2,h3,h4,h5,h6', text: header_text)
end

Then(/^I should see a table with class "([^"]*)" containing (\d+) rows?$/) do |classname, row_count|
  expect(page).to have_selector("table.#{classname} tbody tr", count: row_count)
end

# Forms

Then(/^the "([^"]*)" value should be "([^"]*)"/) do |label, value|
  expect(page).to have_field(label, with: value)
end
