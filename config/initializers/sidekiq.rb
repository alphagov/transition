redis_url = ENV.fetch('REDIS_URL', 'redis://dev:6379')
redis_url = "#{redis_url}/0"

options = {
  concurrency: Integer(ENV.fetch('RAILS_MAX_THREADS') { 5 })
}

Sidekiq.configure_server do |config|
  config.options.merge!(options)
  config.redis = {
    url: redis_url,
    size: config.options[:concurrency] + 5
  }
end

Sidekiq.configure_client do |config|
  config.options.merge!(options)
  config.redis = {
    url: redis_url,
    size: config.options[:concurrency] + 5
  }
end

Sidekiq::Logging.logger.level = Logger::WARN if Rails.env.production?
