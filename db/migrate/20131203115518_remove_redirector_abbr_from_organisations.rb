class RemoveRedirectorAbbrFromOrganisations < ActiveRecord::Migration
  def up
    remove_column :organisations, :redirector_abbr
  end

  def down
    add_column :organisations, :redirector_abbr
    add_index  :organisations, :redirector_abbr
  end
end
