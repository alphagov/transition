module ApplicationHelper
  ##
  # Render a bootstrap style-compatible breadcrumb. Knows about our models.
  # Pass in the current significant model to generate, or nothing if you're
  # at the top level.
  def breadcrumb(model = nil)
    content_tag(:ul, nil, class: 'breadcrumb') do
      crumb_li('Organisations', organisations_path, model == nil) + list_items_for(model)
    end
  end

  def list_items_for(model, active = true)
    case model
    when Organisation
      crumb_li(model.title, organisation_path(model), active)
    when Site
      list_items_for(model.organisation, false) + crumb_li("#{model.abbr} Mappings", site_mappings_path(model), active)
    when Mapping
      list_items_for(model.site, false) + crumb_li('Mapping', '#{foobar}', true)
    end
  end

  def crumb_li(title, path, active)
    options = {}
    options[:class] = 'active' if active

    content_tag :li, nil, options do
      active ? title : link_to(title, path) + content_tag(:span, nil, class: 'divider' )
    end
  end

  KNOWN_ABBRS = {
    'http' => 'HTTP',
    'Http' => 'HTTP',
    'url' => 'URL',
    'Url' => 'URL'
  }

  ##
  # Help avoid abominations like 'Http status' or 'Archive url' without resorting to the nuclear
  # +ActiveSupport::Inflector#acronym+
  def titleize_known_abbr(str)
    all_abbrs = Regexp.new("(#{KNOWN_ABBRS.keys.map(&:to_s).join('|')})")
    str.titleize.gsub(all_abbrs, KNOWN_ABBRS)
  end
end
