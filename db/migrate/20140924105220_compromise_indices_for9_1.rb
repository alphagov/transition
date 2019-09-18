##
# Compromise indices to make import/view hits work after discovery of
# very bad index selection on 9.1 in Preview. This is an admission that
# we don't know what's gone wrong but we know how to fix it. It's
# less than ideal, and hopefully we can go back to the two 3/4-column
# index solution for hits if we can use 9.3.x
#
# This is less than ideal because we know it will slow imports down.
# On the plus side it will speed the viewing of hits (particularly for
# summary/category) up by 100-200%
#
class CompromiseIndicesFor91 < ActiveRecord::Migration
  # A couple of helpers to avoid us having to say everything twice
  def remove_index_if_exists(table, *args)
    remove_index(table, *args) if index_exists?(table, *args)
  end

  def add_index_unless_exists(table, columns, options = {})
    add_index table, columns, options unless index_exists?(table, columns, options)
  end

  def up
    remove_index_if_exists  :hits, %i[host_id hit_on http_status]
    add_index_unless_exists :hits, %i[host_id hit_on]
    add_index_unless_exists :hits, %i[host_id http_status]
  end

  def down
    remove_index_if_exists :hits,  %i[host_id hit_on]
    remove_index_if_exists :hits,  %i[host_id http_status]
    add_index_unless_exists :hits, %i[host_id hit_on http_status]
  end
end
