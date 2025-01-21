# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2023_12_12_143730) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "daily_hit_totals", force: :cascade do |t|
    t.integer "host_id", null: false
    t.string "http_status", limit: 3, null: false
    t.integer "count", null: false
    t.date "total_on", null: false
    t.index ["host_id", "total_on", "http_status"], name: "index_daily_hit_totals_on_host_id_and_total_on_and_http_status", unique: true
  end

  create_table "hits", force: :cascade do |t|
    t.integer "host_id", null: false
    t.string "path", limit: 2048, null: false
    t.string "http_status", limit: 3, null: false
    t.integer "count", null: false
    t.date "hit_on", null: false
    t.integer "mapping_id"
    t.index ["host_id", "hit_on"], name: "index_hits_on_host_id_and_hit_on"
    t.index ["host_id", "http_status"], name: "index_hits_on_host_id_and_http_status"
    t.index ["host_id", "path", "hit_on", "http_status"], name: "index_hits_on_host_id_and_path_and_hit_on_and_http_status", unique: true
    t.index ["mapping_id"], name: "index_hits_on_mapping_id"
  end

  create_table "hits_staging", id: false, force: :cascade do |t|
    t.text "hostname"
    t.text "path"
    t.string "http_status", limit: 3
    t.integer "count"
    t.date "hit_on"
  end

  create_table "host_paths", force: :cascade do |t|
    t.string "path", limit: 2048
    t.integer "host_id"
    t.integer "mapping_id"
    t.string "canonical_path", limit: 2048
    t.index ["canonical_path"], name: "index_host_paths_on_canonical_path"
    t.index ["host_id", "path"], name: "index_host_paths_on_host_id_and_path", unique: true
    t.index ["mapping_id"], name: "index_host_paths_on_mapping_id"
  end

  create_table "hosts", force: :cascade do |t|
    t.integer "site_id", null: false
    t.text "hostname", null: false
    t.integer "ttl"
    t.string "cname", limit: 255
    t.string "live_cname", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "ip_address", limit: 255
    t.integer "canonical_host_id"
    t.index ["canonical_host_id"], name: "index_hosts_on_canonical_host_id"
    t.index ["hostname"], name: "index_hosts_on_host", unique: true
    t.index ["site_id"], name: "index_hosts_on_site_id"
  end

  create_table "imported_hits_files", force: :cascade do |t|
    t.string "filename", limit: 255
    t.string "content_hash", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["filename"], name: "index_imported_hits_files_on_filename", unique: true
  end

  create_table "mappings", force: :cascade do |t|
    t.integer "site_id", null: false
    t.string "path", limit: 2048, null: false
    t.text "new_url"
    t.text "suggested_url"
    t.text "archive_url"
    t.boolean "from_redirector", default: false
    t.string "type", limit: 255, null: false
    t.integer "hit_count"
    t.index ["hit_count"], name: "index_mappings_on_hit_count"
    t.index ["site_id", "path"], name: "index_mappings_on_site_id_and_path", unique: true
    t.index ["site_id", "type"], name: "index_mappings_on_site_id_and_type"
    t.index ["site_id"], name: "index_mappings_on_site_id"
  end

  create_table "mappings_batch_entries", force: :cascade do |t|
    t.string "path", limit: 2048
    t.integer "mappings_batch_id"
    t.integer "mapping_id"
    t.boolean "processed", default: false
    t.string "klass", limit: 255
    t.text "new_url"
    t.string "type", limit: 255
    t.text "archive_url"
    t.index ["mappings_batch_id"], name: "index_mappings_batch_entries_on_mappings_batch_id"
  end

  create_table "mappings_batches", force: :cascade do |t|
    t.string "tag_list", limit: 255
    t.string "new_url", limit: 2048
    t.boolean "update_existing"
    t.integer "user_id"
    t.integer "site_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "state", limit: 255, default: "unqueued"
    t.boolean "seen_outcome", default: false
    t.string "type", limit: 255
    t.string "klass", limit: 255
    t.index ["user_id", "site_id"], name: "index_mappings_batches_on_user_id_and_site_id"
  end

  create_table "organisational_relationships", force: :cascade do |t|
    t.integer "parent_organisation_id"
    t.integer "child_organisation_id"
    t.index ["child_organisation_id"], name: "index_organisational_relationships_on_child_organisation_id"
    t.index ["parent_organisation_id"], name: "index_organisational_relationships_on_parent_organisation_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.string "title", limit: 255, null: false
    t.string "homepage", limit: 255
    t.string "furl", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "css", limit: 255
    t.string "ga_profile_id", limit: 16
    t.string "whitehall_slug", limit: 255
    t.string "whitehall_type", limit: 255
    t.string "abbreviation", limit: 255
    t.string "content_id", limit: 255, null: false
    t.index ["content_id"], name: "index_organisations_on_content_id", unique: true
    t.index ["title"], name: "index_organisations_on_title"
    t.index ["whitehall_slug"], name: "index_organisations_on_whitehall_slug", unique: true
  end

  create_table "organisations_sites", id: false, force: :cascade do |t|
    t.integer "site_id", null: false
    t.integer "organisation_id", null: false
    t.index ["site_id", "organisation_id"], name: "index_organisations_sites_on_site_id_and_organisation_id", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", limit: 255, null: false
    t.text "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "sites", force: :cascade do |t|
    t.integer "organisation_id", null: false
    t.string "abbr", limit: 255
    t.string "query_params", limit: 255
    t.datetime "tna_timestamp", precision: nil, null: false
    t.string "homepage", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "global_new_url"
    t.date "launch_date"
    t.string "special_redirect_strategy", limit: 255
    t.boolean "global_redirect_append_path", default: false, null: false
    t.string "global_type", limit: 255
    t.string "homepage_title", limit: 255
    t.string "homepage_furl", limit: 255
    t.boolean "precompute_all_hits_view", default: false, null: false
    t.index ["abbr"], name: "index_sites_on_site", unique: true
    t.index ["organisation_id"], name: "index_sites_on_organisation_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type", limit: 255
    t.integer "tagger_id"
    t.string "tagger_type", limit: 255
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "email", limit: 255
    t.string "uid", limit: 255
    t.text "permissions"
    t.boolean "remotely_signed_out", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "organisation_slug", limit: 255
    t.boolean "is_robot", default: false
    t.boolean "disabled", default: false
    t.string "organisation_content_id", limit: 255
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", limit: 255, null: false
    t.integer "item_id", null: false
    t.string "event", limit: 255, null: false
    t.string "whodunnit", limit: 255
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.jsonb "object"
    t.jsonb "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "whitelisted_hosts", force: :cascade do |t|
    t.text "hostname", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["hostname"], name: "index_whitelisted_hosts_on_hostname", unique: true
  end
end
