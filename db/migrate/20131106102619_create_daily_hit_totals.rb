class CreateDailyHitTotals < ActiveRecord::Migration
  def change
    create_table :daily_hit_totals do |t|
      t.references :host, null: false
      t.string :http_status, null: false, limit: 3
      t.integer :count, null: false
      t.date :total_on, null: false
    end

    add_index :daily_hit_totals, %i[host_id total_on http_status], unique: true
  end
end
