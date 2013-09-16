source 'https://rubygems.org'
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'rails', '3.2.13'
gem 'unicorn', '4.6.2'
gem 'mysql2', '0.3.11'
gem 'jquery-rails', '2.0.2' # TODO: Newer versions break publisher sortable parts. Will need attention.
gem 'optic14n', '1.0.0'     # Ideally version should be synced with bouncer
gem 'gds-sso', '3.0.0'
gem 'plek', '1.2.0'
gem 'htmlentities'
gem 'kaminari'

# Exception notification is configured in alphagov-deployment. These gems are
# needed by that code.
gem 'aws-ses', '0.4.4', require: 'aws/ses'
gem 'exception_notification', '2.6.1'

group :assets do
  gem 'sass', '3.2.8'
  gem 'sass-rails', '3.2.6'
  gem "bootstrap-sass", "2.3.2.1"
  gem 'uglifier', '2.0.1'
end

group :test do
  gem 'launchy'                             # Primarily for save_and_open_page support in Capybara
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
end
