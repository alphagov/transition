require "csv"
require "transition/history"

module Transition
  module Import
    module Whitehall
      class MappingsCSV
        def initialize(user)
          @user = user
        end

        def from_csv(urls_io)
          Transition::History.as_a_user(@user) do
            # Includes a row for each Old URL associated with a Document or
            # Attachment. Uses the current edition for a Document, whether it
            # is imported, draft, submitted, rejected, published or archived.
            #
            # Rows are like:
            # Old URL,New URL,Admin URL,State
            ::CSV.new(urls_io, headers: true).each do |row|
              next if row["Old URL"].blank?
              next unless row["State"] == "published"

              begin
                old_uri = Addressable::URI.parse(row["Old URL"])
              rescue Addressable::URI::InvalidURIError
                Rails.logger.warn("Skipping mapping for unparseable Old URL in Whitehall URL CSV: #{row['Old URL']}")
                next
              end

              host = hosts_by_hostname[old_uri.host]

              if host.nil?
                Rails.logger.warn("Skipping mapping for unknown host in Whitehall URL CSV: '#{old_uri.host}'")
              else
                canonical_path = host.site.canonical_path(row["Old URL"])
                existing_mapping = host.site.mappings.where(path: canonical_path).first

                if existing_mapping
                  if existing_mapping.type == "archive" ||
                      existing_mapping.type == "unresolved" ||
                      !existing_mapping.edited_by_human?
                    existing_mapping.update!(new_url: row["New URL"], type: "redirect")
                  end
                else
                  host.site.mappings.create!(path: canonical_path, new_url: row["New URL"], type: "redirect")
                end
              end
            end
          end
        end

        def hosts_by_hostname
          @hosts_by_hostname ||= Host.all.inject({}) { |accumulator, host| accumulator.merge(host.hostname => host) }
        end
      end
    end
  end
end
