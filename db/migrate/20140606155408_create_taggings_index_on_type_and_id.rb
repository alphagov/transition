class CreateTaggingsIndexOnTypeAndId < ActiveRecord::Migration
  def change
    add_index :taggings, [:taggable_type, :taggable_id]
  end
end
