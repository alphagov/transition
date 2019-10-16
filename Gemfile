source "https://rubygems.org"

gem "activerecord-import"
gem "activerecord-session_store"
gem "acts-as-taggable-on"
gem "aws-sdk-s3", "~> 1.49"
gem "gds-api-adapters", "~> 60.1"
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
gem "paper_trail", "4.1.0"
gem "pg"
gem "plek"
gem "rails", "5.1.6.2"
gem "select2-rails", "3.5.7"
gem "whenever"

gem "sass"
gem "sass-rails"
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
  gem "govuk-lint", "~> 4.0.1"
  gem "jasmine"
  gem "pry"
  gem "rspec-collection_matchers"
  gem "rspec-rails"
end
