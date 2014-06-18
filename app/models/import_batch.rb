require 'csv'

class ImportBatch < MappingsBatch
  attr_accessor :raw_csv
  attr_accessible :raw_csv

  def self.columns
    # Disable columns which are not used in this subclass
    super().reject { |column| ['type', 'new_url'].include?(column.name) }
  end

  validates :raw_csv, presence: { :if => :new_record?, message: I18n.t('mappings.import.raw_csv_empty') } # we only care about raw_csv at create-time

  after_create :create_entries

  def create_entries
    CSV.parse(raw_csv).each do |csv_row|
      next unless csv_row[0].starts_with?('/')

      row = Transition::ImportBatchRow.new(csv_row[0], csv_row[1])

      entry = ImportBatchEntry.new(path: row.path, type: row.type, new_url: row.new_url)
      entry.mappings_batch = self
      entry.save!
    end
  end
end
