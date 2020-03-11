Given(/^(.*) site with abbr (.*) launche([s|d]) on 13\/12\/12 with the following aliases:$/) do |default_host, abbr, launch_suffix, aliases|
  @site = create :site_without_host,
                 abbr: abbr,
                 homepage: "https://www.gov.uk/government/organisations/attorney-generals-office",
                 launch_date: Date.new(2012, 12, 13)

  # Have we launche*d*?
  cname_trait = launch_suffix == "d" ? :with_govuk_cname : :with_third_party_cname

  @site.hosts << create(:host, cname_trait, hostname: default_host, site: @site)
  aliases.rows.each do |hostname_row|
    @site.hosts << create(:host, hostname: hostname_row.first)
  end
end
