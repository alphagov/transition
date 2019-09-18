require 'transition/import/hits'
require 'transition/import/daily_hit_totals'

namespace :import do
  desc 'Import hits for a file or mask'
  task :hits, [:filename_or_mask] => :environment do |_, args|
    filename_or_mask = args[:filename_or_mask]
    done = Transition::Import::Hits.from_mask!(filename_or_mask)
    if done.positive?
      Transition::Import::DailyHitTotals.from_hits!
      Transition::Import::HitsMappingsRelations.refresh!
    end
  end

  desc 'Copy filenames and etags for all old stats files from s3'
  task :update_legacy_from_s3, [:bucket] => :environment do |_, args|
    bucket = args[:bucket]
    %w[transition-stats pre-transition-stats].each do |prefix|
      Services.s3.list_objects(bucket: bucket, prefix: prefix).each do |resp|
        resp.contents.each do |object|
          begin
            # when the legacy data was uploaded to s3, the paths were
            # changed
            old_filename = object.key.sub("#{prefix}/", "data/#{prefix}/hits/")
            ImportedHitsFile
              .find_by(filename: old_filename)
              .update_attributes!(
                filename: object.key,
                content_hash: object.etag,
              )
            puts "#{object.key} - updated"
          rescue ActiveRecord::RecordNotFound
            puts "#{object.key} - skipped"
          end
        end
      end
    end
  end

  desc 'Import hits from S3 files in a W3C log format'
  task :from_w3c_files, [:bucket] => :environment do |_, args|
    bucket = args[:bucket]
    IngestW3cLogs.perform_async(bucket)
  end
end
