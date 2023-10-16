namespace :import do
  desc "Import Organisations and Hits and update DNS details"
  task :all,
       [:bucket] => [
         "import:all:organisations",
         "import:all:hits",
         "import:dns_details",
       ]

  namespace :all do
    desc "Import all Organisations"
    task organisations: :environment do
      Rake::Task["import:organisations"].invoke
    end

    desc "Import all hits from s3"
    task :hits, [:bucket] => :environment do |_, args|
      Transition::Import::Hits.from_s3!(args[:bucket])
      Transition::Import::DailyHitTotals.from_hits!
      Transition::Import::HitsMappingsRelations.refresh!
    end
  end
end
