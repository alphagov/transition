desc 'Update the New URL whitelist in the database from the file'
task :update_new_url_whitelist => :environment do
  lines = File.open('config/new_url_whitelist.txt').map(&:chomp)
  hostnames = lines.reject { |line| line.start_with?('#') || line.empty? }
  hostnames.uniq!
  ActiveRecord::Base.transaction do
    NewURLWhitelistEntry.delete_all
    hostnames.each do |hostname|
      NewURLWhitelistEntry.create!(hostname: hostname)
    end
  end
end
