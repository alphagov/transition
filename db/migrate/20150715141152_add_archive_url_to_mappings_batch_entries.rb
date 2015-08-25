class AddArchiveURLToMappingsBatchEntries < ActiveRecord::Migration
  def change
    add_column :mappings_batch_entries, :archive_url, :string
  end
end
