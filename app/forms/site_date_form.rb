class SiteDateForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :site

  attribute "launch_date(3i)"
  attribute "launch_date(2i)"
  attribute "launch_date(1i)"

  validate :date_parts_must_be_present

  def save
    return false if invalid?

    site.update!(
      "launch_date(3i)": attributes["launch_date(3i)"],
      "launch_date(2i)": attributes["launch_date(2i)"],
      "launch_date(1i)": attributes["launch_date(1i)"],
    )

    true
  end

private

  def date_parts_must_be_present
    parts = {
      "launch_date(1i)": "year",
      "launch_date(2i)": "month",
      "launch_date(3i)": "day",
    }

    parts.each do |attribute, message|
      if attributes[attribute.to_s].blank?
        errors.add(:launch_date, "The date of transition must include a #{message}")
      end
    end
  end
end
