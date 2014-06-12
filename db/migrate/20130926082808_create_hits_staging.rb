class CreateHitsStaging < ActiveRecord::Migration
  def change
    # no indices, constraints or timestamps - this is meant to be fast
    create_table :hits_staging, id: false do |t|
      t.string :hostname
      t.string :path, limit: 1024
      t.string :http_status, limit: 3
      t.integer :count
      t.date :hit_on
    end
  end
end
