class HarmonisePathLengths < ActiveRecord::Migration
  def up
    change_column :mappings, :path, :string, limit: 2048
  end

  def down
    change_column :mappings, :path, :string, limit: 1024
  end
end
