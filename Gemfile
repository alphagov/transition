source 'https://rubygems.org'

gem 'rails', '5.1.6.2'
gem 'govuk_app_config', '~> 1.19'
gem 'activerecord-session_store'
gem 'pg'
gem 'optic14n' # Ideally version should be synced with bouncer
gem 'gds-sso'
gem 'govuk_admin_template'
gem 'plek'
gem 'htmlentities'
gem 'kaminari'
gem 'paper_trail', '4.1.0'
gem 'google-api-client'
gem 'gds-api-adapters', '~> 59.5'
gem 'mlanett-redis-lock'
gem 'whenever'
gem 'gretel'
gem 'acts-as-taggable-on'
gem 'select2-rails', '3.5.7'
gem 'activerecord-import'
gem 'govuk_sidekiq', '~> 3.0'
gem 'aws-sdk-s3', '~> 1.43'

gem 'sass'
gem 'sass-rails'
gem 'uglifier'

group :development do
  gem 'web-console'
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'govuk_test', '~> 0.5.0'
  gem 'launchy' # Primarily for save_and_open_page support in Capybara
  gem 'rails-controller-testing'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'webmock', require: false
end

group :development, :test do
  gem 'pry'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'jasmine'
  gem 'govuk-lint', '~> 3.11.2'
end
