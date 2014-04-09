Given(/^a mapping exists for the site ukba$/) do
  @site = create :site, abbr: 'ukba'
  @mapping = create(:mapping)
  @site.mappings = [@mapping]
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

Given(/^a site has lots of mappings$/) do
  @site = create :site
  3.times { create :mapping, site: @site }
end

Given(/^a site has lots of mappings and lots of hits$/) do
  @site = create :site, :with_mappings_and_hits
end
