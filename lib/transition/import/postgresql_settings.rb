module Transition
  module Import
    module PostgreSQLSettings
      def get_setting(name)
        result_row = ActiveRecord::Base.connection.execute("show #{name}").first
        result_row[name]
      end

      def set_setting(name, value)
        ActiveRecord::Base.connection.execute("set #{name}='#{value}'")
      end

      ##
      # Change a setting, do a thing, return setting to previous
      def change_settings(new_values)
        old_values = {}

        new_values.each_pair do |name, value|
          old_values[name] = get_setting(name)
          set_setting(name, value)
        end

        begin
          yield
        ensure
          old_values.each_pair do |name, value|
            set_setting(name, value)
          end
        end
      end
    end
  end
end
