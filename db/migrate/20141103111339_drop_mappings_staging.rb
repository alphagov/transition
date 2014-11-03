class DropMappingsStaging < ActiveRecord::Migration
  def up
    drop_table :mappings_staging
  end

  def down
    create_table :mappings_staging, id: false do |t|
      t.text :old_url
      t.text :new_url
      t.string :http_status, length: 3
      t.string :host, length: 512
      t.string :path, length: 2048
      t.string :path_hash, length: 40
      t.text :suggested_url
      t.text :archive_url
    end
  end
end
