class AddOrganisationsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :organisations, :text
  end
end
