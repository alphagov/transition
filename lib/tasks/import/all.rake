namespace :import do
  desc 'Import hits and mappings'
  task :all => ['import:all:mappings', 'import:all:hits']

  namespace :all do
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
