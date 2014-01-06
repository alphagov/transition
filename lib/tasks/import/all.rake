namespace :import do
  desc 'Import Organisations, Sites, Hosts, Mappings and Hits'
  task :all => [
    'import:all:orgs_sites_hosts',
    'import:all:mappings',
    'import:all:hits',
    'import:dns_details',
    'import:site_transition_status'
  ]

  namespace :all do
    desc 'Import all Organisations, Sites and Hosts'
    task :orgs_sites_hosts do
      patterns = [
        'data/redirector/data/transition-sites/*.yml',
        'data/redirector/data/sites/*.yml',
      ]
      glob = '{' + patterns.join(',') + '}'
      Rake::Task['import:orgs_sites_hosts'].invoke(glob)
    end

    desc 'Import all mappings'
    task :mappings do
      Rake::Task['import:mappings'].invoke('data/redirector/data/mappings/*.csv')
    end

    desc 'Import all hits'
    task :hits do
      Rake::Task['import:hits'].invoke('data/transition-stats/hits/*.tsv')
    end
  end
end
