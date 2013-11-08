class RenameOrganisationAbbrToRedirectorAbbr < ActiveRecord::Migration
  def up
    rename_column :organisations, :abbr, :redirector_abbr
  end

  def down
    rename_column :organisations, :redirector_abbr, :abbr
  end
end
