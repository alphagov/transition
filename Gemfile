source 'https://rubygems.org'

gem 'rails', '3.2.18'
gem 'unicorn', '4.6.2'
gem 'mysql2', '0.3.13'
gem 'optic14n', '2.0.0'     # Ideally version should be synced with bouncer
gem 'gds-sso', '9.3.0'
gem 'govuk_admin_template', '1.0.1'
gem 'plek', '1.2.0'
gem 'htmlentities', '4.3.1'
gem 'kaminari', '0.14.1'
gem 'paper_trail', '3.0.2'
gem 'google-api-client', '0.7.1'
gem 'gds-api-adapters', '7.14.0'
gem 'mlanett-redis-lock', '0.2.6'
gem 'whenever', '0.8.4'
gem 'gretel', '3.0.5'
gem 'acts-as-taggable-on', '3.1.1'
gem 'select2-rails', '3.5.2'
gem 'activerecord-import', '0.5.0'
gem 'sidekiq', '3.0.0'

# We use Errbit for tracking exceptions, which needs the airbrake gem. Config
# for Errbit is in alphagov-deployment.
gem 'airbrake', '3.1.15'

gem 'logstasher', '0.4.8'

group :assets do
  gem 'sass', '3.2.12'
  gem 'sass-rails', '3.2.6'
  gem 'uglifier', '2.0.1'
end

group :development do
  gem 'quiet_assets', '1.0.2'
end

group :test do
  gem 'poltergeist', '1.4.1'
  gem 'launchy', '2.3.0'                  # Primarily for save_and_open_page support in Capybara
  gem 'timecop', '0.5.9.2'
  gem 'cucumber-rails', require: false
  gem 'capybara', '2.1.0', require: false
  gem 'factory_girl_rails', '4.1.0'
  gem 'shoulda-matchers', '2.2.0'
  gem 'ci_reporter', '1.8.0'
  gem 'database_cleaner', '1.0.1'
  gem 'webmock', '1.11.0', require: false
end

group :development, :test do
  gem 'rspec-rails', '2.13.2'
  gem 'jasmine', '2.0.2'
end
