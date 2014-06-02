Given(/^I have logged in as a GDS Editor$/) do
  GDS::SSO.test_user = create(:gds_editor)
end

Given(/^I have logged in as a member of DCLG$/) do
  dclg = create(:organisation,
                title:          'Department for Communities and Local Government',
                abbreviation:   'DCLG',
                whitehall_slug: 'department-for-communities-and-local-government')

  GDS::SSO.test_user = create(:user, organisation_slug: dclg.whitehall_slug)
end

Given(/^I log in as a SIRO$/) do
  GDS::SSO.test_user = create(:gds_editor)
end

Given(/^I have logged in as a GDS Editor called "([^"]*)"$/) do |name|
  GDS::SSO.test_user = create(:gds_editor, name: name)
end

Given(/^I have logged in as a member of another organisation$/) do
  GDS::SSO.test_user = create(:user, organisation_slug: 'slug-for-another-org')
end
