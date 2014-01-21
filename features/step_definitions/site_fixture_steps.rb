And(/^(.*) site with abbr (.*) launche(?:[s|d]) on 13\/12\/12 with the following aliases:$/) do |default_host, abbr, aliases|
  @site = create :site_without_host,
                 abbr: abbr,
                 launch_date: Date.new(2012, 12, 13)

  @site.hosts << create(:host, hostname: default_host)
  aliases.rows.each do |hostname|
    @site.hosts << create(:host, hostname: hostname)
  end
end
