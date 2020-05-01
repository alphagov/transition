require "transition/import/orgs_sites_hosts"

namespace :import do
  desc "Import all Organisations, and Sites and Hosts from the given filename or mask"
  task :orgs_sites_hosts, [:filename_or_mask] => :environment do |_, args|
    Transition::Import::OrgsSitesHosts.from_yaml!(args.filename_or_mask)
  rescue Transition::Import::Sites::NoYamlFound
    warn <<~TEXT
      Warning: no sites YAML found at #{args.filename_or_mask}

      You may need to run the following before seeding again:

      rake notmodules:sync
    TEXT
  end
end
