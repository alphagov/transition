class IndexHitsOnHostIdAndPathHash < ActiveRecord::Migration
  def change
    add_index :hits, [:host_id, :path_hash]
  end
end
