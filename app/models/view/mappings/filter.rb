require "view/mappings/canonical_filter"

module View
  module Mappings
    ##
    # Take a site and params and apply the scopes required to
    # return a matching set of mappings.
    #
    class Filter
      attr_accessor :site, :params
      def initialize(site, params)
        @site = site
        @params = params
      end

      ##
      # Fields
      #

      def self.fields
        %i[path_contains new_url_contains tagged type sort]
      end

      def path_contains
        @path_contains ||= View::Mappings.canonical_filter(site, params[:path_contains])
      end

      def new_url_contains
        params[:new_url_contains]
      end

      def tagged
        params[:tagged]
      end

      def type
        params[:type] if Mapping::SUPPORTED_TYPES.include?(params[:type]) && !incompatible?
      end

      def sort
        params[:sort]
      end

      ##
      # Non-field helpers
      #

      def active?
        type || new_url_contains || path_contains || tagged || sort_by_hits?
      end

      def incompatible?
        %w[archive unresolved].include?(params[:type]) && new_url_contains.present?
      end

      def query
        @query ||= QueryParams.new(self)
      end

      def sort_by_hits?
        params[:sort] == "by_hits"
      end

      def tags
        tagged.present? ? tagged.split(ActsAsTaggableOn.delimiter) : []
      end

      def mappings
        unpaginated_mappings.page(params[:page])
      end

      def unpaginated_mappings
        mappings = site.mappings
          .includes(:site)
          .includes(taggings: :tag)

        mappings = mappings.redirects   if type == "redirect"
        mappings = mappings.archives    if type == "archive"
        mappings = mappings.unresolved  if type == "unresolved"
        mappings = mappings.filtered_by_path(path_contains) if path_contains.present?
        mappings = mappings.redirects.filtered_by_new_url(new_url_contains) if new_url_contains.present?
        mappings = mappings.tagged_with(tagged) if tagged.present?

        mappings.order(sort_by_hits? ? "mappings.hit_count DESC NULLS LAST" : "mappings.path")
      end

      ##
      # Handle the view bits that generate new query hashes for link_to
      class QueryParams
        def initialize(filter)
          @filter = filter
        end

        def params
          @filter.params
        end

        def with_tag(tag)
          tagged = @filter.tags
          if tagged.include?(tag)
            params.except(:page)
          else
            tagged << tag
            params.except(:page).merge(tagged: tagged.join(ActsAsTaggableOn.delimiter))
          end
        end

        def without_tag(tag)
          tagged = @filter.tags
          tagged.delete(tag)

          if tagged.empty?
            params.except(:page, :tagged)
          else
            params.except(:page).merge(tagged: tagged.join(ActsAsTaggableOn.delimiter))
          end
        end

        def with_type(type)
          params.except(:page).merge(type: type)
        end

        def without_type
          params.except(:page, :type)
        end

        def sort_by_path
          params.except(:page, :sort)
        end

        def sort_by_hits
          params.except(:page).merge(sort: "by_hits")
        end
      end
    end
  end
end
