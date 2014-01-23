#encoding: utf-8

module VersionsHelper
  def value_or_blank(value)
    value.blank? ? '<blank>' : value
  end

  def friendly_changeset_title(changeset)
    if changeset['id']
      "Mapping created"
    elsif changeset['http_status']
      if changeset['http_status'][0] == '410'
        "Switched mapping to a Redirect"
      else
        "Switched mapping to an Archive"
      end
    elsif changeset.length == 1
      first = changeset.first[0].titleize
      first = "Alternative Archive URL" if first == "Archive URL"
      "#{first} updated"
    else
      "Multiple properties updated"
    end
  end

  def friendly_changeset_field(field)
    if field == "http_status"
      "Type"
    elsif field == "archive_url"
      "Alternative Archive URL"
    else
      field.titleize
    end
  end

  def friendly_changeset_values(field, change)

    if field == "http_status"
      old_value = change[0].blank? ? value_or_blank(change[0]) : http_status_name(change[0])
      new_value = change[1].blank? ? value_or_blank(change[1]) : http_status_name(change[1])
    else
      old_value = value_or_blank(change[0])
      new_value = value_or_blank(change[1])
    end

    "#{old_value} → #{new_value}"
  end

end
