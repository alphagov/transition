module FilterHelper
  def filter_option_link(site, type, options = {})
    selected = options[:selected]

    link_to filter_site_mappings_path(site),
        'class'         => "filter-option #{'filter-selected' if selected}",
        'data-toggle'   => 'dropdown',
        'role'          => 'button' do
      "#{type} <span class=\"glyphicon glyphicon-chevron-down\"></span>".html_safe
    end
  end

  def filter_remove_option_link(site, type, type_sym)
    link_to site_mappings_path(site, params.except(type_sym, :page)), title: 'Remove filter', class: 'filter-option filter-selected' do
      "<span class=\"glyphicon glyphicon-remove\"></span><span class=\"rm\">Remove</span> #{type}".html_safe
    end
  end

  def filter_by_type_path(type)
    params.except(:page).merge(type: type)
  end

  def remove_filter_by_type_path
    params.except(:page, :type)
  end

  def filtered_by_tag?(tag)
    filtered_by_tags.include?(tag)
  end

  def filtered_by_tags
    params[:tagged].present? ? params[:tagged].split(ActsAsTaggableOn.delimiter) : []
  end

  def filtered_by_tags?
    filtered_by_tags.present?
  end

  def filter_by_tag_path(tag)
    tagged = filtered_by_tags
    if tagged.include?(tag)
      params.except(:page)
    else
      tagged << tag
      params.except(:page).merge(:tagged => tagged.join(ActsAsTaggableOn.delimiter))
    end
  end

  def remove_tag_from_filter_path(tag)
    tagged = filtered_by_tags
    tagged.delete(tag)

    if tagged.empty?
      params.except(:page, :tagged)
    else
      params.except(:page).merge(:tagged => tagged.join(ActsAsTaggableOn.delimiter))
    end
  end
end
