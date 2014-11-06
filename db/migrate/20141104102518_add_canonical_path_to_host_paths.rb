class AddCanonicalPathToHostPaths < ActiveRecord::Migration
  def up
    change_column_null :mappings, :path_hash, true
    change_column_null :hits,     :path_hash, true

    add_column    :host_paths, :canonical_path, :string, limit: 2048, unique: true
    add_index     :host_paths, [:host_id, :canonical_path]
  end

  # If we're rolling back this migration, we may have nulls
  # in hits/mappings where none should exist. Compute them from the path.
  # Note that this +down+ will be unrunnable and this migration will be
  # irreversible once DROP EXTENSION pgcrypto is run (planned for the
  # deploy following the one in which this migration runs)
  BACKFILL_PATH_HASH_NULLS = <<-postgreSQL
    UPDATE hits
    SET    path_hash = (encode(digest(hits.path, 'sha1'), 'hex'))
    WHERE  hits.path_hash IS NULL;

    UPDATE mappings
    SET    path_hash = (encode(digest(mappings.path, 'sha1'), 'hex'))
    WHERE  mappings.path_hash IS NULL;
  postgreSQL

  def down
    remove_column :host_paths, :canonical_path

    ActiveRecord::Base.connection.execute(BACKFILL_PATH_HASH_NULLS)

    change_column_null :mappings, :path_hash, false
    change_column_null :hits,     :path_hash, false
  end
end
