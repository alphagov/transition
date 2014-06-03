class WhitelistedHost < ActiveRecord::Base
  attr_accessible :hostname

  has_paper_trail

  before_save :ensure_papertrail_user_config

  validates :hostname, presence: true
  validates :hostname, hostname: true
  validates :hostname, uniqueness: { message: 'is already in the list' }

  def ensure_papertrail_user_config
    Transition::History.ensure_user!
  end
end
