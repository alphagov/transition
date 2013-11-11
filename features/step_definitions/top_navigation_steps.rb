Then(/^I should see a link to "(.*?)" in the header$/) do |link_text|
  expect(page).to have_selector("header a", text: link_text)
end
