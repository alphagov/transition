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

  ##
  # For tests that are using MySQL DDE, i.e. anything with an
  # import/ingest using LOAD DATA LOCAL INFILE
  # *OR* any test using a myISAM table for which you need
  # the table to be in a known state per-test I.E. HITS
  config.before(:each, :truncate_everything => true) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  ##
  # Mark tests where you're going to use before(:all) for speed reasons
  # with the metadata +testing_before_all: true+
  config.before(:all, :testing_before_all => true) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after(:all, :testing_before_all => true) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end
