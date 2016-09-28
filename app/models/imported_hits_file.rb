require 'digest'

class ImportedHitsFile < ActiveRecord::Base
  before_validation :set_content_hash

  validates :filename,     presence: true, uniqueness: true
  validates :content_hash, presence: true

  def same_on_disk?
    if File.exist?(filename)
      content_hash == Digest::SHA1.hexdigest(File.read(filename))
    else
      false
    end
  end

private

  def set_content_hash
    filename && File.exist?(filename) && (
      self.content_hash = Digest::SHA1.hexdigest(File.read(filename))
    )
  end
end
