class PopulateHostPathsCanonicalPath < ActiveRecord::Migration
  def up
    record_offset = 0
    batch_size    = 5000
    total_records = HostPath.where(canonical_path: nil).count

    host_paths = HostPath.all
      .joins(:host => :site)
      .includes(:host => :site)
      .where(canonical_path: nil)

    host_paths.find_in_batches(batch_size: batch_size) do |host_paths|
      host_paths.each do |host_path|
        site = host_path.host.site
        host_path.update_column(:canonical_path, site.canonical_path(host_path.path))
      end
      record_offset += batch_size
      $stderr.puts "Updated #{record_offset} / #{total_records}"
    end
  end

  def down
    # Nothing to do
  end
end
