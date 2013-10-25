When(/^I click on the link to check the mapping for the top hit/) do
  click_link '', href: site_mapping_find_path(@site, path: '/A')
end

When /^I wait until a graph is visible$/ do
  find('.js-hits-graph svg')
end
