desc "Clear the sessions table of records that are over 25 hours old."
task :clear_expired_sessions => :environment do
  puts "Deleting sessions over 25 hours old..."
  ActiveRecord::SessionStore::Session.delete_all(["updated_at < ?", 25.hours.ago])
end
