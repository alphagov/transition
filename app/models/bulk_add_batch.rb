class BulkAddBatch < MappingsBatch
  attr_accessor :paths # a virtual attribute to then use for creating entries

  validates :paths,
            presence: {
              if: :new_record?, # we only care about paths at create-time
              message: I18n.t("mappings.paths_empty"),
            }
  validates :paths, old_urls_are_for_site: true
  validates :canonical_paths,
            presence: {
              if: :new_record?,
              message: I18n.t("mappings.paths_empty"),
            }
  validates :type, inclusion: { in: Mapping::SUPPORTED_TYPES }
  with_options if: :redirect? do |redirect|
    redirect.validates :new_url, presence: { message: I18n.t("mappings.bulk.new_url_invalid") }
    redirect.validates :new_url, length: { maximum: 2048 }
    redirect.validates :new_url, non_blank_url: { message: I18n.t("mappings.bulk.new_url_invalid") }
    redirect.validates :new_url,
                       host_in_whitelist: {
                         message: I18n.t("mappings.bulk.new_url_must_be_on_whitelist"),
                       }
    redirect.validates :new_url,
                       not_a_national_archives_url: {
                         message: I18n.t("mappings.bulk.new_url_must_not_be_on_tna"),
                       }
  end

  before_validation :fill_in_scheme
  after_create :create_entries

  def fill_in_scheme
    self.new_url = Mapping.ensure_url(new_url)
  end

  def redirect?
    type == "redirect"
  end

  # called after_create, so in the same transaction
  def create_entries
    existing_mappings = site.mappings.where(path: canonical_paths)

    records = canonical_paths.map do |canonical_path|
      entry = BulkAddBatchEntry.new(path: canonical_path)
      entry.mappings_batch = self
      entry.mapping = existing_mappings.detect { |mapping| mapping.path == canonical_path }
      entry
    end

    BulkAddBatchEntry.import(records, validate: false)
  end

  def verb
    "add"
  end

private

  def canonical_paths
    @canonical_paths ||= begin
      return [] if paths.blank?

      paths.map { |p| site.canonical_path(p) }.select(&:present?).uniq
    end
  end
end
