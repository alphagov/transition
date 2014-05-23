module Transition
  module Revisionism
    class HTTPStatus
      # Probably should DRY to Mapping, but this is one-shot
      HTTP_STATUSES_TO_TYPES = {'301' => 'redirect', '410' => 'archive'}

      def self.map_to_new(old_change)
        [
          HTTP_STATUSES_TO_TYPES[old_change.first],
          HTTP_STATUSES_TO_TYPES[old_change.last]
        ]
      end

      def self.replace_with_type!
        PaperTrail::Version.find_each do |version|
          changes = YAML.load(version.object_changes)
          if changes[:http_status]
            changes[:type] = map_to_new(changes.delete(:http_status))
            version.update_attribute(:object_changes, changes)
          end
        end
      end
    end
  end
end
