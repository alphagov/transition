class AddSeenOutcomeToMappingsBatch < ActiveRecord::Migration
  def change
    add_column :mappings_batches, :seen_outcome, :boolean, default: false
  end
end
