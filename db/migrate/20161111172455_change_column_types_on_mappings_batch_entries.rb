class ChangeColumnTypesOnMappingsBatchEntries < ActiveRecord::Migration
  def up
    change_column :mappings_batch_entries, :new_url, :text
    change_column :mappings_batch_entries, :archive_url, :text
  end

  def down
    # This is what we would need to do, but data would be lost by doing it,
    # so don't:
    # change_column :mappings_batch_entries, :new_url, :string, limit: 2048
    # change_column :mappings_batch_entries, :archive_url, :string, limit: 255
    raise ActiveRecord::IrreversibleMigration
  end
end
