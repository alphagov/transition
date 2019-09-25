require "transition/distributed_lock"
require "transition/import/whitehall/mappings"

namespace :import do
  namespace :whitehall do
    desc "Import mappings from Whitehall. Set FILENAME to avoid downloading the huge file."
    task mappings: :environment do
      options = if ENV["FILENAME"]
                  { filename: ENV["FILENAME"] }
                else
                  {
                    username: ENV["BASIC_AUTH_USERNAME"] || raise("Basic AUTH_USERNAME is required"),
                    password: ENV["BASIC_AUTH_PASSWORD"] || raise("Basic AUTH_PASSWORD is required"),
                  }
                end
      Transition::DistributedLock.new("import_whitehall_mappings").lock do
        Transition::Import::Whitehall::Mappings.new(options).call
      end
    end
  end
end
