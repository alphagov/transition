module NavigationHelper
  def navigation_items
    return [] unless current_user

    items = []

    if current_user.own_organisation
      items << { text: organisation_with_abbreviation(current_user.own_organisation), href: organisation_path(current_user.own_organisation) }
    end

    if current_user.gds_editor?
      items << { text: "Universal analytics", href: hits_path }

      items << { text: "Leaderboard", href: leaderboard_path }
    end

    if current_user.admin?
      items << { text: "Redirection whitelist", href: admin_whitelisted_hosts_path }

      items << { text: "Hosts", href: hosts_path }
    end

    items << { text: "Glossary", href: glossary_index_path }

    items.each { |item| item[:active] = current_page?(item[:href]) }
  end
end
