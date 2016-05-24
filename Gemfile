source 'https://rubygems.org'

gem 'rails', '4.2.6'
gem 'activerecord-session_store', '0.1.2'
gem 'unicorn', '4.6.2'
gem 'pg', '0.18.4'
gem 'optic14n', '2.0.0'     # Ideally version should be synced with bouncer
gem 'plek', '1.12.0'
gem 'htmlentities', '4.3.4'
gem 'kaminari', '0.16.3'
gem 'paper_trail', '4.1.0'
gem 'google-api-client', '0.8.6'
gem 'mlanett-redis-lock', '0.2.7'
gem 'whenever', '0.9.4'
gem 'gretel', '3.0.8'
gem 'acts-as-taggable-on', '3.5.0'
gem 'select2-rails', '3.5.7'
gem 'activerecord-import', '0.12.0'
gem 'sidekiq', '4.1.1'
gem 'redis-namespace', '1.5.2'
gem 'rails_warden', '0.5.8'

# Remove GDS specific stuff...
# gem 'govuk_admin_template', '4.2.0'
# gem 'gds-api-adapters', '29.6.0'
gem 'bootstrap-sass', '3.3.5.1'

# Custom authentication...
gem 'omniauth', '1.3.1'
gem 'omniauth-zendesk-oauth2', '0.1'

# We use Errbit for tracking exceptions, which needs the airbrake gem. Config
# for Errbit is in alphagov-deployment.
gem 'airbrake', '~> 4.3.0'

gem 'logstasher', '0.6.5'

gem 'sass', '3.4.14'
gem 'sass-rails', '5.0.4'
gem 'uglifier', '2.7.2'

group :development do
  gem 'quiet_assets', '1.1.0'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'poltergeist', '1.5.1'
  gem 'launchy', '2.4.3'                  # Primarily for save_and_open_page support in Capybara
  gem 'timecop', '0.8.0'
  gem 'cucumber-rails', require: false
  gem 'capybara', '2.6.2', require: false
  gem 'factory_girl_rails', '4.6.0'
  gem 'shoulda-matchers', '3.1.1'
  gem 'database_cleaner', '1.5.1'
  gem 'webmock', '1.24.2', require: false
end

group :development, :test do
  gem 'pry'
  gem 'rspec-rails', '3.4.2'
  gem 'rspec-collection_matchers', '1.1.2'
  gem 'jasmine', '2.4.0'
end
