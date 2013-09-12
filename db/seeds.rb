# Create test user
#
unless User.find_by_email("test@example.com")
  u             = User.new
  u.email       = "test@example.com"
  u.name        = "Test User"
  u.permissions = ["signin"]
  u.save
end

require 'transition/import/orgs_sites_hosts'

SITES_YAML_MASK = 'data/redirector/data/sites/*.yml'

begin
  Transition::Import::OrgsSitesHosts.from_redirector_yaml!(SITES_YAML_MASK)
rescue Transition::Import::OrgsSitesHosts::NoYamlFound
  $stderr.puts <<-TEXT
Warning: no sites YAML found at #{SITES_YAML_MASK}

You may need to run the following before seeding again:

  mkdir -p data && git clone git@github.com:alphagov/redirector data/redirector
TEXT
end
