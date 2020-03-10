class AddStateToMappingsBatchAndEntries < ActiveRecord::Migration
  def change
    add_column :mappings_batches, :state, :string, default: "unqueued"
    add_column :mappings_batch_entries, :processed, :boolean, default: false
  end
end
