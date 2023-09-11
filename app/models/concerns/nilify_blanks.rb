module NilifyBlanks
  extend ActiveSupport::Concern

  included do
    before_save :nilify_blanks
  end

  def nilify_blanks
    attributes.each do |column, value|
      next if nilify_except.include?(column.to_sym)

      self[column] = nil if value.blank?
    end
  end

private

  def nilify_except
    []
  end
end
