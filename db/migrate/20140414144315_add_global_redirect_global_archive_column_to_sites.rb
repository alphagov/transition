class AddGlobalRedirectGlobalArchiveColumnToSites < ActiveRecord::Migration
  def change
    add_column :sites, :global_redirect, :boolean, default: false
    add_column :sites, :global_archive, :boolean, default: false
  end
end
