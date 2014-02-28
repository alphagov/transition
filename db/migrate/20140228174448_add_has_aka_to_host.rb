class AddHasAkaToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :has_aka, :boolean
  end
end
