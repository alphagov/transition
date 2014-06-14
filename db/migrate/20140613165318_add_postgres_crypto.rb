class AddPostgresCrypto < ActiveRecord::Migration
  def up
    execute <<-postgreSQL
      CREATE EXTENSION IF NOT EXISTS pgcrypto
    postgreSQL
  end

  def down
    execute <<-postgreSQL
      DROP EXTENSION IF EXISTS pgcrypto
    postgreSQL
  end
end
