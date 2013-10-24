module OrganisationsHelper
  def date_or_not_yet(date)
    date.nil? ? 'Not yet launched' : date.to_s(:long_ordinal)
  end

  def add_indefinite_article(noun_phrase)
    indefinite_article = starts_with_vowel?(noun_phrase) ? 'an' : 'a'
    "#{indefinite_article} #{noun_phrase}"
  end

  def starts_with_vowel?(word_or_phrase)
    'aeiou'.include?(word_or_phrase.downcase[0])
  end

  def relationship_display_name(organisation)
    return 'works with' if organisation.whitehall_type == 'Other'
    relationship_text = organisation.whitehall_type
    "is #{add_indefinite_article(relationship_text[0].downcase + relationship_text[1..-1])} of"
  end
end
