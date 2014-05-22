#encoding: utf-8

module VersionsHelper
  def value_or_blank(value)
    value.blank? ? '<blank>' : value
  end

  # We will always have old versions in the database which record changes to the
  # http_status column on mappings, and so will always need to display those
  # versions as well as displaying changes to the new type column. We should not
  # have any versions which record changes to both at the same time, because
  # we have told PaperTrail to skip the http_status field at the same time as
  # adding the type column.
  def friendly_changeset_title_for_type(changeset)
    if changeset['type']
      new_value = changeset['type'][1]
    elsif changeset['http_status']
      new_value = changeset['http_status'][1]
    end

    if ['301', 'redirect'].include? new_value
      'Switched mapping to a Redirect'
    elsif ['410', 'archive'].include? new_value
      'Switched mapping to an Archive'
    else
      'Switched mapping type'
    end
  end

  def friendly_changeset_title(changeset)
    if changeset['id']
      'Mapping created'
    elsif changeset['type'] || changeset['http_status']
      friendly_changeset_title_for_type(changeset)
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
    when 'http_status'
      'Type'
    when 'archive_url'
      'Alternative Archive URL'
    else
      field.titleize
    end
  end

  def http_status_name(http_status)
    if http_status == '301'
      'Redirect'
    elsif http_status == '410'
      'Archive'
    end
  end

  def friendly_changeset_old_to_new(field, change)
    old_value = value_or_blank(change[0])
    new_value = value_or_blank(change[1])

    if field == 'type'
      old_value = change[0].titleize unless change[0].blank?
      new_value = change[1].titleize unless change[1].blank?
    elsif field == 'http_status'
      old_value = http_status_name(change[0]) unless change[0].blank?
      new_value = http_status_name(change[1]) unless change[1].blank?
    end

    "#{old_value} → #{new_value}"
  end
end
