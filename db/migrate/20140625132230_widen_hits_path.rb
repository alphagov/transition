class WidenHitsPath < ActiveRecord::Migration
  def up
    change_column :hits_staging, :path, :text
    change_column :hits, :path, :string, limit: 2048
  end

  def down
    change_column :hits_staging, :path, :string, limit: 1024
    change_column :hits, :path, :string, limit: 1024
  end
end
