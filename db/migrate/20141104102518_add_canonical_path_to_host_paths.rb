class AddCanonicalPathToHostPaths < ActiveRecord::Migration
  def up
    # Remove the UNIQUE index on path_hash
    remove_index :host_paths, column: [:host_id, :path_hash]

    # Add a canonical path column and populate it using optic14n's c14n rules
    add_column    :host_paths, :canonical_path, :string, limit: 2048
    require 'transition/import/hits_mappings_relations'
    Transition::Import::HitsMappingsRelations.new.send :connect_mappings_to_host_paths!

    # Add the UNIQUE index to non-canonical path now we've done the expensive work
    add_index     :host_paths, [:host_id, :path], unique: true

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

    # Remove the UNIQUE index on host_paths (host_id, path)
    remove_index  :host_paths, column: [:host_id, :path]
    # And put it back on (host_id, path_hash)
    add_index :host_paths, [:host_id, :path_hash], unique: true

    # Fill in any blanks in hits/mappings that can't be NULL
    ActiveRecord::Base.connection.execute(BACKFILL_PATH_HASH_NULLS)

    # Enforce that constraint
    change_column_null :hits,     :path_hash, false
    change_column_null :mappings, :path_hash, false
  end
end
