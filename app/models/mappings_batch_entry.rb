class MappingsBatchEntry < ApplicationRecord
  self.inheritance_column = :klass

  belongs_to :mappings_batch
  belongs_to :mapping

  scope :with_existing_mappings, -> { where("mapping_id is not null") }
  scope :without_existing_mappings, -> { where("mapping_id is null") }
  scope :processed, -> { where(processed: true) }

  def old_url
    "http://#{mappings_batch.site.default_host.hostname}#{path}"
  end

  def tags
    mappings_batch.tag_list.split(",")
  end
end
