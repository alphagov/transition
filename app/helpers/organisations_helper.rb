module OrganisationsHelper
  def date_or_not_yet(date)
    date.nil? ? 'Not yet launched' : date.to_s(:long_ordinal)
  end
end
