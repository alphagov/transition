class BatchOutcomePresenter
  def initialize(batch)
    @batch = batch
  end

  def success_message
    if updated_count.zero?
      I18n.t(
        "mappings.success.all_created",
        created: mappings_created,
        tagged_with: tagged_with(and: true),
      )
    elsif created_count.zero?
      I18n.t(
        "mappings.success.all_updated",
        updated: mappings_updated,
        tagged_with: tagged_with(and: true),
      )
    else
      I18n.t(
        "mappings.success.some_updated",
        created: mappings_created,
        updated: mappings_updated,
        tagged_with: tagged_with(all: true),
      )
    end
  end

  def analytics_event_type
    update_type = @batch.update_existing? ? "overwrite" : "ignore"
    if @batch.is_a?(BulkAddBatch)
      "bulk-add-#{@batch.type}-#{update_type}-existing"
    else
      "import-#{update_type}-existing"
    end
  end

  def affected_mapping_ids
    paths = @batch.entries_to_process.map(&:path)
    @batch.site.mappings.where(path: paths).pluck(:id)
  end

private

  def tagged_with(opts = { all: false, and: false })
    if @batch.tag_list.present?
      %(#{opts[:all] ? '. All ' : ''}#{opts[:and] ? ' and ' : ''}tagged with "#{@batch.tag_list}")
    end
  end

  def created_count
    @created_count ||= @batch.entries.without_existing_mappings.count
  end

  def updated_count
    @updated_count ||= @batch.entries_to_process.with_existing_mappings.count
  end

  def mappings_created
    "#{created_count} #{'mapping'.pluralize(created_count)} created"
  end

  def mappings_updated
    "#{updated_count} #{'mapping'.pluralize(updated_count)} updated"
  end
end
