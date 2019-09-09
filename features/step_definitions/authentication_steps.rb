include Warden::Test::Helpers

Given(/^I have logged in as a GDS Editor$/) do
  user = create(:gds_editor)
  login_as(user)
end

Given(/^I have logged in as an admin$/) do
  user = create(:admin)
  login_as(user)
end

Given(/^I have logged in as a member of DCLG$/) do
  dclg = create(:organisation,
                title:          'Department for Communities and Local Government',
                abbreviation:   'DCLG',
                whitehall_slug: 'department-for-communities-and-local-government')

  user = create(:user, organisation_content_id: dclg.content_id)
  login_as(user)
end

Given(/^I log in as a SIRO$/) do
  user = create(:gds_editor)
  login_as(user)
end

Given(/^I have logged in as a GDS Editor called "([^"]*)"$/) do |name|
  user = create(:gds_editor, name: name)
  login_as(user)
end

Given(/^I have logged in as a member of another organisation$/) do
  user = create(:user, organisation_content_id: SecureRandom.uuid)
  login_as(user)
end
