class CreateMappingsStaging < ActiveRecord::Migration
  def change
    create_table :mappings_staging, id: false do |t|
      t.text :old_url, limit: 16777215
      t.text :new_url, limit: 16777215
      t.string :http_status, length: 3
      t.string :host, length: 512
      t.string :path, length: 1024
      t.string :path_hash, length: 40
      t.text :suggested_url, limit: 16777215
      t.text :archive_url, limit: 16777215
    end
  end
end
