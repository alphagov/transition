desc "Clear the mappings batches (and entries) that are over 48 hours old."
task clear_old_mappings_batches: :environment do
  MappingsBatch.where(["updated_at < ?", 48.hours.ago]).destroy_all
end
