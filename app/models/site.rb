class Site < ActiveRecord::Base
  belongs_to :organisation

  has_many :hosts
  has_many :mappings

  def to_param
    abbr
  end
end
