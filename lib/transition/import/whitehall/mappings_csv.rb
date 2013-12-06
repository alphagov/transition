require 'csv'

module Transition
  module Import
    module Whitehall
      class MappingsCSV
        def initialize(user)
          @user = user
        end

        def from_csv(urls_io)
          as_a_user(@user) do
            # The structure of the CSV is:
            #
            # For every artefact in Whitehall
            #   For each edition (in any state)
            #     if the artefact has any Old URLs
            #       include a line per Old URL
            #     else
            #       include a single line
            #
            # Where an 'artefact' is one of:
            #   document
            #   attachment
            #   people
            #   policy advisory groups
            #   policy teams
            #   roles
            #   organisations
            #   corporate information pages
            #
            # Rows are like:
            # Old Url,New Url,Status,Slug,Admin Url,State
            CSV.new(urls_io, headers: true).each do |row|
              next if row['Old Url'].blank?
              next unless row['State'] == 'published'

              begin
                old_uri = URI.parse(row['Old Url'])
              rescue URI::InvalidURIError => e
                Rails.logger.warn("Skipping mapping for unparseable Old Url in Whitehall URL CSV: #{row['Old Url']}")
                next
              end

              host = Host.find_by_hostname(old_uri.host)

              if host.nil?
                Rails.logger.warn("Skipping mapping for unknown host in Whitehall URL CSV: '#{old_uri.host}'")
              elsif ! host.site.managed_by_transition?
                Rails.logger.warn("Skipping mapping for a site managed by redirector in Whitehall URL CSV: '#{old_uri.host}'")
              else
                canonical_path = host.site.canonical_path_from_url(row['Old Url'])
                existing_mapping = host.site.mappings.where(path_hash: path_hash(canonical_path)).first

                unless existing_mapping && existing_mapping.edited_by_human?
                  if existing_mapping
                    existing_mapping.update_attributes(new_url: row['New Url'], http_status: '301')
                  else
                    host.site.mappings.create(path: canonical_path, new_url: row['New Url'], http_status: '301')
                  end
                end
              end
            end
          end
        end

        def path_hash(canonical_path)
          Digest::SHA1.hexdigest(canonical_path)
        end

        def as_a_user(user)
          original_whodunnit = ::PaperTrail.whodunnit
          ::PaperTrail.whodunnit = user
          begin
            yield
          ensure
            ::PaperTrail.whodunnit = original_whodunnit
          end
        end
      end
    end
  end
end
