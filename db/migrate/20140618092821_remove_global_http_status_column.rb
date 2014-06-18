class RemoveGlobalHTTPStatusColumn < ActiveRecord::Migration
  def change
    remove_column :sites, :global_http_status
  end
end
