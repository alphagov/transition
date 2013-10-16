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
      title, mapping_path = model.persisted? ?
        ['Mapping', edit_site_mapping_path(model.site, model)] :
        ['New mapping', '']
      list_items_for(model.site, false) + crumb_li(title, mapping_path, active)
    when Hit
      list_items_for(model.host.site.organisation, false) + crumb_li("#{model.host.site.abbr} Hits", '#', true)
    when Version
      list_items_for(model.item, false) + crumb_li('History', '#', true)
    end
  end

  def crumb_li(title, path, active)
    options = {}
    options[:class] = 'active' if active

    content_tag :li, nil, options do
      active ? title : link_to(title, path) + content_tag(:span, nil, class: 'divider' )
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
end
