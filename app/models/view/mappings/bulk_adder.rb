module View
  module Mappings
    ##
    # Load all the fields associated with a bulk adding operation
    # to avoid stuffing controllers full of fields.
    #
    # Needs a site and params to work out what should be created
    class BulkAdder < Struct.new(:site, :params, :back_to_index)
      def raw_paths
        # Efficiently match any combination of new line characters:
        #     http://stackoverflow.com/questions/10805125
        params[:paths].split(/\r?\n|\r/).select { |p| p.present? }
      end

      def canonical_paths
        raw_paths.map { |p| site.canonical_path(p) }.select { |p| p.present? }.uniq
      end
    end
  end
end
