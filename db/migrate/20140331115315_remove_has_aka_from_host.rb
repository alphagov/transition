class RemoveHasAkaFromHost < ActiveRecord::Migration
  def change
    remove_column :hosts, :has_aka
  end
end
