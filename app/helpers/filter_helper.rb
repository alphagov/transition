module FilterHelper
  def filter_option_link(site, type, options = {})
    selected = options[:selected]

    link_to filter_site_mappings_path(site),
            "class" => "filter-option #{'filter-selected' if selected}",
            "data-toggle" => "dropdown",
            "role" => "button" do
      "#{type} <span class=\"glyphicon glyphicon-chevron-down\"></span>".html_safe
    end
  end

  def filter_remove_option_link(_site, type, type_sym)
    link_to site_mappings_path(permitted_params(params.except(type_sym, :page))), title: "Remove filter", class: "filter-option filter-selected" do
      "<span class=\"glyphicon glyphicon-remove\"></span><span class=\"rm\">Remove</span> #{type}".html_safe
    end
  end

  ##
  # When rendering a single filter form for a dropdown we need to pass through
  # all the other existing filter field values
  def hidden_filter_fields_except(filter, field)
    hidden_fields = (View::Mappings::Filter.fields - [field]).map do |name|
      value = filter.try(name)
      hidden_field_tag(name, value) if value.present?
    end
    hidden_fields.join("\n").html_safe
  end

  # receives params that have not been permitted (permited: false)
  def permitted_params(unpermitted_params)
    unpermitted_params.permit(
      :controller,
      :action,
      :site_id,
      :format,
      :type,
      :path_contains,
      :new_url_contains,
      :tagged,
    )
  end
end
