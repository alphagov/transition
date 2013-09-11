Then(/^I should see the header "([^"]*)"$/) do |header_text|
  expect(page).to have_selector('h1,h2,h3,h4,h5,h6', text: header_text)
end

Then(/^I should see a table with class "([^"]*)" containing (\d+) rows$/) do |classname, row_count|
  expect(page).to have_selector("table.#{classname} tbody tr", count: row_count)
end

Then(/^I should see "([^"]*)"$/) do |text|
  expect(page).to have_content(text)
end