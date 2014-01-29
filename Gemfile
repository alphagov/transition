source 'https://rubygems.org'
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'rails', '3.2.16'
gem 'unicorn', '4.6.2'
gem 'mysql2', '0.3.13'
gem 'jquery-rails', '3.0.4'
gem 'optic14n', '1.0.0'     # Ideally version should be synced with bouncer
gem 'gds-sso', '9.2.0'
gem 'plek', '1.2.0'
gem 'htmlentities', '4.3.1'
gem 'kaminari', '0.14.1'
gem 'paper_trail', '2.7.2'  # Using stable, see https://github.com/airblade/paper_trail/tree/2.7-stable for docs
gem 'google-api-client', '0.6.4'
gem 'gds-api-adapters', '7.14.0'
gem 'mlanett-redis-lock', '0.2.2'
gem 'whenever', '0.8.4'
gem 'gretel', '3.0.5'

# Exception notification is configured in alphagov-deployment. These gems are
# needed by that code.
gem 'aws-ses', '0.4.4', require: 'aws/ses'
gem 'exception_notification', '2.6.1'

gem 'logstasher', '0.4.1'

group :assets do
  gem 'sass', '3.2.8'
  gem 'sass-rails', '3.2.6'
  gem 'bootstrap-sass', '3.0.3.0'
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
  gem 'jasmine', '2.0.0.rc3'
end
