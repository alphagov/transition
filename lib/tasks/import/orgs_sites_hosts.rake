require 'transition/import/orgs_sites_hosts'

namespace :import do
  task :orgs_sites_hosts, [:filename_or_mask] => :environment do |_, args|
    begin
      Transition::Import::OrgsSitesHosts.from_yaml!(args.filename_or_mask, Transition::Import::WhitehallOrgs.new('./data/orgs.json'))
    rescue Transition::Import::Sites::NoYamlFound
      $stderr.puts <<-TEXT
Warning: no sites YAML found at #{args.filename_or_mask}

You may need to run the following before seeding again:

rake notmodules:sync
    TEXT
    end
  end
end
