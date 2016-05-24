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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160314150053) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "daily_hit_totals", force: true do |t|
    t.integer "host_id",               null: false
    t.string  "http_status", limit: 3, null: false
    t.integer "count",                 null: false
    t.date    "total_on",              null: false
  end

  add_index "daily_hit_totals", ["host_id", "total_on", "http_status"], name: "index_daily_hit_totals_on_host_id_and_total_on_and_http_status", unique: true, using: :btree

  create_table "hits", force: true do |t|
    t.integer "host_id",                  null: false
    t.string  "path",        limit: 2048, null: false
    t.string  "http_status", limit: 3,    null: false
    t.integer "count",                    null: false
    t.date    "hit_on",                   null: false
    t.integer "mapping_id"
  end

  add_index "hits", ["host_id", "hit_on"], name: "index_hits_on_host_id_and_hit_on", using: :btree
  add_index "hits", ["host_id", "http_status"], name: "index_hits_on_host_id_and_http_status", using: :btree
  add_index "hits", ["host_id", "path", "hit_on", "http_status"], name: "index_hits_on_host_id_and_path_and_hit_on_and_http_status", unique: true, using: :btree
  add_index "hits", ["mapping_id"], name: "index_hits_on_mapping_id", using: :btree

  create_table "hits_staging", id: false, force: true do |t|
    t.string  "hostname"
    t.text    "path"
    t.string  "http_status", limit: 3
    t.integer "count"
    t.date    "hit_on"
  end

  create_table "host_paths", force: true do |t|
    t.string  "path",           limit: 2048
    t.integer "host_id"
    t.integer "mapping_id"
    t.string  "canonical_path", limit: 2048
  end

  add_index "host_paths", ["canonical_path"], name: "index_host_paths_on_canonical_path", using: :btree
  add_index "host_paths", ["host_id", "path"], name: "index_host_paths_on_host_id_and_path", unique: true, using: :btree
  add_index "host_paths", ["mapping_id"], name: "index_host_paths_on_mapping_id", using: :btree

  create_table "hosts", force: true do |t|
    t.integer  "site_id",           null: false
    t.string   "hostname",          null: false
    t.integer  "ttl"
    t.string   "cname"
    t.string   "live_cname"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "ip_address"
    t.integer  "canonical_host_id"
  end

  add_index "hosts", ["canonical_host_id"], name: "index_hosts_on_canonical_host_id", using: :btree
  add_index "hosts", ["hostname"], name: "index_hosts_on_host", unique: true, using: :btree
  add_index "hosts", ["site_id"], name: "index_hosts_on_site_id", using: :btree

  create_table "imported_hits_files", force: true do |t|
    t.string   "filename"
    t.string   "content_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "imported_hits_files", ["filename"], name: "index_imported_hits_files_on_filename", unique: true, using: :btree

  create_table "mappings", force: true do |t|
    t.integer "site_id",                                      null: false
    t.string  "path",            limit: 2048,                 null: false
    t.text    "new_url"
    t.text    "suggested_url"
    t.text    "archive_url"
    t.boolean "from_redirector",              default: false
    t.string  "type",                                         null: false
    t.integer "hit_count"
  end

  add_index "mappings", ["hit_count"], name: "index_mappings_on_hit_count", using: :btree
  add_index "mappings", ["site_id", "path"], name: "index_mappings_on_site_id_and_path", unique: true, using: :btree
  add_index "mappings", ["site_id", "type"], name: "index_mappings_on_site_id_and_type", using: :btree
  add_index "mappings", ["site_id"], name: "index_mappings_on_site_id", using: :btree

  create_table "mappings_batch_entries", force: true do |t|
    t.string  "path",              limit: 2048
    t.integer "mappings_batch_id"
    t.integer "mapping_id"
    t.boolean "processed",                      default: false
    t.string  "klass"
    t.string  "new_url",           limit: 2048
    t.string  "type"
    t.string  "archive_url"
  end

  add_index "mappings_batch_entries", ["mappings_batch_id"], name: "index_mappings_batch_entries_on_mappings_batch_id", using: :btree

  create_table "mappings_batches", force: true do |t|
    t.string   "tag_list"
    t.string   "new_url",         limit: 2048
    t.boolean  "update_existing"
    t.integer  "user_id"
    t.integer  "site_id"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "state",                        default: "unqueued"
    t.boolean  "seen_outcome",                 default: false
    t.string   "type"
    t.string   "klass"
  end

  add_index "mappings_batches", ["user_id", "site_id"], name: "index_mappings_batches_on_user_id_and_site_id", using: :btree

  create_table "organisational_relationships", force: true do |t|
    t.integer "parent_organisation_id"
    t.integer "child_organisation_id"
  end

  add_index "organisational_relationships", ["child_organisation_id"], name: "index_organisational_relationships_on_child_organisation_id", using: :btree
  add_index "organisational_relationships", ["parent_organisation_id"], name: "index_organisational_relationships_on_parent_organisation_id", using: :btree

  create_table "organisations", force: true do |t|
    t.string   "title",                     null: false
    t.string   "homepage"
    t.string   "furl"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "css"
    t.string   "ga_profile_id",  limit: 16
    t.string   "whitehall_slug"
    t.string   "whitehall_type"
    t.string   "abbreviation"
    t.string   "content_id",                null: false
  end

  add_index "organisations", ["content_id"], name: "index_organisations_on_content_id", unique: true, using: :btree
  add_index "organisations", ["title"], name: "index_organisations_on_title", using: :btree
  add_index "organisations", ["whitehall_slug"], name: "index_organisations_on_whitehall_slug", unique: true, using: :btree

  create_table "organisations_sites", id: false, force: true do |t|
    t.integer "site_id",         null: false
    t.integer "organisation_id", null: false
  end

  add_index "organisations_sites", ["site_id", "organisation_id"], name: "index_organisations_sites_on_site_id_and_organisation_id", unique: true, using: :btree

  create_table "requests", force: :cascade do |t|
    t.string "hostname"
    t.text   "path"
    t.string "http_status", limit: 3
    t.date   "hit_on"
  end

  add_index "requests", ["hit_on", "hostname", "path", "http_status"], name: "index_requests_on_hit_on_and_hostname_and_path_and_http_status", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "sites", force: true do |t|
    t.integer  "organisation_id",                             null: false
    t.string   "abbr",                                        null: false
    t.string   "query_params"
    t.datetime "tna_timestamp",                               null: false
    t.string   "homepage"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.text     "global_new_url"
    t.date     "launch_date"
    t.string   "special_redirect_strategy"
    t.boolean  "global_redirect_append_path", default: false, null: false
    t.string   "global_type"
    t.string   "homepage_title"
    t.string   "homepage_furl"
    t.boolean  "precompute_all_hits_view",    default: false, null: false
  end

  add_index "sites", ["abbr"], name: "index_sites_on_site", unique: true, using: :btree
  add_index "sites", ["organisation_id"], name: "index_sites_on_organisation_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  add_index "taggings", ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id", using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "uid"
    t.text     "permissions"
    t.boolean  "remotely_signed_out",     default: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "organisation_slug"
    t.boolean  "is_robot",                default: false
    t.boolean  "disabled",                default: false
    t.string   "organisation_content_id"
  end

  create_table "versions", force: true do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.integer  "user_id"
    t.text     "object_changes"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "whitelisted_hosts", force: true do |t|
    t.string   "hostname",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "whitelisted_hosts", ["hostname"], name: "index_whitelisted_hosts_on_hostname", unique: true, using: :btree

end
