module View
  module Mappings
    ##
    # Take a site and params and apply the scopes required to
    # return a matching set of mappings.
    #
    class Filter < Struct.new(:site, :params)
      def incompatible?
        type == 'archive' && new_url_contains.present?
      end

      def type
        params[:type] if Mapping::SUPPORTED_TYPES.include?(params[:type])
      end

      def new_url_contains
        params[:new_url_contains]
      end

      def path_contains
        @path_contains ||= View::Mappings::canonical_filter(site, params[:path_contains])
      end

      def tagged
        params[:tagged]
      end

      def tags
        tagged.present? ? tagged.split(ActsAsTaggableOn.delimiter) : []
      end

      def query
        @query ||= Query.new(self)
      end

      def active?
        type || new_url_contains || path_contains || tagged || sort_by_hits?
      end

      def sort_by_hits?
        params[:sort] == 'by_hits'
      end

      def mappings
        mappings = site.mappings.page(params[:page])

        mappings = mappings.redirects if type == 'redirect'
        mappings = mappings.archives  if type == 'archive'
        mappings = mappings.filtered_by_path(path_contains) if path_contains.present?
        mappings = mappings.redirects.filtered_by_new_url(new_url_contains) if new_url_contains.present?
        mappings = mappings.tagged_with(tagged) if tagged.present?

        sort_by_hits? ? mappings.with_hit_count.order('hit_count DESC') : mappings.order(:path)
      end

      ##
      # Handle the view bits that generate new query hashes for link_to
      class Query
        def initialize(filter)
          @filter = filter
        end

        def params
          @filter.params
        end

        def add_tag(tag)
          tagged = @filter.tags
          if tagged.include?(tag)
            params.except(:page)
          else
            tagged << tag
            params.except(:page).merge(:tagged => tagged.join(ActsAsTaggableOn.delimiter))
          end
        end

        def remove_tag(tag)
          tagged = @filter.tags
          tagged.delete(tag)

          if tagged.empty?
            params.except(:page, :tagged)
          else
            params.except(:page).merge(:tagged => tagged.join(ActsAsTaggableOn.delimiter))
          end
        end

        def by_type(type)
          params.except(:page).merge(type: type)
        end
      end
    end
  end
end
