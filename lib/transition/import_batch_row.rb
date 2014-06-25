module Transition
  class ImportBatchRow
    include Comparable

    attr_reader :line_number, :old_value, :new_value

    def initialize(site, line_number, csv_row)
      @site = site
      @line_number = line_number
      @old_value = csv_row[0].strip
      @new_value = csv_row[1].present? ? csv_row[1].strip : nil
    end

    def data_row?
      @old_value.starts_with?('/') || @old_value.starts_with?('http')
    end

    def type
      @_type ||= case
                 when new_value && (new_value.upcase == 'TNA') then 'archive'
                 when new_value then 'redirect'
                 else 'unresolved'
                 end
    end

    def path
      @_path ||= @site.canonical_path(old_value)
    end

    def new_url
      if type == 'redirect'
        new_value
      end
    end

    def archive?
      type == 'archive'
    end

    def redirect?
      type == 'redirect'
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
      elsif archive?
        1
      else
        -1
      end
    end
  end
end
