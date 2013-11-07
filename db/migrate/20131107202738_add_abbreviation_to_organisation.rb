class AddAbbreviationToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :abbreviation, :string
  end
end
