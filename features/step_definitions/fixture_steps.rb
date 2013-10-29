Given(/^there are (\d+) organisations$/) do |n|
  n.to_i.times { create(:organisation) }
end

Given(/^there is a (.*) organisation named (.*) abbreviated (.*) with these sites:$/) do |parent, name, abbr, site_table|
  # table rows are like | awb  | http://average-white-band.gov.uk/ |
  @parent             = create(:organisation, abbr: parent)
  @organisation       = create(:organisation, title: name, abbr: abbr, parent: @parent)
  @organisation.sites = site_table.rows.map do |site_abbr, homepage|
    create(:site, abbr: site_abbr, homepage: homepage, organisation_id: @organisation.id)
  end
end

Given(/^there are these organisations:$/) do |org_table|
  # org_table is like | abbr | Title |
  org_table.rows.each do |abbr, title|
    create(:organisation, abbr: abbr, title: title)
  end
end

Given(/^there is a site called (.*) belonging to an organisation (.*) with these mappings:$/) do |site_abbr, org_abbr, mappings_table|
  # table is a | 410         | /about/corporate |                   |
  org  = create(:organisation, title: org_abbr, abbr: org_abbr)
  site = create(:site_with_default_host, organisation: org, abbr: site_abbr)

  site.mappings = mappings_table.rows.map do |http_status, path, new_url|
    create(:mapping, site: site, http_status: http_status, path: path, new_url: new_url == '' ? nil : new_url)
  end
end

Given (/^a (\d+) mapping exists for the (.+) site with the path (.*)$/) do |status, site_abbr, path|
  site = create :site_with_default_host, abbr: site_abbr
  site.mappings << create(:mapping, http_status: status, path: path)
end

Given(/^there is a mapping that has no history$/) do
  with_papertrail_disabled do
    @mapping = create :mapping, site: create(:site_with_default_host)
  end
end

Given(/^a site (.*) exists$/) do |site_abbr|
  create :site_with_default_host, abbr: site_abbr
end

Given(/^these hits exist for the Attorney General's office site:$/) do |table|
  @site = create :site_with_default_host, abbr: 'ago'
  # table is a | 410         | /    | 16/10/12 | 100   |
  table.rows.map do |status, path, hit_on, count|
    create :hit, host: @site.default_host,
                 http_status: status,
                 path: path,
                 hit_on: DateTime.strptime(hit_on, '%d/%m/%y'),
                 count: count
  end
end

Given(/^some hits exist for the Cabinet Office site$/) do
  site = create :site_with_default_host, abbr: 'cabinetoffice'
  create :hit, http_status: '410', count: 20, host: site.hosts.first, path: '/cabinetofficehit'
end

Given(/^no hits exist for the Attorney General's office site$/) do
  @site ||= create(:site_with_default_host, abbr: 'ago')
  Hit.delete_all
end

Given(/^no mapping exists for the top hit$/) do
  @site.mappings.delete_all
end
