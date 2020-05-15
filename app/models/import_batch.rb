require "csv"
require "transition/import/csv/import_batch_row"
require "transition/import/csv/csv_separator_detector"

class ImportBatch < MappingsBatch
  attr_accessor :raw_csv

  has_many :entries,
           foreign_key: :mappings_batch_id,
           class_name: "ImportBatchEntry",
           dependent: :delete_all

  validates :raw_csv,
            presence: {
              if: :new_record?, # we only care about raw_csv at create-time
              message: I18n.t("mappings.import.raw_csv_empty"),
            }
  validates :old_urls, old_urls_are_for_site: true
  validates :canonical_paths,
            presence: {
              if: :new_record?,
              message: I18n.t("mappings.paths_empty"),
            }
  validates :new_urls,
            each_in_collection: {
              validator: LengthValidator,
              maximum: (64.kilobytes - 1),
              message: I18n.t("mappings.new_url_too_long"),
            }
  validates :new_urls,
            each_in_collection: {
              validator: NonBlankURLValidator,
              message: I18n.t("mappings.import.new_url_invalid"),
            }
  validates :new_urls,
            each_in_collection: {
              validator: HostInWhitelistValidator,
              message: I18n.t("mappings.bulk.new_url_must_be_on_whitelist"),
            }
  validates :archive_urls,
            each_in_collection: {
              validator: LengthValidator,
              maximum: (64.kilobytes - 1),
              message: I18n.t("mappings.new_url_too_long"),
            }

  after_create :create_entries

  def create_entries
    canonical_paths = deduplicated_csv_rows.map(&:path)
    existing_mappings = site.mappings.where(path: canonical_paths)

    deduplicated_csv_rows.each do |row|
      entry = ImportBatchEntry.new(
        path: row.path,
        type: row.type,
        new_url: row.new_url,
        archive_url: row.archive_url,
      )

      entry.mappings_batch = self
      entry.mapping = existing_mappings.detect { |mapping| mapping.path == row.path }
      entry.save!
    end
  end

  def old_urls
    deduplicated_csv_rows.map(&:old_value)
  end

  def new_urls
    deduplicated_csv_rows.select(&:redirect?).map(&:new_url).uniq
  end

  def archive_urls
    deduplicated_csv_rows.map(&:archive_url).compact
  end

  def canonical_paths
    deduplicated_csv_rows.map(&:path)
  end

  def verb
    "import"
  end

private

  def deduplicated_csv_rows
    @deduplicated_csv_rows ||= begin
      return [] if raw_csv.blank?

      separator = Transition::Import::CSV::CSVSeparatorDetector.new(raw_csv.lines.to_a[0..5]).separator

      rows_by_path = {}
      CSV.parse(raw_csv, col_sep: separator).each.with_index(1) do |csv_row, line_number|
        # Blank lines are parsed as []. Rows with just a separator are parsed as [nil, nil]
        next unless csv_row.present? && csv_row[0].present?

        row = Transition::Import::CSV::ImportBatchRow.new(site, line_number, csv_row)
        next if row.ignorable?

        # If we don't yet have a row for this canonical path, or if the row we're
        # considering is 'better' than the one we have already, put this row into
        # the hash.
        # The second expression here calls the `<=>` method on ImportBatchRow,
        # which knows which of two mappings is 'better'
        if !rows_by_path.key?(row.path) || row > rows_by_path[row.path]
          rows_by_path[row.path] = row
        end
      end
      rows_by_path.values
    end
  end
end
