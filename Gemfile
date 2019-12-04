source 'https://rubygems.org'

gem 'activerecord-import'
gem 'activerecord-session_store'
gem 'acts-as-taggable-on'
gem 'apache_log-parser'
gem 'aws-sdk-s3', '~> 1.48'
gem 'bootstrap-sass', '3.4.1'
gem 'gds-api-adapters', '~> 60.0'
gem 'google-api-client'
gem 'govuk_admin_template'
gem 'govuk_app_config', '~> 2.0'
gem 'gretel'
gem 'htmlentities'
gem 'kaminari'
gem 'mlanett-redis-lock'
gem 'optic14n' # Ideally version should be synced with bouncer
gem 'paper_trail', '~> 9.0'
gem 'pg'
gem 'plek'
gem 'puma', '~> 4.3'
gem 'rails', '5.1.6.2'
gem 'rails_warden', '0.6.0'
gem 'redis-namespace'
gem 'rollbar', '~> 2.22'
gem 'ruby-ip'
gem 'select2-rails', '3.5.7'
gem 'sidekiq', '~> 6.0'
gem 'sidekiq-cron', '~> 1.1'
gem 'whenever'

# Custom authentication...
gem 'omniauth', '1.9.0'
gem 'omniauth-auth0', '~> 2.2'
gem 'omniauth-rails_csrf_protection', '~> 0.1'

gem 'sass'
gem 'sass-rails'
gem 'uglifier'

group :development do
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'cucumber-rails', require: false
  gem 'cuprite'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'launchy' # Primarily for save_and_open_page support in Capybara
  gem 'poltergeist'
  gem 'rails-controller-testing'
  gem 'rspec-sidekiq'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'webdrivers'
  gem 'webmock', require: false
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'govuk-lint', '~> 3.11.5'
  gem 'jasmine'
  gem 'pry'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
end
