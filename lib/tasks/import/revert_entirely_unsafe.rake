namespace :import do
  desc "Deletes a site and all associated data"
  task :revert_entirely_unsafe, [:site_abbr] => :environment do |_, args|
    if args[:site_abbr].nil?
      puts "Usage: rake import:revert_entirely_unsafe[site_abbr]"
      abort
    end

    site = Site.find_by(abbr: args[:site_abbr])
    raise "No site found for #{args[:site_abbr]}" unless site

    STDOUT.flush
    STDOUT.puts "WAIT! This will delete all data that is associated with this site. \nAre you sure? (y/N)"
    input = STDIN.gets.chomp

    unless %w[y yes].include?(input)
      abort("Aborting deletion of site: #{args[:site_abbr]}.")
    end

    Transition::Import::RevertEntirelyUnsafe::RevertSite.new(site).revert_all_data!
  end
end
