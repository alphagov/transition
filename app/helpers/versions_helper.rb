#encoding: utf-8

module VersionsHelper
  def value_or_blank(value)
    value.blank? ? '<blank>' : value
  end

  def friendly_changeset_title_for_type(value)
    case value
    when 'redirect'
      'Switched mapping to a Redirect'
    when 'archive'
      'Switched mapping to an Archive'
    when 'unresolved'
      'Switched mapping to Unresolved'
    else
      'Switched mapping type'
    end
  end

  def friendly_changeset_title(changeset)
    if changeset['id']
      'Mapping created'
    elsif changeset['type']
      friendly_changeset_title_for_type(changeset['type'][1])
    elsif changeset.length == 1
      first = changeset.first[0].titleize
      first = 'Alternative Archive URL' if first == 'Archive URL'
      "#{first} updated"
    else
      "Multiple properties updated"
    end
  end

  def friendly_field_name(field)
    case field
    when 'archive_url'
      'Alternative Archive URL'
    else
      field.titleize
    end
  end

  def friendly_changeset_old_to_new(field, change)
    old_value = value_or_blank(change[0])
    new_value = value_or_blank(change[1])

    if field == 'type'
      old_value = change[0].titleize unless change[0].blank?
      new_value = change[1].titleize unless change[1].blank?
    end

    "#{old_value} → #{new_value}"
  end
end
