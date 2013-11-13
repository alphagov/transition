require 'csv'

module Transition
  module Import
    class WhitehallDocumentURLs
      def from_csv(urls_io)
        # Rows are like:
        # Old Url,New Url,Status,Slug,Admin Url,State
        CSV.new(urls_io, headers: true).each do |row|
          old_uri = URI.parse(row[0])
          host = Host.find_by_hostname(old_uri.host)

          if host
            canonical_path = host.site.canonical_path_from_url(row[0])
            host.site.mappings.create!(path: canonical_path, new_url: row[1], http_status: '301')
          end
        end
      end
    end
  end
end
