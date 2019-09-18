class CreateMappingsBatchTables < ActiveRecord::Migration
  def change
    create_table :mappings_batches do |t|
      t.string :tag_list
      t.string :http_status
      t.string :new_url
      t.boolean :update_existing
      t.references :user
      t.references :site
      t.timestamps
    end
    add_index :mappings_batches, %i[user_id site_id]

    create_table :mappings_batch_entries do |t|
      t.string :path, limit: 2048
      t.references :mappings_batch
      t.references :mapping
    end
    add_index :mappings_batch_entries, :mappings_batch_id
  end
end
