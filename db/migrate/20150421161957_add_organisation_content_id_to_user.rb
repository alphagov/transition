class AddOrganisationContentIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :organisation_content_id, :string
  end
end
