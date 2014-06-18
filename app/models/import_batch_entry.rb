class ImportBatchEntry < MappingsBatchEntry
  attr_accessible :type, :new_url

  scope :with_type, -> type { where(type: type) }
  scope :redirects,   with_type('redirect')
  scope :archives,    with_type('archive')
  scope :unresolved,  with_type('unresolved')

  def redirect?
    type == 'redirect'
  end
end
