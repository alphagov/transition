Given(/^there are (\d+) organisations$/) do |n|
  n.to_i.times { FactoryGirl.create(:organisation) }
end

Given(/^there is an organisation named (.*) abbreviated (.*) with these sites:$/) do |name, abbr, site_table|
  # table rows are like | awb  | http://average-white-band.gov.uk/ |
  org = FactoryGirl.create(:organisation,
    title: name,
    abbr: abbr
  )
  org.sites = site_table.rows.map do |site_abbr, homepage|
    FactoryGirl.create(:site, abbr: site_abbr, homepage: homepage, organisation_id: org.id)
  end
end

Given(/^there are these organisations:$/) do |org_table|
  # org_table is like | abbr | Title |
  org_table.rows.each do |abbr, title|
    FactoryGirl.create(:organisation, abbr: abbr, title: title)
  end
end
