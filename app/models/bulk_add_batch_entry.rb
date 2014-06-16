class BulkAddBatchEntry < MappingsBatchEntry
  def self.columns
    # Disable columns which are not used in this subclass
    super().reject { |column| ['type', 'new_url'].include?(column.name) }
  end

  def new_url
    mappings_batch.new_url
  end

  def type
    mappings_batch.type
  end

  def redirect?
    mappings_batch.redirect?
  end
end
