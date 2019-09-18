class PopulateHostPathsCanonicalPath < ActiveRecord::Migration
  include ActionView::Helpers::DateHelper

  def up
    Site.reset_column_information

    record_offset = 0
    batch_size    = 5000
    total_records = HostPath.where(canonical_path: nil).count

    start_time = Time.zone.now

    host_paths = HostPath.all
      .joins(host: :site)
      .includes(host: :site)
      .where(canonical_path: nil)

    warn "Populating canonical paths on #{total_records} records"
    host_paths.find_in_batches(batch_size: batch_size) do |host_paths|
      host_paths.each do |host_path|
        site = host_path.host.site
        host_path.update_column(:canonical_path, site.canonical_path(host_path.path))
      end
      record_offset += batch_size

      elapsed_time = Time.zone.now - start_time

      time_remaining = elapsed_time * (total_records - record_offset) / record_offset
      warn "Updated #{record_offset} / #{total_records} (#{distance_of_time_in_words(time_remaining)} remaining)"
    end
  end

  def down
    # Nothing to do
  end
end
