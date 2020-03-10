class AddTypeToMappingsTables < ActiveRecord::Migration
  def change
    add_column :mappings,         :type, :string, null: false
    add_column :mappings_staging, :type, :string
    add_column :mappings_batches, :type, :string

    add_index "mappings", %w[site_id type], name: "index_mappings_on_site_id_and_type"
  end
end
