class SwitchHostPathIndexToCanonicalPath < ActiveRecord::Migration
  def up
    add_index :host_paths, :canonical_path
    remove_index :host_paths, column: [:c14n_path_hash]
  end

  def down
    add_index :host_paths, :c14n_path_hash
    remove_index :host_paths, column: [:canonical_path]
  end
end
