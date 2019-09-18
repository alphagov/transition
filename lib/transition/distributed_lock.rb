require 'redis'
require 'redis-lock'
module Transition
  class DistributedLock
    LIFETIME = (5 * 60) # seconds

    def initialize(lock_name)
      @lock_name = lock_name
    end

    def lock
      redis.lock("transition:#{Rails.env}:#{@lock_name}", life: LIFETIME) do
        Rails.logger.debug('Successfully got a lock. Running...')
        yield
      end
    rescue Redis::Lock::LockNotAcquired => e
      Rails.logger.debug("Failed to get lock for #{@lock_name} (#{e.message}). Another process probably got there first.")
    end
  end

private

  def redis
    @_redis ||= begin
      redis_config = YAML.load_file(File.join(Rails.root, "config", "redis.yml"))
      Redis.new(redis_config.symbolize_keys)
    end
  end
end
