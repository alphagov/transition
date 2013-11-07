Given(/^I have logged in as a GDS user$/) do
  GDS::SSO.test_user = create(:user)
end

Given(/^I have logged in as a member of DCLG$/) do
  dclg = FactoryGirl.create(:organisation,
                             title: 'Department for Communities and Local Government',
                             abbreviation: 'DCLG',
                             redirector_abbr: 'dclg',
                             whitehall_slug: 'department-for-communities-and-local-government')
  GDS::SSO.test_user = create(:user, organisation_slug: dclg.whitehall_slug)
end

Given(/^I log in as a SIRO$/) do
  GDS::SSO.test_user = create(:user)
end

Given(/^I have logged in as a GDS user called "([^"]*)"$/) do |name|
  GDS::SSO.test_user = create(:user, name: name)
end
