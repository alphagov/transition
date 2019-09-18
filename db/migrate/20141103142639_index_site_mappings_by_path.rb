class IndexSiteMappingsByPath < ActiveRecord::Migration
  def change
    add_index :mappings, %i[site_id path], unique: true
  end
end
