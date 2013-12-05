require 'transition/google/url_ingester'

def start_date(args)
  args.start_date ? Date.strptime(args.start_date, '%Y-%m-%d') : 6.months.ago
end

##
# Google Analytics rake tasks (ingestion)
namespace :ingest do
  namespace :ga do
    task :to_hits, [:whitehall_slug, :start_date] => :environment do |_, args|
      Transition::Google::UrlIngester.new(args.whitehall_slug, start_date(args)).ingest!
    end

    desc 'List "hits" from Google Analytics for a given org abbr'
    task :list, [:whitehall_slug, :start_date] => :environment do |_, args|
      Transition::Google::UrlIngester.new(args.whitehall_slug, start_date(args)).list
    end
  end

  desc 'Ingest "hits" from Google Analytics for a given org abbr'
  task :ga, [:whitehall_slug, :start_date] => :environment do |_, args|
    Rake::Task['ingest:ga:to_hits'].invoke(args.whitehall_slug, args.start_date)
  end
end
