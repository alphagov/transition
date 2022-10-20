class ChangeHostToText < ActiveRecord::Migration[7.0]
  def up
    change_column :hits_staging, :hostname, :text
    change_column :hosts, :hostname, :text
    change_column :whitelisted_hosts, :hostname, :text
  end

  def down
    # This is what we would need to do, but data would be lost by doing it,
    # so don't:
    # change_column :hits_staging, :hostname, :string, limit: 255
    # change_column :hosts, :hostname, :string, limit: 255
    # change_column :whitelisted_hosts, :hostname, :string, limit: 255
    raise ActiveRecord::IrreversibleMigration
  end
end
