class IndexOrganisationsOnTitle < ActiveRecord::Migration
  def change
    add_index :organisations, :title
  end
end
