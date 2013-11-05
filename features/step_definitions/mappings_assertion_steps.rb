Then(/^I should be returned to the mappings list for (.*)$/) do |site_abbr|
  expect(current_path).to eql(site_mappings_path(site_abbr))
end

Then(/^I should still be editing a mapping$/) do
  step 'I should see "Edit mapping"'
end

Then(/^the filter box should contain "([^"]*)"$/) do |path|
  expect(page).to have_field('Filter by path', with: path)
end

Then(/^I should see a link to remove the filter$/) do
  expect(page).to have_link('Remove filter')
end

Then(/^I should see no history$/) do
  expect(page).not_to have_link('History')
end

Then(/^I should see that (.*) was changed from (.*) to (.*)$/) do |field_name, old_value, new_value|
  within '.versions' do
    expect(page).to have_content(field_name)
    expect(page).to have_content(old_value)
    expect(page).to have_content(new_value)
  end
end

Then(/^I should see redirect fields$/) do
  within '.js-edit-mapping-form' do
    expect(page).to have_selector('.js-for-redirect')
  end
end

Then(/^I should not see redirect fields$/) do
  within '.js-edit-mapping-form' do
    expect(page).not_to have_selector('.js-for-redirect')
  end
end

Then(/^I should see archive fields$/) do
  within '.js-edit-mapping-form' do
    expect(page).to have_selector('.js-for-archive')
  end
end

Then(/^I should not see archive fields$/) do
  within '.js-edit-mapping-form' do
    expect(page).not_to have_selector('.js-for-archive')
  end
end
