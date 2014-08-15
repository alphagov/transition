redis_config = YAML.load_file(File.join(Rails.root, "config", "redis.yml"))

redis_config_for_sidekiq = {
  :url => "redis://#{redis_config['host']}:#{redis_config['port']}/0",
  :namespace => redis_config['namespace'],
}

Sidekiq.configure_server do |config|
  config.redis = redis_config_for_sidekiq
end

Sidekiq.configure_client do |config|
  config.redis = redis_config_for_sidekiq
end
