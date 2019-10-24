##
# Lifted shamelessly from
# http://devblog.avdi.org/2012/08/31/configuring-database_cleaner-with-rails-rspec-capybara-and-selenium/
RSpec.configure do |config|
  DatabaseCleaner.allow_remote_database_url = true

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  ##
  # Use if your specs are using their own transactions and you don't
  # want the implicit wrapped transaction around specs. Not using this
  # can result in the dreaded PG::InFailedTransaction, which may
  # bork a whole load of successive specs
  config.before(:each, truncate_everything: true) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  ##
  # Mark tests where you're going to use before(:all) for speed reasons
  # with the metadata +testing_before_all: true+
  config.before(:all, testing_before_all: true) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after(:all, testing_before_all: true) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
