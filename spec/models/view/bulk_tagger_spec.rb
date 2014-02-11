require 'spec_helper'

describe View::Mappings::BulkTagger do
  let!(:site)     { create(:site) }
  let!(:mappings) { [
    create(:mapping, site: site, tag_list: 'fee, fum, fox'),
    create(:mapping, site: site, tag_list: 'fi, fum, fox'),
    create(:mapping, site: site, tag_list: 'fo, fum, fox')
  ] }
  let(:tag_list) { 'fox, fiddle' }
  let(:bulk_tagger) {
    View::Mappings::BulkTagger.new(
      site,
      {
        mapping_ids: mappings.map(&:id),
        tag_list:    tag_list
      }
    )
  }

  it 'has common tags from the mappings' do
    bulk_tagger.common_tags.should =~ %w(fum fox)
  end

  describe '#tag_list' do
    subject { bulk_tagger.tag_list }

    context 'when the tag list is compact' do
      let(:tag_list) { 'fox,fiddle' }
      it { should eql('fox, fiddle') }
    end
    context 'when the tag list is expanded' do
      let(:tag_list) { 'fox,    fiddle' }
      it { should eql('fox, fiddle') }
    end
    context 'when the tag list is not supplied' do
      let(:tag_list) { nil }
      it { should eql(bulk_tagger.common_tags.join(', ')) }
    end
  end

  describe '#update!' do
    before { bulk_tagger.update! }

    context 'we remove common tag "fum" and add "fiddle"' do
      let(:tag_list) { 'fox, fiddle' }

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

    context 'we remove all the common tags' do
      let(:tag_list) { '' }

      it 'has seen no failures' do
        bulk_tagger.failures.should be_empty
      end
      it 'has updated mapping 1' do
        mappings.first.reload.tag_list.should =~ %w(fee)
      end
      it 'has updated mapping 2' do
        mappings.second.reload.tag_list.should =~ %w(fi)
      end
      it 'has updated mapping 3' do
        mappings.third.reload.tag_list.should =~ %w(fo)
      end
    end
  end
end
