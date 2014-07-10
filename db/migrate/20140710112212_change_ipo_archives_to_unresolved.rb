class ChangeIpoArchivesToUnresolved < ActiveRecord::Migration
  SET_IPO_ARCHIVE_TO_UNRESOLVED = <<-mySQL
    UPDATE mappings
    SET type = 'unresolved'
    WHERE site_id = 337 AND type = 'archive'
  mySQL

  def up
    ActiveRecord::Base.connection.execute(SET_IPO_ARCHIVE_TO_UNRESOLVED)
  end

  SET_IPO_UNRESOLVED_TO_ARCHIVE = <<-mySQL
    UPDATE mappings
    SET type = 'archive'
    WHERE site_id = 337 AND type = 'unresolved'
  mySQL

  def down
    ActiveRecord::Base.connection.execute(SET_IPO_UNRESOLVED_TO_ARCHIVE)
  end
end
