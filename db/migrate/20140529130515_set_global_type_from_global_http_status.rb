class SetGlobalTypeFromGlobalHTTPStatus < ActiveRecord::Migration
  SET_GLOBAL_TYPE_FROM_GLOBAL_HTTP_STATUS = <<-mySQL.freeze
    UPDATE sites
    SET    global_type = (CASE global_http_status
                          WHEN '301' THEN 'redirect'
                          WHEN '410' THEN 'archive'
                          END)
  mySQL


  def up
    ActiveRecord::Base.connection.execute(SET_GLOBAL_TYPE_FROM_GLOBAL_HTTP_STATUS)
  end

  SET_GLOBAL_HTTP_STATUS_FROM_GLOBAL_TYPE = <<-mySQL.freeze
    UPDATE sites
    SET    global_http_status = (CASE global_type
                                 WHEN 'redirect' THEN '301'
                                 WHEN 'archive' THEN '410'
                                 END)
  mySQL

  def down
    ActiveRecord::Base.connection.execute(SET_GLOBAL_HTTP_STATUS_FROM_GLOBAL_TYPE)
  end
end
