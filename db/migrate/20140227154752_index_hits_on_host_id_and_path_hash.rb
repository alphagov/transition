class IndexHitsOnHostIdAndPathHash < ActiveRecord::Migration
  def change
    add_index :hits, %i[host_id path_hash]
  end
end
