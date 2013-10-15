class Host < ActiveRecord::Base
  belongs_to :site
  has_many :hits
end
