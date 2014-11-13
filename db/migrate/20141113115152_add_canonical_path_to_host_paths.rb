class AddCanonicalPathToHostPaths < ActiveRecord::Migration
  def change
    add_column :host_paths, :canonical_path, :string, limit: 2048
  end
end
