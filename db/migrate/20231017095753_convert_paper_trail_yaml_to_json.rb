class ConvertPaperTrailYamlToJson < ActiveRecord::Migration[7.0]
  # https://github.com/paper-trail-gem/paper_trail/blob/v12.3.0/README.md#postgresql-json-column-type-support
  def up
    change_table :versions, bulk: true do |table|
      table.jsonb :new_object
      table.jsonb :new_object_changes
    end

    PaperTrail::Version.where.not(object: nil).find_each do |version|
      version.update_column(:new_object, YAML.unsafe_load(version.object))
      if version.object_changes
        version.update_column(
          :new_object_changes,
          YAML.unsafe_load(version.object_changes),
        )
      end
    end

    change_table :versions, bulk: true do |table|
      table.remove :object
      table.remove :object_changes
    end

    rename_column :versions, :new_object, :object
    rename_column :versions, :new_object_changes, :object_changes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
