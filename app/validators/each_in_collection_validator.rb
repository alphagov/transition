class EachInCollectionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, collection)
    validator_class = options[:validator] || raise(ArgumentError)
    validator = validator_class.new(options.dup.merge(attributes: @attributes))

    collection.each do |value|
      validator.validate_each(record, attribute, value)
    end
  end
end
