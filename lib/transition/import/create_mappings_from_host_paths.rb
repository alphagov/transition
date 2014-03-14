module Transition
  module Import
    class CreateMappingsFromHostPaths
      def self.call(site)
        site_paths = site.host_paths.where('mapping_id is null').group('c14n_path_hash').pluck(:path)
        site_paths.map do |uncanonicalised_path|
          # Try to create them (there may be duplicates in the set and they may
          # already exist).
          site.mappings.create(path: uncanonicalised_path, http_status: '410')
        end
      end
    end
  end
end
