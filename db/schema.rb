# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(version: 20140815095728) do
  create_table "daily_hit_totals", :force => true do |t|
    t.integer "host_id",                  :null => false
    t.string  "http_status", :limit => 3, :null => false
    t.integer "count",                    :null => false
    t.date    "total_on",                 :null => false
  end

  add_index "daily_hit_totals", ["host_id", "total_on", "http_status"], :name => "daily_hit_totals_host_id_total_on_http_status_key", :unique => true

  create_table "days", :force => true do |t|
    t.date "hit_on"
  end

  add_index "days", ["hit_on"], :name => "days_hit_on_key", :unique => true

  create_table "hits", :force => true do |t|
    t.integer "host_id",                     :null => false
    t.string  "path",        :limit => 2048, :null => false
    t.string  "path_hash",   :limit => 40,   :null => false
    t.string  "http_status", :limit => 3,    :null => false
    t.integer "count",                       :null => false
    t.date    "hit_on",                      :null => false
    t.integer "mapping_id"
  end

  add_index "hits", ["host_id", "hit_on"], :name => "hits_host_id_hit_on_idx"
  add_index "hits", ["host_id", "http_status"], :name => "hits_host_id_http_status_idx"
  add_index "hits", ["host_id", "path_hash", "hit_on", "http_status"], :name => "hits_host_id_path_hash_hit_on_http_status_key", :unique => true
  add_index "hits", ["host_id", "path_hash"], :name => "hits_host_id_path_hash_idx"
  add_index "hits", ["host_id"], :name => "hits_host_id_idx"
  add_index "hits", ["mapping_id"], :name => "hits_mapping_id_idx"
  add_index "hits", ["path_hash"], :name => "hits_path_hash_idx"

  create_table "hits_staging", :id => false, :force => true do |t|
    t.string  "hostname"
    t.text    "path"
    t.string  "http_status", :limit => 3
    t.integer "count"
    t.date    "hit_on"
  end

  create_table "host_paths", :force => true do |t|
    t.string  "path",           :limit => 2048
    t.string  "path_hash"
    t.string  "c14n_path_hash"
    t.integer "host_id"
    t.integer "mapping_id"
  end

  add_index "host_paths", ["c14n_path_hash"], :name => "host_paths_c14n_path_hash_idx"
  add_index "host_paths", ["host_id", "path_hash"], :name => "host_paths_host_id_path_hash_key", :unique => true
  add_index "host_paths", ["mapping_id"], :name => "host_paths_mapping_id_idx"

  create_table "hosts", :force => true do |t|
    t.integer  "site_id",           :null => false
    t.string   "hostname",          :null => false
    t.integer  "ttl"
    t.string   "cname"
    t.string   "live_cname"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "ip_address"
    t.integer  "canonical_host_id"
  end

  add_index "hosts", ["canonical_host_id"], :name => "hosts_canonical_host_id_idx"
  add_index "hosts", ["hostname"], :name => "hosts_hostname_key", :unique => true
  add_index "hosts", ["site_id"], :name => "hosts_site_id_idx"

  create_table "http_statuses", :force => true do |t|
    t.string "status", :limit => 3
  end

  add_index "http_statuses", ["status"], :name => "http_statuses_status_key", :unique => true

  create_table "imported_hits_files", force: true do |t|
    t.string   "filename"
    t.string   "content_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mappings", force: true do |t|
    t.integer "site_id",                                      null: false
    t.string  "path",            limit: 1024,                 null: false
    t.string  "path_hash",       limit: 40,                   null: false
    t.text    "new_url"
    t.text    "suggested_url"
    t.text    "archive_url"
    t.boolean "from_redirector"
    t.string  "type",            limit: 510,                  null: false
  end

  add_index "mappings", ["site_id", "path_hash"], :name => "mappings_site_id_path_hash_key", :unique => true
  add_index "mappings", ["site_id", "type"], :name => "mappings_site_id_type_idx"
  add_index "mappings", ["site_id"], :name => "mappings_site_id_idx"

  create_table "mappings_batch_entries", :force => true do |t|
    t.string  "path",              :limit => 2048
    t.integer "mappings_batch_id"
    t.integer "mapping_id"
    t.boolean "processed",                         :default => false
  end

  add_index "mappings_batch_entries", ["mappings_batch_id"], :name => "mappings_batch_entries_mappings_batch_id_idx"

  create_table "mappings_batches", :force => true do |t|
    t.string   "tag_list"
    t.string   "new_url"
    t.boolean  "update_existing"
    t.integer  "user_id"
    t.integer  "site_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "state",           :default => "unqueued"
    t.boolean  "seen_outcome",    :default => false
    t.string   "type"
  end

  add_index "mappings_batches", ["user_id", "site_id"], :name => "mappings_batches_user_id_site_id_idx"

  create_table "mappings_staging", :id => false, :force => true do |t|
    t.text   "old_url"
    t.text   "new_url"
    t.string "host"
    t.string "path"
    t.string "path_hash"
    t.text   "suggested_url"
    t.text   "archive_url"
    t.string "type"
  end

  create_table "organisational_relationships", :force => true do |t|
    t.integer "parent_organisation_id"
    t.integer "child_organisation_id"
  end

  add_index "organisational_relationships", ["child_organisation_id"], :name => "organisational_relationships_child_organisation_id_idx"
  add_index "organisational_relationships", ["parent_organisation_id"], :name => "organisational_relationships_parent_organisation_id_idx"

  create_table "organisations", :force => true do |t|
    t.string   "title",                        :null => false
    t.string   "homepage"
    t.string   "furl"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "css"
    t.string   "ga_profile_id",  :limit => 16
    t.string   "whitehall_slug"
    t.string   "whitehall_type"
    t.string   "abbreviation"
  end

  add_index "organisations", ["title"], :name => "organisations_title_idx"
  add_index "organisations", ["whitehall_slug"], :name => "organisations_whitehall_slug_key", :unique => true

  create_table "organisations_sites", :id => false, :force => true do |t|
    t.integer "site_id",         :null => false
    t.integer "organisation_id", :null => false
  end

  add_index "organisations_sites", ["site_id", "organisation_id"], :name => "organisations_sites_site_id_organisation_id_key", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_idx"
  add_index "sessions", ["updated_at"], :name => "sessions_updated_at_idx"

  create_table "sites", :force => true do |t|
    t.integer  "organisation_id",                                :null => false
    t.string   "abbr",                                           :null => false
    t.string   "query_params"
    t.datetime "tna_timestamp",                                  :null => false
    t.string   "homepage"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.text     "global_new_url"
    t.boolean  "managed_by_transition",       :default => true,  :null => false
    t.date     "launch_date"
    t.string   "special_redirect_strategy"
    t.boolean  "global_redirect_append_path", :default => false, :null => false
    t.string   "global_type"
  end

  add_index "sites", ["abbr"], :name => "sites_abbr_key", :unique => true
  add_index "sites", ["organisation_id"], :name => "sites_organisation_id_idx"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], :name => "taggings_tag_id_taggable_id_taggable_type_context_tagger_id_key", :unique => true
  add_index "taggings", ["taggable_type", "taggable_id"], :name => "index_taggings_on_taggable_type_and_taggable_id"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "taggings_count", :default => 0
  end

  add_index "tags", ["name"], :name => "tags_name_key", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "uid"
    t.text     "permissions"
    t.boolean  "remotely_signed_out", :default => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "organisation_slug"
    t.boolean  "is_robot",            :default => false
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.integer  "user_id"
    t.text     "object_changes"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "versions_item_type_item_id_idx"

  create_table "whitelisted_hosts", :force => true do |t|
    t.string   "hostname",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "whitelisted_hosts", ["hostname"], :name => "whitelisted_hosts_hostname_key", :unique => true

end
