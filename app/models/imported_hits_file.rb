require 'digest'

class ImportedHitsFile < ActiveRecord::Base
  before_save :make_content_hash

  validates :filename,     presence: true
  validates :content_hash, presence: true

private
  def make_content_hash
    self.content_hash = Digest::SHA1.hexdigest(File.read(filename))
  end
end
