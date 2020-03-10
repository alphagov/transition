# Stop using `path_hash` for anything important.
#
# * change the unique host path index on `host_id` and `path_hash` for one on
#   `host_id` and `path`
# * drop NOT NULL constraints on all `path_hash` fields
class StopUsingPathHash < ActiveRecord::Migration
  def up
    remove_index :host_paths, column: %i[host_id path_hash]
    add_index :host_paths, %i[host_id path], unique: true

    # Make the mappings and hits path hashes unimportant to our new code,
    # but still present to any extant processes needing access
    change_column_null :mappings, :path_hash, true
    change_column_null :hits,     :path_hash, true
  end

  # If we're rolling back this migration, we will have nulls
  # in hits/mappings path_hash where none should exist. Fill them
  # in using the path.
  #
  # Note that this +down+ will be unrunnable and this migration will be
  # irreversible once DROP EXTENSION pgcrypto is run (planned for the
  # deploy following the one in which this migration runs)
  #
  # As a result, +raise ActiveRecord::IrreversibleMigration+ or convert this
  # SQL to Ruby following initial deploy.
  BACKFILL_PATH_HASH_NULLS = <<-postgreSQL.freeze
    UPDATE hits
    SET    path_hash = (encode(digest(hits.path, 'sha1'), 'hex'))
    WHERE  hits.path_hash IS NULL;

    UPDATE mappings
    SET    path_hash = (encode(digest(mappings.path, 'sha1'), 'hex'))
    WHERE  mappings.path_hash IS NULL;
  postgreSQL

  def down
    remove_index :host_paths, column: %i[host_id path]
    add_index :host_paths, %i[host_id path_hash], unique: true

    # Fill in any blanks in hits/mappings that can't be NULL
    execute(BACKFILL_PATH_HASH_NULLS)

    # Enforce that constraint
    change_column_null :hits,     :path_hash, false
    change_column_null :mappings, :path_hash, false
  end
end
