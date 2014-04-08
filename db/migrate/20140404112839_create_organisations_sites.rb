class CreateOrganisationsSites < ActiveRecord::Migration
  def change
    create_table :organisations_sites, id: false do |t|
      t.references :site, null: false
      t.references :organisation, null: false
    end

    add_index :organisations_sites, [:site_id, :organisation_id], unique: true
  end
end
