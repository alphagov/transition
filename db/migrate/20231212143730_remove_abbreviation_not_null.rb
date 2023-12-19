class RemoveAbbreviationNotNull < ActiveRecord::Migration[7.1]
  def up
    change_column :sites, :abbr, :string, limit: 255, null: true
  end

  def down
    change_column :sites, :abbr, :string, limit: 255, null: false
  end
end
