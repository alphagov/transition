class AddTransitionStatusToSite < ActiveRecord::Migration
  def change
    add_column :sites, :transition_status, :string
  end
end
