class ImportBatch < MappingsBatch

  def self.columns
    # Disable columns which are not used in this subclass
    super().reject { |column| ['type', 'new_url'].include?(column.name) }
  end
end
