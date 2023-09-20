require "./lib/transition/import/revert_entirely_unsafe"

class DeleteSiteForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :abbr
  attribute :abbr_confirmation

  validate :confirmation_matches

  def save
    return false if invalid?

    Transition::Import::RevertEntirelyUnsafe::RevertSite.new(site).revert_all_data!
    true
  end

private

  def site
    Site.find_by(abbr:)
  end

  def confirmation_matches
    if abbr_confirmation != abbr
      errors.add(:abbr_confirmation, "The confirmation did not match")
    end
  end
end
