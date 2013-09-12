##
# Lifted shamelessly from
# http://devblog.avdi.org/2012/08/31/configuring-database_cleaner-with-rails-rspec-capybara-and-selenium/
RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  ##
  # Mark tests where you're going to use before(:all) for speed reasons
  # with the metadata +expensive_setup: true+
  config.before(:all, :expensive_setup => true) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after(:all, :expensive_setup => true) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end