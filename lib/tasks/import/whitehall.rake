require 'transition/distributed_lock'
require 'transition/import/whitehall/mappings'

namespace :import do
  namespace :whitehall do
    desc "Import mappings from Whitehall. Set FILENAME to avoid downloading the huge file."
    task :mappings => :environment do
      if ENV['FILENAME']
        options = { filename: ENV['FILENAME'] }
      else
        govuk_basic_auth = Transition::Application.config.govuk_basic_auth
        options = {
          username: govuk_basic_auth[:username] || ENV['AUTH_USERNAME'] || raise('Basic AUTH_USERNAME is required'),
          password: govuk_basic_auth[:password] || ENV['AUTH_PASSWORD'] || raise('Basic AUTH_PASSWORD is required'),
        }
      end
      Transition::DistributedLock.new('import_whitehall_mappings').lock do
        Transition::Import::Whitehall::Mappings.new(options).call
      end
    end
  end
end
