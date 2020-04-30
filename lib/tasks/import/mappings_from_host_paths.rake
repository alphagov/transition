require "transition/import/mappings_from_host_paths"

namespace :import do
  desc "Create mappings from HostPaths for a site"
  task :mappings_from_host_paths, [:site_abbr] => :environment do |_, args|
    site = Site.find_by(abbr: args[:site_abbr])
    raise "No site found for #{args[:site_abbr]}" unless site

    if site.global_type
      STDOUT.flush
      STDOUT.puts "WARNING: This site has a global_type, so Bouncer will not use any mappings you create.\nDo you want to continue? (y/N)"
      input = STDIN.gets.chomp
      unless %w[y yes].include?(input)
        abort("Not creating mappings for site #{args[:site_abbr]} with global_type.")
      end
    end

    Transition::Import::MappingsFromHostPaths.refresh!(site)
  end
end
