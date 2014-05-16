require 'transition/import/console_job_wrapper'

module Transition
  class SetMappingType
    extend Transition::Import::ConsoleJobWrapper

    SET_TYPE_FROM_HTTP_STATUS = <<-mySQL
      UPDATE mappings USE INDEX (index_mappings_on_site_id_and_type)
      SET    type = (CASE http_status WHEN '301' THEN 'redirect' WHEN '410' THEN 'archive' END)
    mySQL

    def self.set_type!
      start 'Setting type from http_status for all mappings' do
        ActiveRecord::Base.connection.execute(SET_TYPE_FROM_HTTP_STATUS)
      end
    end
  end
end
