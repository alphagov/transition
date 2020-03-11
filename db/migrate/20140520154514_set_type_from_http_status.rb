class SetTypeFromHTTPStatus < ActiveRecord::Migration
  SET_MAPPING_TYPE_FROM_HTTP_STATUS = <<-mySQL.freeze
    UPDATE mappings
    SET    type = (CASE http_status
                   WHEN '301' THEN 'redirect'
                   WHEN '410' THEN 'archive'
                   WHEN '418' THEN 'pending_content'
                   END)
  mySQL

  SET_MAPPING_BATCH_TYPE_FROM_HTTP_STATUS = <<-mySQL.freeze
    UPDATE mappings_batches
    SET    type = (CASE http_status
                   WHEN '301' THEN 'redirect'
                   WHEN '410' THEN 'archive'
                   END)
  mySQL

  def up
    ActiveRecord::Base.connection.execute(SET_MAPPING_TYPE_FROM_HTTP_STATUS)
    ActiveRecord::Base.connection.execute(SET_MAPPING_BATCH_TYPE_FROM_HTTP_STATUS)
  end

  SET_MAPPING_HTTP_STATUS_FROM_TYPE = <<-mySQL.freeze
    UPDATE mappings
    SET    http_status = (CASE type
                          WHEN 'redirect' THEN '301'
                          WHEN 'archive' THEN '410'
                          WHEN 'pending_content' THEN '418'
                          END)
  mySQL

  SET_MAPPING_BATCH_HTTP_STATUS_FROM_TYPE = <<-mySQL.freeze
    UPDATE mappings_batches
    SET    http_status = (CASE type
                          WHEN 'redirect' THEN '301'
                          WHEN 'archive' THEN '410'
                          END)
  mySQL

  def down
    ActiveRecord::Base.connection.execute(SET_MAPPING_HTTP_STATUS_FROM_TYPE)
    ActiveRecord::Base.connection.execute(SET_MAPPING_BATCH_HTTP_STATUS_FROM_TYPE)
  end
end
