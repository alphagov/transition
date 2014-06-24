class WhitelistedHost < ActiveRecord::Base
  has_paper_trail

  before_save :ensure_papertrail_user_config

  validates :hostname, presence: true
  validates :hostname, hostname: true
  validates :hostname, uniqueness: { message: 'is already in the list' }
  validate :hostname_is_not_automatically_allowed_anyway

  def ensure_papertrail_user_config
    Transition::History.ensure_user!
  end

  def hostname_is_not_automatically_allowed_anyway
    return if hostname.nil?
    if hostname.end_with?('.gov.uk') || hostname.end_with?('.mod.uk')
      errors.add(:hostname, 'cannot end in .gov.uk or .mod.uk - these are automatically whitelisted')
    end
  end
end
