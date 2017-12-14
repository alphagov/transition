source 'https://rubygems.org'

gem 'rails', '5.1.1'
gem 'govuk_app_config', '~> 0.2'
gem 'activerecord-session_store'
gem 'unicorn'
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
gem 'govuk_sidekiq', '~> 2.0'

gem 'logstasher', '1.2.2'

gem 'sass'
gem 'sass-rails'
gem 'uglifier'

group :development do
  gem 'web-console'
end

group :test do
  gem 'poltergeist'
  gem 'phantomjs'
  gem 'launchy' # Primarily for save_and_open_page support in Capybara
  gem 'timecop'
  gem 'cucumber-rails', require: false
  gem 'capybara', require: false
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'database_cleaner'
  gem 'webmock', require: false
  gem 'rails-controller-testing'
end

group :development, :test do
  gem 'pry'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'jasmine'
  gem 'govuk-lint', '~> 1.2.1'
end
