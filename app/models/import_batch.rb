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
    CSV.parse(raw_csv).each_with_index do |csv_row, index|
      next unless csv_row[0].starts_with?('/') || csv_row[0].starts_with?('http')

      line_number = index + 1
      row = Transition::ImportBatchRow.new(site, line_number, csv_row[0], csv_row[1])

      entry = ImportBatchEntry.new(path: row.path, type: row.type, new_url: row.new_url)
      entry.mappings_batch = self
      entry.save!
    end
  end
end
