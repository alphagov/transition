module FilterHelper
  def filter_option_link(site, type)
    link_to filter_site_mappings_path(@site),
        'class'         => 'filter-option',
        'data-toggle' => 'dropdown',
        'role'          => 'button',
        'data-target' => "filter-by-#{type}" do
      "#{type.titleize} <span class=\"glyphicon glyphicon-chevron-down\"></span>".html_safe
    end
  end
end
