require 'transition/import/create_mappings_from_host_paths'

namespace :import do
  desc 'Create mappings from HostPaths for a site'
  task :create_mappings_from_host_paths, [:site_abbr] => :environment do |_, args|
    site = Site.find_by_abbr(args[:site_abbr])
    raise "No site found for #{args[:site_abbr]}" unless site
    Transition::Import::CreateMappingsFromHostPaths.call(site)
  end
end
