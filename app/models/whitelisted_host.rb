class WhitelistedHost < ActiveRecord::Base
  attr_accessible :hostname

  validates :hostname, presence: true
  validates :hostname, hostname: true
end
