Then(/^I should see links to all this organisation's sites and homepages$/) do
  @organisation.sites.each do |site|
    expect(page).to have_link('', href: site_mappings_path(site.abbr))
    expect(page).to have_link('', href: site.homepage)
  end
end

Then(/^I should see that this organisation is an executive non-departmental public body of its parent$/) do
  expect(page).to have_content('is an executive non-departmental public body of')
  expect(page).to have_link('', href: organisation_path(@organisation.parent_organisations.first))
end

Then(/^I should see a link to the organisation (.*)$/) do |org_abbr|
  expect(page).to have_link('', href: organisation_path(org_abbr))
end

Then(/^I should not see a link to the organisation (.*)$/) do |org_abbr|
  expect(page).not_to have_link('', href: organisation_path(org_abbr))
end

Then(/^I should see all the old homepages for the sites of the given organisation$/) do
  @organisation.sites.each do |site|
    expect(page).to have_content(site.default_host.hostname)
  end
end
