module Transition
  module Import
    module CSV
      class ImportBatchRow
        include Comparable

        attr_reader :line_number, :old_value, :new_value

        def initialize(site, line_number, csv_row)
          @site = site
          @line_number = line_number
          @old_value = csv_row[0].strip
          @new_value = csv_row[1].present? ? csv_row[1].strip : nil
        end

        def ignorable?
          !data_row? || homepage?
        end

        def data_row?
          @old_value.starts_with?("/") || ::Transition::PathOrUrl.starts_with_http_scheme?(@old_value)
        end

        def type
          @type ||= if new_value && ((new_value.upcase == "TNA") || new_url_is_a_national_archives_url?) then "archive"
                    elsif new_value then "redirect"
                    else "unresolved"
                    end
        end

        def path
          @path ||= @site.canonical_path(old_value)
        end

        def homepage?
          path == ""
        end

        def new_url
          new_value if redirect?
        end

        def archive_url
          new_value if archive_with_custom_url?
        end

        def archive?
          type == "archive"
        end

        def archive_with_custom_url?
          archive? && new_value && new_url_is_a_national_archives_url?
        end

        def archive_without_custom_url?
          archive? && !archive_with_custom_url?
        end

        def redirect?
          type == "redirect"
        end

        def <=>(other)
          if path != other.path
            raise ArgumentError, "Cannot compare rows with differing paths: #{path} and: #{other.path}"
          end

          if redirect? && other.redirect?
            other.line_number <=> line_number
          elsif redirect?
            1
          elsif archive? && other.redirect?
            -1
          elsif archive_with_custom_url? && other.archive_without_custom_url?
            1
          elsif archive_without_custom_url? && other.archive_with_custom_url?
            -1
          elsif archive? && other.archive?
            other.line_number <=> line_number
          elsif archive?
            1
          else
            -1
          end
        end

      private

        def new_url_is_a_national_archives_url?
          host = Addressable::URI.parse(new_value).host
          host == NationalArchivesURLValidator::NATIONAL_ARCHIVES_HOST
        rescue Addressable::URI::InvalidURIError
          false
        end
      end
    end
  end
end
