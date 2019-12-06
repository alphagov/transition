##
# The set of HostPaths represents a list of paths
# we've seen and know about. It's derived from Hit data
# by +Transition::Import::HitsMappingsRelations.refresh!+
#
# It also holds a canonical_path, which lets us update hits
# when we update mappings.
class HostPath < ApplicationRecord
  belongs_to :host
  belongs_to :mapping

  before_save :set_canonical_path

  def set_canonical_path
    self.canonical_path = host.site.canonical_path(path) if path_changed?
  end
end
