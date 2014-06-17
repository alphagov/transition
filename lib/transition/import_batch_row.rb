module Transition
  class ImportBatchRow
    attr_reader :old_value, :new_value

    def initialize(old_value, new_value)
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
      old_value
    end

    def new_url
      if type == 'redirect'
        new_value
      end
    end
  end
end
