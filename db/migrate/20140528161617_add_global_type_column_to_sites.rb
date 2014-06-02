class AddGlobalTypeColumnToSites < ActiveRecord::Migration
  def change
    add_column :sites, :global_type, :string
  end
end
