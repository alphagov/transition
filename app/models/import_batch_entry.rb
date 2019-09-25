class ImportBatchEntry < MappingsBatchEntry
  scope :with_type,  ->(type) { where(type: type) }
  scope :redirects,  -> { with_type("redirect") }
  scope :archives,   -> { with_type("archive") }
  scope :unresolved, -> { with_type("unresolved") }

  scope :with_custom_archive_urls, -> { archives.where("archive_url IS NOT NULL") }

  def redirect?
    type == "redirect"
  end
end
