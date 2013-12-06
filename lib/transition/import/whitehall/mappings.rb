require 'redis'
require 'redis-lock'
require 'open-uri'
require 'transition/import/whitehall/mappings_csv'

module Transition
  module Import
    module Whitehall
      class Mappings
        WHITEHALL_URL = 'https://whitehall-admin.production.alphagov.co.uk/government/all_document_attachment_and_non_document_mappings.csv'
        AS_USER_EMAIL = 'whitehall-urls-robot@dummy.com'

        def initialize(options = {})
          @filename = options[:filename]
          @username = options[:username]
          @password = options[:password]
        end

        def call
          redis.lock("transition:#{Rails.env}:import_whitehall_mappings", life: (5 * 60)) do
            Rails.logger.debug('Successfully got a lock. Running...')
            if @filename
              filename = @filename
            else
              filename = download
            end
            process(filename)
          end
        rescue Redis::Lock::LockNotAcquired => e
          Rails.logger.debug("Failed to get lock for Whitehall Document URLs import (#{e.message}). Another process probably got there first.")
        rescue StandardError => e
          ExceptionNotifier.notify_exception(e)
          raise
        end

      private

        def redis
          @_redis ||= begin
            redis_config = YAML.load_file(File.join(Rails.root, "config", "redis.yml"))
            Redis.new(redis_config.symbolize_keys)
          end
        end

        def as_user
          User.first_or_create!(email: AS_USER_EMAIL) do |user|
            user.name  = 'Whitehall URL Robot'
            user.is_robot = true
          end
        end

        def default_filename
          "tmp/#{Time.now.to_i}-all_document_attachment_and_non_document_mappings.csv"
        end

        def download(filename = default_filename)
          Rails.logger.info("Downloading 50+ MB CSV to #{filename}")
          # Have to force the encoding because it isn't set on the response, so
          # Ruby defaults to BINARY
          urls_io = open(WHITEHALL_URL, 'r:utf-8', http_basic_authentication: [@username, @password])
          open(filename, 'w') do |file|
            file.write(urls_io.read)
          end
          filename
        end

        def process(filename)
          Rails.logger.info('Processing...')

          File.open(filename, 'r') { |file|
            Transition::Import::Whitehall::MappingsCSV.new(as_user).from_csv(file)
          }
        end
      end
    end
  end
end
