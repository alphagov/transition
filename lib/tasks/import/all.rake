namespace :import do
  desc 'Import Organisations, Sites, Hosts, Mappings and Hits'
  task :all => ['import:all:orgs_sites_hosts', 'import:all:mappings', 'import:all:hits']

  namespace :all do
    desc 'Import all Organisations, Sites and Hosts'
    task :orgs_sites_hosts do
      Rake::Task['import:orgs_sites_hosts'].invoke('data/redirector/data/sites/*.yml')
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
