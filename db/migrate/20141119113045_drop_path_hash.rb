class DropPathHash < ActiveRecord::Migration
  def up
    remove_column :hits,       :path_hash

    # implicitly removes already-redundant index_mappings_on_site_id_and_path_hash
    remove_column :mappings,   :path_hash

    remove_column :host_paths, :path_hash
    remove_column :host_paths, :c14n_path_hash
  end

  def down
    add_column :hits,       :path_hash,      :string, limit: 40
    add_column :mappings,   :path_hash,      :string, limit: 40
    add_column :host_paths, :path_hash,      :string
    add_column :host_paths, :c14n_path_hash, :string

    add_index :mappings, %i[site_id path_hash]
  end
end
