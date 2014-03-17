require 'transition/import/mappings_from_host_paths'

namespace :import do
  desc 'Create mappings from HostPaths for a site'
  task :mappings_from_host_paths, [:site_abbr] => :environment do |_, args|
    site = Site.find_by_abbr(args[:site_abbr])
    raise "No site found for #{args[:site_abbr]}" unless site
    raise 'ABORT: This site is not managed by transition' unless site.managed_by_transition?

    if site.global_http_status
      STDOUT.flush
      STDOUT.puts "WARNING: This site has a global_http_status, so Bouncer will not use any mappings you create.\nDo you want to continue? (y/N)"
      input = STDIN.gets.chomp
      unless %w(y yes).include?(input)
        abort("Not creating mappings for site #{args[:site_abbr]} with global_http_status.")
      end
    end

    Transition::Import::MappingsFromHostPaths.refresh!(site)
  end
end
