begin
  require "database_cleaner"
  require "database_cleaner/cucumber"

  DatabaseCleaner.allow_remote_database_url = true
  DatabaseCleaner.strategy = :truncation
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end
