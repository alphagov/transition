class RemoveGlobalHTTPStatusColumn < ActiveRecord::Migration
  def up
    remove_column :sites, :global_http_status
  end

  def down
    add_column :sites, :global_http_status, :string, limit: 3
  end
end
