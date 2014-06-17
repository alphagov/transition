require 'csv'

class ImportBatch < MappingsBatch
  attr_accessor :raw_csv

  def self.columns
    # Disable columns which are not used in this subclass
    super().reject { |column| ['type', 'new_url'].include?(column.name) }
  end

  validates :raw_csv, presence: { :if => :new_record?, message: I18n.t('mappings.import.raw_csv_empty') } # we only care about raw_csv at create-time

  after_create :create_entries

  def create_entries
    CSV.parse(raw_csv).each_with_index do |row|
      old_url_value = row[0].strip
      new_url_value = row[1].nil? ? nil : row[1].strip

      is_unresolved = new_url_value.nil?

      next unless old_url_value.starts_with?('/')

      entry = ImportBatchEntry.new(path: old_url_value)
      entry.type = case
      when is_unresolved then 'unresolved'
      when (new_url_value.upcase == 'TNA') then 'archive'
      else 'redirect'
      end
      entry.new_url = entry.redirect? ? new_url_value : nil
      entry.mappings_batch = self
      entry.save!
    end
  end
end
