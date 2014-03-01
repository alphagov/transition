module FilterHelper
  def filter_option_link(site, type)
    link_to filter_site_mappings_path(@site),
        'class'         => 'filter-option',
        'data-toggle'   => 'dropdown',
        'role'          => 'button' do
      "#{type} <span class=\"glyphicon glyphicon-chevron-down\"></span>".html_safe
    end
  end

  def filter_remove_option_link(site, type, type_sym)
    link_to site_mappings_path(@site, params.except(type_sym, :page)), class: 'filter-option filter-selected' do
      "<span class=\"glyphicon glyphicon-remove\"></span> #{type}".html_safe
    end
  end

end
