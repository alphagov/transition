class AddCanonicalHostIdToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :canonical_host_id, :integer
    add_index :hosts, [:canonical_host_id]
  end
end
