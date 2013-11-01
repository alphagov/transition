When(/^I click on the link to check the mapping for the top hit/) do
  click_link '', href: site_mapping_find_path(@site, path: '/A')
end

When(/^I filter by the date period "([^"]*)"$/) do |period_title|
  within '.date-range' do
    page.find('.btn.dropdown-toggle').click
    click_link(period_title)
  end
end
