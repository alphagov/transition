module OrganisationsHelper
  def date_or_not_yet(date)
    date.nil? ? "No date set" : (I18n.l date, format: :govuk_date)
  end

  def add_indefinite_article(noun_phrase)
    indefinite_article = starts_with_vowel?(noun_phrase) ? "an" : "a"
    "#{indefinite_article} #{noun_phrase}"
  end

  def starts_with_vowel?(word_or_phrase)
    "aeiou".include?(word_or_phrase.downcase[0])
  end

  def relationship_display_name(organisation)
    return "works with" if organisation.whitehall_type == "Other"

    relationship_text = organisation.whitehall_type
    "is #{add_indefinite_article(relationship_text[0].downcase + relationship_text[1..-1])} of"
  end

  def links_to_all_parents(organisation)
    all_links = organisation.parent_organisations.map do |parent|
      link_to parent.title, organisation_path(parent)
    end
    all_links.to_sentence(last_word_connector: " and ").html_safe
  end
end
