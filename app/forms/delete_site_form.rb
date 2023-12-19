require "./lib/transition/import/revert_entirely_unsafe"

class DeleteSiteForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id
  attribute :hostname_confirmation

  validate :confirmation_matches

  def save
    return false if invalid?

    Transition::Import::RevertEntirelyUnsafe::RevertSite.new(site).revert_all_data!
    true
  end

private

  def site
    Site.find_by(id:)
  end

  def confirmation_matches
    if hostname_confirmation != site.default_host.hostname
      errors.add(:hostname_confirmation, "The confirmation did not match")
    end
  end
end
