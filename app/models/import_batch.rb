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
    # Default entries in the hash to empty array
    # http://stackoverflow.com/a/2552946/3726525
    rows_by_path = Hash.new { |hash, key| hash[key] = [] }
    CSV.parse(raw_csv).each_with_index do |csv_row, index|
      next unless csv_row[0].starts_with?('/') || csv_row[0].starts_with?('http')

      line_number = index + 1
      row = Transition::ImportBatchRow.new(site, line_number, csv_row[0], csv_row[1])
      rows_by_path[row.path] << row
    end
    # The rows in each array in the hash will be in insertion order.
    # Calling sort on each array calls the `<=>` method on ImportBatchRow,
    # which knows which of two mappings is 'better'. The outcome is that the
    # last entry in the array is the 'best' row for a path.
    rows_by_path.values.map { |rows_for_a_path| rows_for_a_path.sort.last }
  end
end
