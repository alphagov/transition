class ConvertPaperTrailYamlToJson < ActiveRecord::Migration[7.0]
  # https://github.com/paper-trail-gem/paper_trail/blob/v12.3.0/README.md#postgresql-json-column-type-support
  def change
    rename_column :versions, :object, :old_object
    rename_column :versions, :object_changes, :old_object_changes

    change_table :versions, bulk: true do |table|
      table.jsonb :object
      table.jsonb :object_changes
    end
  end
end
