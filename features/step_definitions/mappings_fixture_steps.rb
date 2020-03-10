Given(/^a mapping exists for the site ukba$/) do
  @site = create :site, abbr: "ukba"
  @mapping = create(:mapping)
  @site.mappings = [@mapping]
end

Given(/^a site "([^"]*)" exists with mappings with lots of tags$/) do |site_abbr|
  @site = create :site, abbr: site_abbr
  [10, 11].each do |tag_count|
    # The site dashboard only displays the 10 most popular tags. If we make it
    # so that there are 11 tags on this site, 10 of which are predictably more
    # popular, and should be displayed, but the eleventh one should be excluded.
    #
    # To do this, we create:
    #   a mapping with tags:        1, 2, 3, ... 9, 10
    #   a second mapping with tags: 1, 2, 3, ... 9, 10, 11
    @site.mappings << create(:archived).tap do |mapping|
      mapping.tag_list = (1..tag_count.to_i).to_a.join(", ")
    end
  end
end

Given(/^a site "([^"]*)" exists with these tagged mappings:$/) do |site_abbr, tagged_paths|
  @site = create :site, abbr: site_abbr

  # tagged_paths.hashes.keys # => [:path, :tags]
  tagged_paths.hashes.each do |row|
    @site.mappings << create(:archived, path: row[:path]).tap do |mapping|
      mapping.tag_list = row[:tags]
    end
  end
end

Given(/^a site has lots of mappings(?: and no hits)?$/) do
  @site = create :site
  3.times { create :mapping, site: @site }
end

Given(/^a site has lots of mappings and lots of hits$/) do
  @site = create :site, :with_mappings_and_hits
  Transition::Import::DailyHitTotals.from_hits!
end
