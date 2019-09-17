source 'https://rubygems.org'

gem 'rails', '5.1.6.2'
gem 'govuk_app_config', '~> 2.0'
gem 'activerecord-session_store'
gem 'pg'
gem 'optic14n' # Ideally version should be synced with bouncer
gem 'govuk_admin_template'
gem 'bootstrap-sass', '3.4.1'
gem 'plek'
gem 'htmlentities'
gem 'kaminari'
gem 'paper_trail', '~> 9.0'
gem 'google-api-client'
gem 'gds-api-adapters', '~> 60.0'
gem 'mlanett-redis-lock'
gem 'whenever'
gem 'gretel'
gem 'acts-as-taggable-on'
gem 'select2-rails', '3.5.7'
gem 'activerecord-import'
gem 'sidekiq', '~> 5.2'
gem 'redis-namespace'
gem 'aws-sdk-s3', '~> 1.48'
gem 'rails_warden', '0.6.0'
gem 'puma', '~> 4.1'
gem 'rollbar', '~> 2.22'

# Custom authentication...
gem 'omniauth', '1.9.0'
gem 'omniauth-zendesk-oauth2', '0.1'

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
  gem 'poltergeist'
  gem 'cuprite'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'launchy' # Primarily for save_and_open_page support in Capybara
  gem 'rails-controller-testing'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'webmock', require: false
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'pry'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'jasmine'
  gem 'govuk-lint', '~> 3.11.5'
end
