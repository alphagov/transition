class AddOrganisationToUser < ActiveRecord::Migration
  def change
    add_column :users, :organisation, :string
  end
end
