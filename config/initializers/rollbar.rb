if Rails.env.production?
  Rollbar.configure do |config|
    config.access_token = ENV.fetch('ROLLBAR_ACCESS_TOKEN', nil)
    # If you run your staging application instance in production environment then
    # you'll want to override the environment reported by `Rails.env` with an
    # environment variable like this: `ROLLBAR_ENV=staging`. This is a recommended
    # setup for Heroku. See:
    # https://devcenter.heroku.com/articles/deploying-to-a-custom-rails-environment
    config.environment = ENV['ROLLBAR_ENV'].presence || Rails.env
  end
end
