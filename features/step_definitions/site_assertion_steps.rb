Then(/^I should see a big message that this organisation is (.*)$/) do |status|
  expect(page).to have_selector(".highlight-#{status}", text: status.capitalize)
end

Then(/^I should see a big number "(\d+) days (.*)"$/) do |days, message|
  within '.highlight.date' do
    expect(page).to have_selector('.big-number', text: "#{days} days")
    expect(page).to have_content(message)
  end
end

Then(/^I should see links to the site's analytics$/) do
  within '.performance' do
    expect(page).to have_selector('.list-group-item-heading', text: 'Analytics')
    expect(page).to have_link('a', site_hits_path(@site))
  end
end

Then(/^I should see links to edit and add the site's mappings$/) do
  within '.mappings' do
    expect(page).to have_selector('.list-group-item-heading', text: 'Edit mappings')
    expect(page).to have_link('a', href: site_mappings_path(@site))
    expect(page).to have_selector('.list-group-item-heading', text: 'Add mappings')
    expect(page).to have_link('a', href: new_multiple_site_mappings_path(@site))
  end
end

Then(/^I should see the site's configuration including all host aliases$/) do
  pending
end


Then(/^I should see the date of the site's transition$/) do
  pending
end

