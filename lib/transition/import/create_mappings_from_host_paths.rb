module Transition
  module Import
    class CreateMappingsFromHostPaths
      def self.call(site)
        site.hosts.each do |host|
          host.host_paths.where('mapping_id is null').each do |host_path|
            site.mappings.create(path: host_path.path, http_status: '410')
          end
        end
      end
    end
  end
end
