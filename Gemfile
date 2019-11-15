source "https://rubygems.org"

gem "activerecord-import"
gem "activerecord-session_store"
gem "acts-as-taggable-on"
gem "aws-sdk-s3", "~> 1.54"
gem "gds-api-adapters", "~> 61.0"
gem "gds-sso"
gem "google-api-client"
gem "govuk_admin_template"
gem "govuk_app_config", "~> 2.0"
gem "govuk_sidekiq", "~> 3.0"
gem "gretel"
gem "htmlentities"
gem "kaminari"
gem "mlanett-redis-lock"
gem "optic14n" # Ideally version should be synced with bouncer
gem "paper_trail", "10.3.1"
gem "pg"
gem "plek"
gem "rails", "5.2.3"
gem "select2-rails", "3.5.7"
gem "whenever"

gem "sass"
gem "sass-rails"
gem "sprockets", "~> 3"
gem "uglifier"

group :development do
  gem "web-console"
end

group :test do
  gem "cucumber-rails", require: false
  gem "database_cleaner"
  gem "factory_bot_rails"
  gem "govuk_test", "~> 1.0.3"
  gem "launchy" # Primarily for save_and_open_page support in Capybara
  gem "rails-controller-testing"
  gem "shoulda-matchers"
  gem "timecop"
  gem "webmock", require: false
end

group :development, :test do
  gem "jasmine"
  gem "pry"
  gem "rspec-collection_matchers"
  gem "rspec-rails"
  gem "rubocop-govuk"
end
