require 'digest'

class ImportedHitsFile < ActiveRecord::Base
  validates :filename,     presence: true, uniqueness: true
  validates :content_hash, presence: true
end
