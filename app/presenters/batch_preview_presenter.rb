class BatchPreviewPresenter
  def initialize(batch)
    @batch = batch
  end

  def redirect_count
    @batch.entries.without_existing_mappings.redirects.count
  end

  def archive_count
    @batch.entries.without_existing_mappings.archives.count
  end

  def custom_archive_url_count
    @batch.entries.with_custom_archive_urls.count
  end

  def unresolved_count
    @batch.entries.without_existing_mappings.unresolved.count
  end

  def existing_mappings_count
    @batch.entries.with_existing_mappings.count
  end

  def mappings
    @batch.entries.order(:id).limit(20)
  end
end
