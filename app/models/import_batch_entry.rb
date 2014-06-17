class ImportBatchEntry < MappingsBatchEntry
  attr_accessible :type, :new_url

  def redirect?
    type == 'redirect'
  end
end
