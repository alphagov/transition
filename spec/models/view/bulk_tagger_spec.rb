require 'spec_helper'

describe View::Mappings::BulkTagger do
  let!(:site)     { create(:site) }
  let!(:mappings) { [
    create(:mapping, site: site, tag_list: 'fee, fum, fox'),
    create(:mapping, site: site, tag_list: 'fi, fum, fox'),
    create(:mapping, site: site, tag_list: 'fo, fum, fox')
  ] }
  let(:bulk_tagger) {
    View::Mappings::BulkTagger.new(
      site,
      {
        mapping_ids: mappings.map(&:id),
        tag_list:    'fiddle, fox'
      }
    )
  }

  describe '#common_tags' do
    it 'has common tags from the mappings' do
      bulk_tagger.common_tags.should =~ %w(fum fox)
    end
  end

  describe '#update!' do
    before { bulk_tagger.update! }

    it 'has seen no failures' do
      bulk_tagger.failures.should be_empty
    end
    it 'has updated mapping 1' do
      mappings.first.reload.tag_list.should =~ %w(fee fiddle fox)
    end
    it 'has updated mapping 2' do
      mappings.second.reload.tag_list.should =~ %w(fi fiddle fox)
    end
    it 'has updated mapping 3' do
      mappings.third.reload.tag_list.should =~ %w(fo fiddle fox)
    end
  end
end
