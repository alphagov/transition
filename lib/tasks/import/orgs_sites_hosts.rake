namespace :import do
  task :orgs_sites_hosts, [:filename_or_mask] => :environment do
    begin
      Transition::Import::OrgsSitesHosts.from_redirector_yaml!(filename_or_mask)
    rescue Transition::Import::OrgsSitesHosts::NoYamlFound
      $stderr.puts <<-TEXT
Warning: no sites YAML found at #{filename_or_mask}

You may need to run the following before seeding again:

mkdir -p data && git clone git@github.com:alphagov/redirector data/redirector
    TEXT
    end

  end
end
