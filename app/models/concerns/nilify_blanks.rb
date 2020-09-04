module NilifyBlanks
  extend ActiveSupport::Concern

  included do
    before_save :nilify_blanks
  end

  def nilify_blanks
    attributes.each do |column, value|
      self[column] = nil if value.blank?
    end
  end
end
