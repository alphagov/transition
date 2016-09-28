module ApplicationHelper
  def crumb_li(title, path, active)
    options = {}
    options[:class] = 'active' if active

    content_tag :li, nil, options do
      active ? title : link_to(title, path)
    end
  end

  def anchor(text, name)
    content_tag :a, text, id: name, name: name
  end

  def past_first_page?
    params[:page] && params[:page].to_i > 1
  end

  def first_page?
    !past_first_page?
  end

  def organisation_with_abbreviation(org)
    if org.abbreviation.present?
      "#{org.title} (#{org.abbreviation})"
    else
      org.title
    end
  end
end
