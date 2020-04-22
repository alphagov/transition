namespace :db do
  namespace :structure do
    # Crazily, when you change to structure.sql-based migration,
    # Rails tries to keep all the auto-increment fields in 'sync'
    # ... by dumping them in your db/structure.sql for EVERY table
    # (e.g. 'ENGINE=MyISAM AUTO_INCREMENT=1851827 DEFAULT CHARSET=utf8 COLLATE=utf8_bin')
    #
    # This augments the existing rails task by removing the resultant noise
    # See also:
    # http://stackoverflow.com/questions/2210719/out-of-sync-auto-increment-values-in-development-structure-sql-from-rails-mysql
    desc "Dump DB schema with auto-increment corrections"
    task dump: :environment do
      path = Rails.root.join("db/structure.sql")
      File.write path, File.read(path).gsub(/ AUTO_INCREMENT=\d*/, "") + "\n"
    end
  end
end
