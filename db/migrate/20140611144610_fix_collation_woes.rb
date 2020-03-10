class FixCollationWoes < ActiveRecord::Migration
  def up
    # This migration fixed some collation inconsistencies for MySQL, but has
    # been emptied on switching to PostgreSQL. The file remains so that we don't
    # have a migration record in the database without a matching file.
  end

  def down; end
end
