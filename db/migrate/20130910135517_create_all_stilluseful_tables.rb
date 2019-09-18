class CreateAllStillusefulTables < ActiveRecord::Migration
  def change
    create_table "hosts", force: true do |t|
      t.integer  "site_id"
      t.string   "hostname"
      t.integer  "ttl"
      t.string   "cname"
      t.string   "live_cname"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_index "hosts", %w[hostname], name: "index_hosts_on_host", unique: true
    add_index "hosts", %w[site_id],  name: "index_hosts_on_site_id"

    create_table "mappings",    force: true do |t|
      t.integer "site_id",      null: false
      t.string  "path",         limit: 1024, null: false
      t.string  "path_hash",    limit: 40,   null: false
      t.string  "http_status",  limit: 3,    null: false
      t.text    "new_url"
      t.text    "suggested_url"
      t.text    "archive_url"
    end

    add_index "mappings", %w[site_id http_status], name: "index_mappings_on_site_id_and_http_status"
    add_index "mappings", %w[site_id path_hash], name: "index_mappings_on_site_id_and_path_hash", unique: true
    add_index "mappings", %w[site_id], name: "index_mappings_on_site_id"

    create_table "organisations", force: true do |t|
      t.string   "abbr"
      t.string   "title"
      t.date     "launch_date"
      t.string   "homepage"
      t.string   "furl"
      t.datetime "created_at",                               null: false
      t.datetime "updated_at",                               null: false
      t.string   "css"
    end

    add_index "organisations", %w[abbr], name: "index_organisations_on_abbr", unique: true

    create_table "sites", force: true do |t|
      t.integer  "organisation_id"
      t.string   "abbr"
      t.string   "query_params"
      t.datetime "tna_timestamp"
      t.string   "homepage"
      t.datetime "created_at",                      null: false
      t.datetime "updated_at",                      null: false
      t.string   "global_http_status", limit: 3
      t.text     "global_new_url"
    end

    add_index "sites", %w[organisation_id], name: "index_sites_on_organisation_id"
    add_index "sites", %w[abbr], name: "index_sites_on_site", unique: true
  end
end
