class MappingsBatchEntry < ActiveRecord::Base
  belongs_to :mappings_batch
  belongs_to :mapping

  attr_accessible :path

  scope :with_existing_mappings, where('mapping_id is not null')
  scope :without_existing_mappings, where('mapping_id is null')
  scope :processed, where(processed: true)

  def old_url
    "http://#{mappings_batch.site.default_host.hostname}#{self.path}"
  end

  def new_url
    mappings_batch.new_url
  end

  def type
    mappings_batch.type
  end

  def http_status
    mappings_batch.http_status
  end

  def tags
    mappings_batch.tag_list.split(',')
  end

  def tag_list
    mappings_batch.tag_list.split(',')
  end

  def redirect?
    mappings_batch.redirect?
  end
end
