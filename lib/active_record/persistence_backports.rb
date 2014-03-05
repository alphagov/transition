require 'active_support/concern'

module ActiveRecord
  # = Active Record Persistence augmentation to backport update_columns
  module PersistenceBackports
    extend ActiveSupport::Concern

    def update_columns(attributes)
      raise ActiveRecordError, "can not update on a new record object" unless persisted?

      attributes.each_key do |key|
        raise ActiveRecordError,
              "#{key} is marked as readonly" if self.class.readonly_attributes.include?(key)
      end

      updated_count = self.class.unscoped.where(self.class.primary_key => id).update_all(attributes)

      attributes.each do |k, v|
        raw_write_attribute(k, v)
      end

      updated_count == 1
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::PersistenceBackports)
