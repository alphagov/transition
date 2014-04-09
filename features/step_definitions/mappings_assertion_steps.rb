#encoding: UTF-8

Then(/^I should still be editing a mapping$/) do
  step 'I should see "Edit mapping"'
end

Then(/^I should be returned to the mappings list I was on$/) do
  uri = URI.parse(current_url)
  expect("#{uri.path}?#{uri.query}").to eql(site_mappings_path('bis', fake_param: 1))
end

Then(/^the "([^"]*)" filter should be visible and contain "([^"]*)"$/) do |filter_type, value|
  expect(page).to have_field(filter_type, with: value)
end

Then(/^the filter box should contain "([^"]*)"$/) do |path|
  expect(page).to have_field('Path', with: path)
end

Then(/^the tag filter should be visible with the tags? "([^"]*)"$/) do |tag_list|
  step "I should see a link to remove the tags \"#{tag_list}\""
end

Then(/^I should see a warning about an incompatible filter$/) do
  within '.filters' do
    expect(page).to have_selector('.alert-warning')
  end
end

Then(/^I should see the most popular tags for this site$/) do
  within '.filters .dropdown-menu' do
    should_have_links_to_tags(%w(fee fi fo fum fiddle))
  end
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
  within '[data-module="toggle-mapping-form-fields"]' do
    expect(page).to have_selector('.js-for-redirect')
  end
end

Then(/^I should not see redirect fields$/) do
  within '[data-module="toggle-mapping-form-fields"]' do
    expect(page).not_to have_selector('.js-for-redirect')
  end
end

Then(/^I should see archive fields$/) do
  within '[data-module="toggle-mapping-form-fields"]' do
    expect(page).to have_selector('.js-for-archive')
  end
end

Then(/^I should not see archive fields$/) do
  within '[data-module="toggle-mapping-form-fields"]' do
    expect(page).not_to have_selector('.js-for-archive')
  end
end

Then(/^I should see the National Archives link replaced with an alternative National Archives field$/) do
  expect(page).to have_selector('#mapping_archive_url')
  expect(page).not_to have_selector('a[href="#add-alternative-url"]')
end

Then(/^I should see the National Archives link again$/) do
  expect(page).not_to have_selector('#mapping_archive_url')
  expect(page).to have_selector('a[href="#add-alternative-url"]')
end

Then(/^the archive URL field should be empty$/) do
  field_labeled('Alternative National Archives URL').value.should be_empty
end

Then(/^I should see a form that contains my selection$/) do
  steps %{
    And I should see "/a"
    And I should see "/about/branding"
    But I should not see "/about/corporate"
  }
end

Then(/^I should see a form that contains my selection within the modal$/) do
  steps %{
    And I should see "/a" in the modal window
    And I should see "/about/branding" in the modal window
  }
  modal_should_not_contain('/about/corporate')
end

Then(/^I should see a table with (\d+) mappings? in the modal$/) do |count|
  expect(page).to have_selector('.modal .mappings tbody tr .breakable', count: count)
end

Then(/^I should see a table with (\d+) saved mappings? in the modal$/) do |count|
  expect(page).to have_selector('.modal .mappings tbody tr', count: count)
end

Then(/^I should see the link replaced with a suggested URL field$/) do
  expect(page).to have_selector('#mapping_suggested_url')
  expect(page).not_to have_selector('a[href="#suggest-url"]')
end

Then(/^I should see a "Redirect to" input$/) do
  expect(page).to have_selector('label', text: 'Redirect to')
end

Then(/^I should not see a "Redirect to" input$/) do
  expect(page).not_to have_selector('label', text: 'Redirect to')
end

Then(/^I should see a highlighted "(.*?)" label and field$/) do |label|
  expect(page).to have_selector('.field_with_errors label', text: label)

  label = find('label', text: label)
  expect(page).to have_selector(".field_with_errors *[name='#{label['for']}']")
end

Then(/^I should see options to ignore or overwrite the existing mappings$/) do
  expect(page).to have_field('Ignore existing mappings', type: 'radio')
  expect(page).to have_field('Overwrite existing mappings', type: 'radio')
end

Then(/^I should see that the mappings will redirect to "(.*?)"$/) do |new_url|
  step "I should see \"Redirect paths to #{new_url}\""
end

Then(/^I should see the canonicalized paths "(.*?)"$/) do |paths|
  paths.split(', ').each do |path|
    expect(page).to have_link(path)
  end
end

Then(/^I should see the tags "([^"]*)"$/) do |tag_list|
  expect(page).to have_field('Tags', with: tag_list)
end

Then(/^I should see that all were tagged "([^"]*)"$/) do |tag_list|
  within '.alert-success', :match => :first do
    expect(page).to have_content(
      %(3 mappings updated and tagged with "#{tag_list}")
    )
  end
end

Then(/^the mapping should have the tags "([^"]*)"$/) do |tag_list|
  expected_tags = tag_list.split(',').map(&:strip)
  within ".mappings-index .mapping-#{@mapping.id}" do
    expected_tags.each do |tag|
      expect(page).to have_selector('.tag', text: tag)
    end
  end
end

Then(/^the mappings should all have the tags "([^"]*)"$/) do |tag_list|
  expect(page).to have_selector('.mappings-index .tag-list', count: @site.mappings.count)

  expected_tags = tag_list.split(',').map(&:strip)
  page.all('.tag-list').each do |mapping_tags_list|
    expected_tags.each do |tag|
      expect(mapping_tags_list).to have_selector('.tag', text: tag)
    end
  end
end

Then(/^I should see that (\d+) were tagged "([^"]*)"$/) do |n, tag_list|
  within '.alert-success', :match => :first do
    expect(page).to have_content(
      %(#{n} mappings tagged “#{tag_list}”)
    )
  end
end

Then(/^I should see only the common tags "([^"]*)"$/) do |tag_list|
  if @_javascript
    tag_list.split(',').map(&:strip).each do |tag|
      expect(page).to have_selector('li.select2-search-choice', text: tag)
    end
  else
    expect(page).to have_field('Tags', with: tag_list)
  end
end

Then(/^mapping (\d+) should have the tags "([^"]*)"$/) do |nth, tag_list|
  within ".mappings-index tbody tr:nth-child(#{nth}) .tag-list" do
    tag_list.split(',').map(&:strip).each do |tag|
      expect(page).to have_selector('.tag', text:tag)
    end
  end
end

Then(/^mapping (\d+) should have the tags "([^"]*)" but not "([^"]*)"$/) do |nth, tag_list, without_tag_list|
  within ".mappings-index tbody tr:nth-child(#{nth}) .tag-list" do
    tag_list.split(',').map(&:strip).each do |tag|
      expect(page).to have_selector('.tag', text:tag)
    end
    without_tag_list.split(',').map(&:strip).each do |without_tag|
      expect(page).not_to have_selector('.tag', text: without_tag)
    end
  end
end

Then(/^I should see "([^"]*)" available for selection$/) do |tag|
  expect(page).to have_selector('.select2-results .select2-result-label', text: tag)
end

But(/^I should not see "([^"]*)" available for selection$/) do |tag|
  expect(page).not_to have_selector('.select2-results .select2-result-label', text: tag)
end

But(/^I should not see "([^"]*)" available for selection as it's already selected$/) do |tag|
  step %Q{I should not see "#{tag}" available for selection}
end

Then(/^I should see the highlighted tags? "([^"]*)"$/) do |tag_list|
  within ".mappings tbody tr:first-child .tag-list" do
    tag_list.split(',').map(&:strip).each do |tag|
      expect(page).to have_selector('.tag-active', text:tag)
    end
  end
end

Then(/^I should see a link to remove the tags? "([^"]*)"$/) do |tag_list|
  within ".filtered-tags" do
    tag_list.split(',').map(&:strip).each do |tag|
      expect(page).to have_selector('.tag', text:tag)
    end
  end
end

Then(/^I should see mappings tagged with "fum"$/) do
  steps %{
    And I should see "/about/corporate"
    And I should see "/about/branding"
    But I should not see "/another"
  }
end

Then(/^I should see mappings tagged with "fum" and "fiddle"$/) do
  steps %{
    And I should see "/about/corporate"
    But I should not see "/about/branding"
    And I should not see "/another"
  }
end

<<<<<<< HEAD
Then(/^I should be redirected to the site dashboard$/) do
  i_should_be_on_the_path site_path(@site)
end

Then(/^I should see a link to preview a mapping in the side\-by\-side browser$/) do
  expect(page).to have_link('Preview')
end

Then(/^I should not see a link to preview a mapping in the side\-by\-side browser$/) do
  expect(page).to_not have_link('Preview')
=======
Then(/^I should see a column with traffic information$/) do
  within 'table.mappings .table-header' do
    expect(page).to have_selector('th:nth-child(4)', text: 'Hits')
  end
end

Then(/^I should not see a column with traffic information$/) do
  within 'table.mappings .table-header' do
    expect(page).not_to have_selector('th:nth-child(4)', text: 'Hits')
  end
end

Then(/^the cells should have hit counts$/) do
  within 'table.mappings tbody' do
    expect(page).to have_selector('tr:first-child td.mapping-hits-column span.hit-count',
                                  text: /^210$/)
    expect(page).to have_selector('tr:nth-child(2) td.mapping-hits-column span.hit-count',
                                  text: /^140$/)
    expect(page).to have_selector('tr:nth-child(3) td.mapping-hits-column span.hit-count',
                                  text: /^70$/)
  end
end

Then(/^the cells should have percentages$/) do
  within 'table.mappings tbody' do
    expect(page).to have_selector('tr:first-child td.mapping-hits-column span.text-muted', text: /^[\d.]+%$/)
  end
>>>>>>> Add a basic feature to sort mappings by priority
end
