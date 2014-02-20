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
            # Includes a row for each Old URL associated with a Document or
            # Attachment. Uses the current edition for a Document, whether it
            # is imported, draft, submitted, rejected, published or archived.
            #
            # Rows are like:
            # Old URL,New URL,Admin URL,State
            CSV.new(urls_io, headers: true).each do |row|
              next if row['Old URL'].blank?
              next unless row['State'] == 'published'

              begin
                old_uri = URI.parse(row['Old URL'])
              rescue URI::InvalidURIError => e
                Rails.logger.warn("Skipping mapping for unparseable Old URL in Whitehall URL CSV: #{row['Old URL']}")
                next
              end

              host = Host.find_by_hostname(old_uri.host)

              if host.nil?
                Rails.logger.warn("Skipping mapping for unknown host in Whitehall URL CSV: '#{old_uri.host}'")
              elsif ! host.site.managed_by_transition?
                Rails.logger.warn("Skipping mapping for a site managed by redirector in Whitehall URL CSV: '#{old_uri.host}'")
              else
                canonical_path = host.site.canonical_path(row['Old URL'])
                existing_mapping = host.site.mappings.where(path_hash: path_hash(canonical_path)).first

                if existing_mapping
                    if existing_mapping.http_status == '410' ||
                        ! existing_mapping.edited_by_human?
                      existing_mapping.update_attributes(new_url: row['New URL'], http_status: '301')
                    end
                else
                  host.site.mappings.create(path: canonical_path, new_url: row['New URL'], http_status: '301')
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
          original_controller_info = ::PaperTrail.controller_info
          ::PaperTrail.whodunnit = user.name
          ::PaperTrail.controller_info = { user_id: user.id }
          begin
            yield
          ensure
            ::PaperTrail.whodunnit = original_whodunnit
            ::PaperTrail.controller_info = original_controller_info
          end
        end
      end
    end
  end
end
