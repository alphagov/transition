require 'transition/import/mappings'

namespace :import do
  desc 'Import redirector mappings for a file or mask'
  task :mappings, [:filename_or_mask] => :environment do |_, args|
    filename_or_mask = args[:filename_or_mask]
    Transition::Import::Mappings.from_redirector_mask!(filename_or_mask)
  end
end
