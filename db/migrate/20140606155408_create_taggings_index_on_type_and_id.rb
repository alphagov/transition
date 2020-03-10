class CreateTaggingsIndexOnTypeAndId < ActiveRecord::Migration
  def change
    add_index :taggings, %i[taggable_type taggable_id]
  end
end
