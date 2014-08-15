require 'digest'

class ImportedHitsFile < ActiveRecord::Base
  before_validation :set_content_hash

  validates :filename,     presence: true
  validates :content_hash, presence: true

  def same_on_disk?
    content_hash == Digest::SHA1.hexdigest(File.read(filename))
  end

private
  def set_content_hash
    filename && (
      self.content_hash = Digest::SHA1.hexdigest(File.read(filename)))
  end
end
