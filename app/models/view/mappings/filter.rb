module View
  module Mappings
    # Represent the ways a user can filter some mappings
    class Filter < Struct.new(:site, :params)
      def incompatible?
        type == 'archive' && new_url_contains.present?
      end

      def type
        params[:type]
      end

      def new_url_contains
        params[:new_url_contains]
      end

      def path_contains
        @path_contains ||= View::Mappings::canonical_filter(site, params[:path_contains])

        # # TODO: move this into canonical_filter
        # # Canonicalisation removes trailing slashes, which in this case
        # # can be an important part of the search string. Put them back.
        # if params[:path_contains].end_with?('/')
        #   @path_contains = @path_contains + '/'
        # end
      end

      def tagged
        params[:tagged]
      end

      def active?
        type || new_url_contains || path_contains || tagged
      end

      def sort_by_hits?
        params[:sort] == 'by_hits'
      end

      def mappings
        @mappings = site.mappings.page(params[:page])

        @mappings = @mappings.redirects if type == 'redirect'
        @mappings = @mappings.archives  if type == 'archive'
        @mappings = @mappings.filtered_by_path(path_contains) if path_contains.present?
        @mappings = @mappings.redirects.filtered_by_new_url(new_url_contains) if new_url_contains.present?
        @mappings = @mappings.tagged_with(tagged) if tagged.present?

        sort_by_hits? ? @mappings.with_hit_count.order('hit_count DESC') : @mappings
      end
    end
  end
end
