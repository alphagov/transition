require 'services'
require 'transition/import/hits'
require 'transition/import/iis_access_log_parser'

class IngestW3cLogWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, queue: 'ingest'

  def perform(bucket)
    puts "Ingesting IIS W3C logs from: #{bucket}" unless Rails.env.test?

    ::Services.s3.list_objects(bucket: bucket).each do |resp|
      resp.contents.each do |object|
        puts "Importing #{object.key}" unless Rails.env.test?

        import_record = Transition::Import::Hits.find_import_record(object.key)
        if import_record.content_hash == object.etag
          puts "Already ingested #{object.key} - skipping" unless Rails.env.test?
          next
        end

        begin
          tempfile = Tempfile.new('ingest')
          ::Services.s3.get_object(
            bucket: bucket, key: object.key, response_target: tempfile.path
          )
          Transition::Import::Hits.from_iis_w3c!(tempfile.path)
        ensure
          tempfile.unlink
        end
        Transition::Import::DailyHitTotals.from_hits!
        Transition::Import::HitsMappingsRelations.refresh!

        puts "Finished ingesting #{object.key}" unless Rails.env.test?
      end
    end

    puts 'Finished ingesting' unless Rails.env.test?
  end
end
