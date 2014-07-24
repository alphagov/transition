module DisableColumns
  # Disable columns which are not used in this subclass
  def disable_columns(columns)
    instance_eval do
      cattr_accessor :disabled_column_list do
        columns.map(&:to_s)
      end

      # Overriding this method disables the columns when instantiating
      def columns
        super().reject { |column| disabled_column_list.include?(column.name) }
      end
    end
  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend DisableColumns
end
