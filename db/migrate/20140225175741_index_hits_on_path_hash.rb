class IndexHitsOnPathHash < ActiveRecord::Migration
  def change
    add_index :hits, :path_hash
  end
end
