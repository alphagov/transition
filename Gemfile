source 'https://rubygems.org'

gem 'rails', '4.1.11'
gem 'activerecord-session_store', '0.1.0'
gem 'unicorn', '4.6.2'
gem 'pg', '0.17.1'
gem 'optic14n', '2.0.0'     # Ideally version should be synced with bouncer
gem 'gds-sso', '11.0.0'
gem 'govuk_admin_template', '2.3.1'
gem 'plek', '1.8.1'
gem 'htmlentities', '4.3.2'
gem 'kaminari', '0.16.1'
gem 'paper_trail', '3.0.2'
gem 'google-api-client', '0.7.1'
gem 'gds-api-adapters', '7.14.0'
gem 'mlanett-redis-lock', '0.2.6'
gem 'whenever', '0.9.2'
gem 'gretel', '3.0.7'
gem 'acts-as-taggable-on', '3.1.1'
gem 'select2-rails', '3.5.7'
gem 'activerecord-import', '0.5.0'
gem 'sidekiq', '3.1.4'

# We use Errbit for tracking exceptions, which needs the airbrake gem. Config
# for Errbit is in alphagov-deployment.
gem 'airbrake', '4.0.0'

gem 'logstasher', '0.5.3'

gem 'sass', '3.4.14'
gem 'sass-rails', '5.0.3'
gem 'uglifier', '2.5.1'

group :development do
  gem 'quiet_assets', '1.0.2'
end

group :test do
  gem 'poltergeist', '1.5.1'
  gem 'launchy', '2.3.0'                  # Primarily for save_and_open_page support in Capybara
  gem 'timecop', '0.5.9.2'
  gem 'cucumber-rails', require: false
  gem 'capybara', '2.3.0', require: false
  gem 'factory_girl_rails', '4.1.0'
  gem 'shoulda-matchers', '2.6.2'
  gem 'ci_reporter', '1.8.0'
  gem 'database_cleaner', '1.0.1'
  gem 'webmock', '1.11.0', require: false
end

group :development, :test do
  gem 'rspec-rails', '2.14.2'
  gem 'rspec-expectations', '2.14.2'
  gem 'rspec-mocks', '2.14.2'
  gem 'jasmine', '2.0.2'
end
