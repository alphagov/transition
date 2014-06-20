require 'csv'

class ImportBatch < MappingsBatch
  attr_accessor :raw_csv
  attr_accessible :raw_csv

  def self.columns
    # Disable columns which are not used in this subclass
    super().reject { |column| ['type', 'new_url'].include?(column.name) }
  end

  has_many :entries, foreign_key: :mappings_batch_id, class_name: 'ImportBatchEntry', dependent: :delete_all

  validates :raw_csv, presence: { :if => :new_record?, message: I18n.t('mappings.import.raw_csv_empty') } # we only care about raw_csv at create-time

  after_create :create_entries

  def create_entries
    canonical_path_hashes = deduplicated_csv_rows.map { |row| Digest::SHA1.hexdigest(row.path) }
    existing_mappings = site.mappings.where(path_hash: canonical_path_hashes)

    deduplicated_csv_rows.each do |row|
      entry = ImportBatchEntry.new(path: row.path, type: row.type, new_url: row.new_url)
      entry.mappings_batch = self
      path_hash = Digest::SHA1.hexdigest(row.path)
      entry.mapping = existing_mappings.detect { |mapping| mapping.path_hash == path_hash }
      entry.save!
    end
  end

private
  def deduplicated_csv_rows
    rows_by_path = {}
    CSV.parse(raw_csv).each_with_index do |csv_row, index|
      next unless csv_row[0].starts_with?('/') || csv_row[0].starts_with?('http')

      line_number = index + 1
      row = Transition::ImportBatchRow.new(site, line_number, csv_row[0], csv_row[1])

      # If we don't yet have a row for this canonical path, or if the row we're
      # considering is 'better' than the one we have already, put this row into
      # the hash.
      # The second expression here calls the `<=>` method on ImportBatchRow,
      # which knows which of two mappings is 'better'
      if !rows_by_path.has_key?(row.path) || row > rows_by_path[row.path]
        rows_by_path[row.path] = row
      end
    end
    rows_by_path.values
  end
end
