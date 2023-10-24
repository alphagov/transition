require "paper_trail/frameworks/active_record"

desc "Migrate PaperTrail YAML columns to JSON"
task migrate_paper_trail: :environment do
  # https://github.com/paper-trail-gem/paper_trail/blob/v12.3.0/README.md#convert-existing-yaml-data-to-json
  most_recent_record = PaperTrail::Version.last.id

  PaperTrail::Version.where.not(old_object: nil).find_each do |version|
    puts "Migrating object #{version.id} / #{most_recent_record}"

    version.update_columns(old_object: nil, object: YAML.unsafe_load(version.old_object))
  end

  PaperTrail::Version.where.not(old_object_changes: nil).find_each do |version|
    puts "Migrating object_changes #{version.id} / #{most_recent_record}"

    version.update_columns(old_object_changes: nil, object_changes: YAML.unsafe_load(version.old_object_changes))
  end
end
