class RationaliseHitsIndices < ActiveRecord::Migration
  # A couple of helpers to avoid us having to say everything twice
  def remove_index_if_exists(table, *args)
    remove_index(table, *args) if index_exists?(table, *args)
  end

  def add_index_unless_exists(table, columns, options = {})
    add_index table, columns, options unless index_exists?(table, columns, options)
  end

  ##
  # MySQL uses a lot of indices to get round its performance
  # issues. Postgres's query planner won't use them, and they
  # make import writes slow.
  #
  # Strip things back to what we do require.
  def up
    remove_index_if_exists :hits, %i[host_id hit_on]
    remove_index_if_exists :hits, %i[host_id http_status]
    remove_index_if_exists :hits, %i[host_id path_hash hit_on http_status]
    remove_index_if_exists :hits, %i[host_id path_hash]
    remove_index_if_exists :hits, [:host_id]
    remove_index_if_exists :hits, [:path_hash]

    add_index_unless_exists :hits, %i[host_id path hit_on http_status], unique: true
    add_index_unless_exists :hits, %i[host_id hit_on http_status]
  end

  def down
    add_index :hits, %i[host_id hit_on]
    add_index :hits, %i[host_id http_status]
    add_index :hits, %i[host_id path_hash hit_on http_status], unique: true
    add_index :hits, %i[host_id path_hash]
    add_index :hits, [:host_id]
    add_index :hits, [:path_hash]

    remove_index_if_exists :hits, column: %i[host_id path hit_on http_status]
    remove_index_if_exists :hits, column: %i[host_id hit_on http_status]
  end
end
