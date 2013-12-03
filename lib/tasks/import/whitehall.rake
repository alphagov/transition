namespace :import do
  namespace :whitehall do
    desc "Import mappings from Whitehall. You must set either: FILENAME or AUTH_USERNAME and AUTH_PASSWORD"
    task :mappings => :environment do
      require 'transition/import/whitehall/mappings'

      if ENV['FILENAME']
        options = { filename: ENV['FILENAME'] }
      else
        options = {
          username: ENV['AUTH_USERNAME'] || raise('Basic AUTH_USERNAME is required'),
          password: ENV['AUTH_PASSWORD'] || raise('Basic AUTH_PASSWORD is required'),
        }
      end
      Transition::Import::Whitehall::Mappings.new(options).call
    end
  end
end
