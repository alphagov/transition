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

ActiveRecord::Schema.define(:version => 20140606155408) do

  create_table "daily_hit_totals", :force => true do |t|
    t.integer "host_id",                  :null => false
    t.string  "http_status", :limit => 6, :null => false
    t.integer "count",                    :null => false
    t.date    "total_on",                 :null => false
  end

  add_index "daily_hit_totals", ["host_id", "total_on", "http_status"], :name => "daily_hit_totals_host_id_total_on_http_status_key", :unique => true

  create_table "hits", :force => true do |t|
    t.integer "host_id",                     :null => false
    t.string  "path",        :limit => 2048, :null => false
    t.string  "path_hash",   :limit => 80,   :null => false
    t.string  "http_status", :limit => 6,    :null => false
    t.integer "count",                       :null => false
    t.date    "hit_on",                      :null => false
    t.integer "mapping_id"
  end

  add_index "hits", ["host_id", "path_hash", "hit_on", "http_status"], :name => "hits_host_id_path_hash_hit_on_http_status_key", :unique => true

  create_table "hits_staging", :id => false, :force => true do |t|
    t.string  "hostname",    :limit => 510
    t.string  "path",        :limit => 2048
    t.string  "http_status", :limit => 6
    t.integer "count"
    t.date    "hit_on"
  end

  create_table "host_paths", :force => true do |t|
    t.string  "path",           :limit => 4096
    t.string  "path_hash",      :limit => 510
    t.string  "c14n_path_hash", :limit => 510
    t.integer "host_id"
    t.integer "mapping_id"
  end

  add_index "host_paths", ["host_id", "path_hash"], :name => "host_paths_host_id_path_hash_key", :unique => true

  create_table "hosts", :force => true do |t|
    t.integer  "site_id",                          :null => false
    t.string   "hostname",          :limit => 510, :null => false
    t.integer  "ttl"
    t.string   "cname",             :limit => 510
    t.string   "live_cname",        :limit => 510
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "ip_address",        :limit => 510
    t.integer  "canonical_host_id"
  end

  add_index "hosts", ["hostname"], :name => "hosts_hostname_key", :unique => true

  create_table "mappings", :force => true do |t|
    t.integer "site_id",                         :null => false
    t.string  "path",            :limit => 2048, :null => false
    t.string  "path_hash",       :limit => 80,   :null => false
    t.text    "new_url"
    t.text    "suggested_url"
    t.text    "archive_url"
    t.boolean "from_redirector"
    t.string  "type",            :limit => 510,  :null => false
  end

  add_index "mappings", ["site_id", "path_hash"], :name => "mappings_site_id_path_hash_key", :unique => true

  create_table "mappings_batch_entries", :force => true do |t|
    t.string  "path",              :limit => 4096
    t.integer "mappings_batch_id"
    t.integer "mapping_id"
    t.boolean "processed"
  end

  create_table "mappings_batches", :force => true do |t|
    t.string   "tag_list",        :limit => 510
    t.string   "new_url",         :limit => 510
    t.boolean  "update_existing"
    t.integer  "user_id"
    t.integer  "site_id"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.string   "state",           :limit => 510, :default => "unqueued"
    t.boolean  "seen_outcome"
    t.string   "type",            :limit => 510
  end

  create_table "mappings_staging", :id => false, :force => true do |t|
    t.text   "old_url"
    t.text   "new_url"
    t.string "host",          :limit => 510
    t.string "path",          :limit => 510
    t.string "path_hash",     :limit => 510
    t.text   "suggested_url"
    t.text   "archive_url"
    t.string "type",          :limit => 510
  end

  create_table "organisational_relationships", :force => true do |t|
    t.integer "parent_organisation_id"
    t.integer "child_organisation_id"
  end

  create_table "organisations", :force => true do |t|
    t.string   "title",          :limit => 510, :null => false
    t.string   "homepage",       :limit => 510
    t.string   "furl",           :limit => 510
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "css",            :limit => 510
    t.string   "ga_profile_id",  :limit => 32
    t.string   "whitehall_slug", :limit => 510
    t.string   "whitehall_type", :limit => 510
    t.string   "abbreviation",   :limit => 510
  end

  add_index "organisations", ["whitehall_slug"], :name => "organisations_whitehall_slug_key", :unique => true

  create_table "organisations_sites", :id => false, :force => true do |t|
    t.integer "site_id",         :null => false
    t.integer "organisation_id", :null => false
  end

  add_index "organisations_sites", ["site_id", "organisation_id"], :name => "organisations_sites_site_id_organisation_id_key", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :limit => 510, :null => false
    t.text     "data"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "sites", :force => true do |t|
    t.integer  "organisation_id",                            :null => false
    t.string   "abbr",                        :limit => 510, :null => false
    t.string   "query_params",                :limit => 510
    t.datetime "tna_timestamp",                              :null => false
    t.string   "homepage",                    :limit => 510
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "global_http_status",          :limit => 6
    t.text     "global_new_url"
    t.boolean  "managed_by_transition",                      :null => false
    t.date     "launch_date"
    t.string   "special_redirect_strategy",   :limit => 510
    t.boolean  "global_redirect_append_path",                :null => false
    t.string   "global_type",                 :limit => 510
  end

  add_index "sites", ["abbr"], :name => "sites_abbr_key", :unique => true

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", :limit => 510
    t.integer  "tagger_id"
    t.string   "tagger_type",   :limit => 510
    t.string   "context",       :limit => 256
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], :name => "taggings_tag_id_taggable_id_taggable_type_context_tagger_id_key", :unique => true
  add_index "taggings", ["taggable_type", "taggable_id"], :name => "index_taggings_on_taggable_type_and_taggable_id"

  create_table "tags", :force => true do |t|
    t.string  "name",           :limit => 510
    t.integer "taggings_count",                :default => 0
  end

  add_index "tags", ["name"], :name => "tags_name_key", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name",                :limit => 510
    t.string   "email",               :limit => 510
    t.string   "uid",                 :limit => 510
    t.text     "permissions"
    t.boolean  "remotely_signed_out"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "organisation_slug",   :limit => 510
    t.boolean  "is_robot"
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :limit => 510, :null => false
    t.integer  "item_id",                       :null => false
    t.string   "event",          :limit => 510, :null => false
    t.string   "whodunnit",      :limit => 510
    t.integer  "user_id"
    t.text     "object_changes"
    t.text     "object"
    t.datetime "created_at"
  end

  create_table "whitelisted_hosts", :force => true do |t|
    t.string   "hostname",   :limit => 510, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "whitelisted_hosts", ["hostname"], :name => "whitelisted_hosts_hostname_key", :unique => true

end
