class AddContentIdToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :content_id, :string
  end
end
