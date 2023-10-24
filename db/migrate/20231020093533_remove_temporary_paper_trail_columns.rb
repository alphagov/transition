class RemoveTemporaryPaperTrailColumns < ActiveRecord::Migration[7.0]
  def change
    change_table :versions, bulk: true do |table|
      table.remove :old_object, type: :text
      table.remove :old_object_changes, type: :text
    end
  end
end
