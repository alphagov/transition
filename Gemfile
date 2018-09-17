source 'https://rubygems.org'

gem 'rails', '5.1.4'
gem 'govuk_app_config', '~> 1.3'
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
gem 'gds-api-adapters'
gem 'mlanett-redis-lock'
gem 'whenever'
gem 'gretel'
gem 'acts-as-taggable-on'
gem 'select2-rails', '3.5.7'
gem 'activerecord-import'
gem 'govuk_sidekiq', '~> 3.0'

gem 'sass'
gem 'sass-rails'
gem 'uglifier'

group :development do
  gem 'web-console'
end

group :test do
  gem 'capybara', require: false
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'govuk_test'
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
  gem 'govuk-lint', '~> 3.8.0'
end
