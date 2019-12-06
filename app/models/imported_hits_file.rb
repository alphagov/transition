require "digest"

class ImportedHitsFile < ApplicationRecord
  validates :filename,     presence: true, uniqueness: true
  validates :content_hash, presence: true
end
