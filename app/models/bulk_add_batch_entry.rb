class BulkAddBatchEntry < MappingsBatchEntry
  def self.columns
    # Disable columns which are not used in this subclass
    super().reject { |column| %w[type new_url].include?(column.name) }
  end

  delegate :new_url, :type, :redirect?, to: :mappings_batch
end
