class ChangeOfstedArchivesToUnresolved < ActiveRecord::Migration
  SET_OFSTED_ARCHIVE_TO_UNRESOLVED = <<-mySQL
    UPDATE mappings
    SET type = 'unresolved'
    WHERE site_id = 403 AND type = 'archive'
  mySQL

  def up
    ActiveRecord::Base.connection.execute(SET_OFSTED_ARCHIVE_TO_UNRESOLVED)
  end

  SET_OFSTED_UNRESOLVED_TO_ARCHIVE = <<-mySQL
    UPDATE mappings
    SET type = 'archive'
    WHERE site_id = 403 AND type = 'unresolved'
  mySQL

  def down
    ActiveRecord::Base.connection.execute(SET_OFSTED_UNRESOLVED_TO_ARCHIVE)
  end
end
