class CreateHostPaths < ActiveRecord::Migration
  def change
    create_table :host_paths do |t|
      t.string :path, limit: 2048
      t.string :path_hash
      t.string :c14n_path_hash

      t.references :host
      t.references :mapping
    end

    add_index :host_paths, %i[host_id path_hash], unique: true # Used only for uniqueness inserting
    add_index :host_paths, :c14n_path_hash # Used for lookup when creating/editing mappings
    add_index :host_paths, :mapping_id
  end
end
