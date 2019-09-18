class AddManagedByTransitionToSite < ActiveRecord::Migration
  def up
    add_column :sites, :managed_by_transition, :boolean, null: false, default: true

    Site.update_all managed_by_transition: false
  end

  def down
    remove_column :sites, :managed_by_transition
  end
end
