class CreateWhitelistedHosts < ActiveRecord::Migration
  def change
    create_table "whitelisted_hosts", force: true do |t|
      t.string   "hostname", null: false
      t.timestamps
    end
    add_index :whitelisted_hosts, :hostname, unique: true
  end
end
