class AddHitCountToMappings < ActiveRecord::Migration
  def change
    add_column :mappings, :hit_count, :integer
    add_index :mappings, :hit_count
  end
end
