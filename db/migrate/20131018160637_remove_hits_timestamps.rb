class RemoveHitsTimestamps < ActiveRecord::Migration
  def change
    remove_columns :hits, :created_at, :updated_at
  end
end
