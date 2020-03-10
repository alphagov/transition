class RemoveHTTPStatusFromMappingsTables < ActiveRecord::Migration
  def up
    remove_index :mappings, %i[site_id http_status]

    remove_column :mappings,         :http_status
    remove_column :mappings_staging, :http_status
    remove_column :mappings_batches, :http_status
  end

  def down
    add_column :mappings,         :http_status, :string, limit: 3, null: false
    add_column :mappings_staging, :http_status, :string
    add_column :mappings_batches, :http_status, :string

    add_index "mappings", %w[site_id http_status], name: "index_mappings_on_site_id_and_http_status"
  end
end
