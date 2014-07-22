class AddStiToMappingsBatchAndMappingsBatchEntry < ActiveRecord::Migration
  def change
    add_column :mappings_batches, :klass, :string
    add_column :mappings_batch_entries, :klass, :string

    add_column :mappings_batch_entries, :new_url, :string
    add_column :mappings_batch_entries, :type, :string
  end
end
