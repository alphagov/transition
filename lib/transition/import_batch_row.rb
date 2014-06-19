module Transition
  class ImportBatchRow
    include Comparable

    attr_reader :line_number, :old_value, :new_value

    def initialize(site, line_number, old_value, new_value)
      @site = site
      @line_number = line_number
      @old_value = old_value.blank? ? nil : old_value.strip
      @new_value = new_value.blank? ? nil : new_value.strip
    end

    def type
      case
      when new_value && (new_value.upcase == 'TNA') then 'archive'
      when new_value then 'redirect'
      else 'unresolved'
      end
    end

    def path
      @site.canonical_path(old_value)
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
