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

    # This callback disables the columns when fetching an instance from the database
    class_eval do
      include DisableColumns

      after_initialize :delete_disabled_columns_from_attributes
    end
  end

protected
  def delete_disabled_columns_from_attributes
    @attributes = @attributes.reject { |name| disabled_column_list.include?(name) }
  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend DisableColumns
end
