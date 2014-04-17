class MappingsBatch < ActiveRecord::Base
  belongs_to :user
  belongs_to :site
  has_many :mappings_batch_entries
end
