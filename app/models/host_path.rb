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
end
