class HarmoniseNewURLLengths < ActiveRecord::Migration
  def up
    change_column :mappings_batches, :new_url, :string, limit: 2048
    change_column :mappings_batch_entries, :new_url, :string, limit: 2048
  end

  def down
    change_column :mappings_batches, :new_url, :string, limit: 255
    change_column :mappings_batch_entries, :new_url, :string, limit: 255
  end
end
