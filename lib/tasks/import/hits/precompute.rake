require "transition/import/hits/precompute"

namespace :import do
  namespace :hits do
    namespace :precompute do
      desc "Set flag to start computing all hits/all-time view for a list of given site abbrs"
      task enable: :environment do |_, args|
        Transition::Import::Hits::Precompute.new(args.extras, true).update!
      end

      desc "Set flag to stop computing all hits/all-time view for a list of given site abbrs"
      task disable: :environment do |_, args|
        Transition::Import::Hits::Precompute.new(args.extras, false).update!
      end
    end
  end
end
