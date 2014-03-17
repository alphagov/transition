require 'transition/import/console_job_wrapper'

module Transition
  module Import
    class MappingsFromHostPaths
      extend Transition::Import::ConsoleJobWrapper

      def self.call(site)
        start 'Creating mappings from HostPaths' do
          site_paths = site.host_paths.where('mapping_id is null').group('c14n_path_hash').pluck(:path)
          site_paths.map do |uncanonicalised_path|
            # Try to create them (there may be duplicates in the set and they may
            # already exist).
            if site.mappings.create(path: uncanonicalised_path, http_status: '410')
              $stderr.print '.'
            end
          end
        end
      end
    end
  end
end
