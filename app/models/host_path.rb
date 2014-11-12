##
# The set of HostPaths represents a list of paths
# we've seen and know about. It's derived from Hit data
# by +Transition::Import::HitsMappingsRelations.refresh!+
#
# It also holds a c14n'd path, which lets us update hits
# when we update mappings.
class HostPath < ActiveRecord::Base
  belongs_to :host
  belongs_to :mapping

  before_save :set_path_hash, :set_c14n_path_hash

  def set_path_hash
    self.path_hash = Digest::SHA1.hexdigest(path) if path_changed?
  end

  def set_c14n_path_hash
    self.c14n_path_hash = Digest::SHA1.hexdigest(host.site.canonical_path(path)) if path_changed?
  end
end
