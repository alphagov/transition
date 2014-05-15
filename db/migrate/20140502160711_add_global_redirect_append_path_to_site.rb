class AddGlobalRedirectAppendPathToSite < ActiveRecord::Migration
  def change
    add_column :sites, :global_redirect_append_path, :boolean, default: false, null: false
  end
end
