def glob_from_array(array)
  "{" + array.join(",") + "}"
end

namespace :import do
  desc "Import Organisations, Sites, Hosts, Hits and update DNS details"
  task :all,
       [:bucket] => [
         "import:all:orgs_sites_hosts",
         "import:all:hits",
         "import:dns_details",
       ]

  namespace :all do
    desc "Import all Organisations, Sites and Hosts"
    task orgs_sites_hosts: :environment do
      patterns = [
        "data/transition-config/data/transition-sites/*.yml",
      ]
      Rake::Task["import:orgs_sites_hosts"].invoke(glob_from_array(patterns))
    end

    desc "Import all hits from s3"
    task :hits, [:bucket] => :environment do |_, args|
      Transition::Import::Hits.from_s3!(args[:bucket])
      Transition::Import::DailyHitTotals.from_hits!
      Transition::Import::HitsMappingsRelations.refresh!
    end
  end
end
