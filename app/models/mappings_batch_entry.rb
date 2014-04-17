class MappingsBatchEntry < ActiveRecord::Base
  belongs_to :mappings_batch
  belongs_to :mapping
end
