When(/^I go to create some mappings$/) do
  steps %{
    And I click the first link called "Add mappings"
  }
end

When(/^I make the mapping a redirect to (.*)$/) do |new_url|
  select 'Redirect', from: 'Type'
  fill_in 'Redirects to', with: new_url
end

When(/^I make the mapping an archive$/) do
  select 'Archive', from: 'Type'
end

When(/^I continue?$/) do
  click_button 'Continue'
end

When(/^I save the mappings?$/) do
  click_button 'Save'
end

When(/^I go to edit the first mapping$/) do
  click_link 'Edit'
end

When(/^I select the first two mappings$/) do
  find(:css, ".mappings tbody tr:first-child input").set(true)
  find(:css, ".mappings tbody tr:first-child + tr input").set(true)
end

When(/^I select the first (\d+) mappings$/) do |count|
  count.to_i.times do |i|
    find(:css, ".mappings tbody tr input[value='#{i + 1}']").set(true)
  end
end

When(/^I select all the mappings$/) do
  find(:css, ".mappings thead input.js-toggle-all").set(true)
end

When (/^I go to edit the selected mappings$/) do
  click_button "Edit selected"
end

When(/^I select "Archive"$/) do
  choose 'Archive'
end

When(/^I open the "(.*)" filter$/) do |filter_type|
  within '.filters' do
    click_link filter_type
  end
end

When(/^I open the "(.*)" filter and filter by "(.*)"$/) do |filter_type, value|
  within '.filters' do
    click_link filter_type
    fill_in filter_type, with: value
    click_button 'Filter'
  end
end

When(/^I open the "(.*)" filter and select "(.*)"$/) do |filter_type, link|
  within '.filters' do
    click_link filter_type
    click_link link
  end
end

When(/^I open the tag filter and click the tag "(.*)"$/) do |tag|
  step 'I open the "Tag" filter'
  step "I click the tag filter \"#{tag}\""
end

When(/^I filter the path by ([^"]*)$/) do |path_contains|
  fill_in 'Path', with: path_contains
  click_button 'Filter'
end

When(/^I remove the filter "(.*?)"$/) do |filter_type|
  click_link filter_type
end

When(/^I click the tag filter "(.*?)"$/) do |tag_filter|
  within '.filters' do
    click_link tag_filter
  end
end

When(/^I change the mapping's redirect to (.*)$/) do |value|
  fill_in 'Redirects to', with: value
  step 'I save the mapping'
end

When(/^I make the new mapping paths "(.*)" redirect to (.*)$/) do |paths, new_url|
  fill_in 'Old URLs', with: paths.gsub(/, /, "\n")
  fill_in 'Redirect to', with: new_url
end

When(/^I enter an archive URL but then click "Cancel"$/) do
  fill_in 'Alternative National Archives URL', with: 'anything'
  click_link 'Cancel'
end

When(/^I enter a new URL to redirect to$/) do
  fill_in 'Redirect to', with: 'https://www.gov.uk'
end

When(/^I edit that mapping$/) do
  visit edit_site_mapping_path(@site, @mapping)
end

When(/^I associate the tags "([^"]*)" with the mappings?$/) do |comma_separated_tags|
  fill_in 'Tags', with: comma_separated_tags
end


When(/^I add multiple paths with tags "([^"]*)" and continue$/) do |tag_list|
  visit new_multiple_site_mappings_path(@site)

  step 'I make the new mapping paths "/1, /2, /3" redirect to www.gov.uk/organisations/ukba'
  step "I associate the tags \"#{tag_list}\" with the mappings"
  step 'I continue'
end

When(/^I choose "([^"]*)"$/) do |radio_label|
  choose(radio_label)
end

When(/^I remove the tag "([^"]*)"$/) do |tag|
  page.find('.filtered-tags a', text: tag).click
end

When(/^I select the first two mappings and go to tag them$/) do
  visit site_mappings_path(@site)

  step 'I select the first two mappings'

  if @_javascript
    within '.mappings' do
      first(:link, 'Tag').click
    end
  else
    choose 'Tag'
    click_button 'Edit selected'
  end
end

When(/^I delete "(?:[^"]*)" and tag the mappings "([^"]*)"$/) do |tag_list|
  i_tag_the_mappings tag_list
end

When(/^I type "([^"]*)" in the tags box$/) do |letters|
  fill_in 'Tags', with: letters
end

When(/^I jump to the mapping "(.*?)"$/) do |url|
  page.execute_script("Mousetrap.trigger('g m');")
  fill_in 'Old URL', with: url
  click_button 'Go to mapping'
end
