class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :hostname
      t.text :path
      t.string :http_status, limit: 3
      t.date :hit_on
    end
    add_index(:requests, [:hit_on, :hostname, :path, :http_status], unique: false)
  end
end
