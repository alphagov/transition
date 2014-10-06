def glob_from_array(array)
  '{' + array.join(',') + '}'
end

namespace :import do
  desc 'Import Organisations, Sites, Hosts, Hits and update DNS details'
  task :all => [
    'import:all:orgs_sites_hosts',
    'import:all:hits',
    'import:dns_details'
  ]

  namespace :all do
    desc 'Import all Organisations, Sites and Hosts'
    task :orgs_sites_hosts do
      patterns = [
        'data/redirector/data/transition-sites/*.yml',
      ]
      Rake::Task['import:orgs_sites_hosts'].invoke(glob_from_array(patterns))
    end

    desc 'Import all hits'
    task :hits do
      patterns = [
        'data/transition-stats/hits/*.tsv',
        'data/pre-transition-stats/hits/*.tsv',
      ]
      Rake::Task['import:hits'].invoke(glob_from_array(patterns))
    end
  end
end
