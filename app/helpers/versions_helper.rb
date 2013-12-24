#encoding: utf-8

module VersionsHelper
  def value_or_blank(value)
    value.blank? ? content_tag(:span, class: 'blank') { '<blank>' } : value
  end

  def changeset_title(version)
    if version.changeset['http_status']
      if version.changeset['http_status'][0] == '410'
        "Archive → Redirect"
      else
        "Redirect → Archive"
      end
    elsif version.changeset.length == 1
      first = version.changeset.first[0].titleize
      first = "Alternative Archive URL" if first == "Archive URL"
      "#{first} updated"
    else
      "Multiple properties updated"
    end
  end

end
