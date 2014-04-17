class MappingsBatchEntry < ActiveRecord::Base
  belongs_to :mappings_batch
  belongs_to :mapping

  attr_accessible :path

  scope :with_existing_mappings, where('mapping_id is not null')

  def old_url
    "http://#{mappings_batch.site.default_host.hostname}#{self.path}"
  end
end
