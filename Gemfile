source "https://rubygems.org"

gem "rails", "7.1.2"

gem "activerecord-import"
gem "activerecord-session_store"
gem "acts-as-taggable-on"
gem "aws-sdk-s3"
gem "bootsnap", require: false
gem "gds-api-adapters"
gem "gds-sso"
gem "google-api-client"
gem "govuk_admin_template"
gem "govuk_app_config"
gem "govuk_publishing_components"
gem "govuk_sidekiq"
gem "gretel"
gem "htmlentities"
gem "kaminari"
gem "mlanett-redis-lock"
gem "optic14n" # Ideally version should be synced with bouncer
gem "paper_trail"
gem "pg"
gem "plek"
gem "select2-rails", "~> 3.5.11" # Version 4 changes CSS classes considerably
gem "sentry-sidekiq"
gem "whenever"

gem "sass"
gem "sass-rails"
gem "sprockets"
gem "uglifier"

group :development do
  gem "web-console"
end

group :test do
  gem "capybara-select-2"
  gem "cucumber-rails", require: false
  gem "database_cleaner"
  gem "factory_bot_rails"
  gem "rails-controller-testing"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "timecop"
  gem "webmock", require: false
end

group :development, :test do
  gem "govuk_test"
  gem "pry"
  gem "rspec-collection_matchers"
  gem "rspec-rails"
  gem "rubocop-govuk"
end
