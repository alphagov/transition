Given(/^a mapping exists for the site ukba$/) do
  @site = create :site, abbr: 'ukba'
  @mapping = create(:mapping)
  @site.mappings = [@mapping]
end

Given(/^a site "ukba" exists with these tagged mappings:$/) do |tagged_paths|
  @site = create :site, abbr: 'ukba'

  # tagged_paths.hashes.keys # => [:path, :tags]
  tagged_paths.hashes.each do |row|
    @site.mappings << create(:archived, path: row[:path]).tap do |mapping|
      mapping.tag_list = row[:tags]
    end
  end
end
