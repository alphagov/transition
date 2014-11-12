class AddPrecomputeAllHitsViewToSites < ActiveRecord::Migration
  def change
    add_column :sites,
               :precompute_all_hits_view, :boolean,
               null: false,
               default: false
  end
end
