require 'spec_helper'

describe BulkAddBatch do
  describe 'callbacks' do
    # In this test, we need to implicitly call #valid? using { be_valid } so
    # that the before_validation callbacks are called so that we can test that
    # they do the right thing.
    describe 'filling in scheme of New URL' do
      subject(:mappings_batch) { build(:bulk_add_batch, new_url: 'www.gov.uk') }

      before { mappings_batch.should be_valid }
      it 'should add a scheme if none included' do
        mappings_batch.new_url.should == 'https://www.gov.uk'
      end
    end
  end

  describe 'validations' do
    it { should ensure_inclusion_of(:type).in_array(Mapping::SUPPORTED_TYPES) }

    describe 'paths would be empty after canonicalisation' do
      subject(:mappings_batch) { build(:bulk_add_batch, paths: ['/']) }

      before { mappings_batch.should_not be_valid }
      it 'should declare it invalid' do
        mappings_batch.errors[:canonical_paths].should == ['Enter at least one valid path or full URL']
      end
    end

    describe 'new_url must be present if it is a redirect' do
      subject(:mappings_batch) { build(:bulk_add_batch, type: 'redirect') }

      before { mappings_batch.should_not be_valid }
      it 'should declare it invalid' do
        mappings_batch.errors[:new_url].should == ['Enter a valid URL to redirect to']
      end
    end

    describe 'constrains the length of new URL' do
      subject(:mappings_batch) { build(:bulk_add_batch, type: 'redirect', new_url: 'http://'.ljust(65536, 'x')) }

      before { mappings_batch.should_not be_valid }
      it 'should declare it invalid' do
        mappings_batch.errors[:new_url].should include('is too long (maximum is 65535 characters)')
      end
    end

    describe 'invalid new URLs' do
      subject(:mappings_batch) { build(:bulk_add_batch, type: 'redirect', new_url: 'newurl') }

      before { mappings_batch.should_not be_valid }
      it 'should declare it invalid' do
        mappings_batch.errors[:new_url].should include('Enter a valid URL to redirect to')
      end
    end

    describe 'non-whitelisted new URLs' do
      subject(:mappings_batch) { build(:bulk_add_batch, type: 'redirect', new_url: 'http://bad.com') }

      before { mappings_batch.should_not be_valid }
      it 'should declare it invalid' do
        mappings_batch.errors[:new_url].should include('The URL to redirect to must be on a whitelisted domain. Contact transition-dev@digital.cabinet-office.gov.uk for more information.')
      end
    end

    describe 'paths includes URLs for another site' do
      subject(:mappings_batch) { build(:bulk_add_batch, paths: ['http://another.com/foo']) }

      before { mappings_batch.should_not be_valid }
      it 'should declare them invalid' do
        mappings_batch.errors[:paths].should == ['One or more of the URLs entered are not part of this site']
      end
    end

    describe 'paths includes URLs for this site' do
      let(:site) { create(:site_without_host, hosts: [create(:host, hostname: 'a.com')]) }

      subject(:mappings_batch) do
        build(:bulk_add_batch, site: site, paths: ['http://a.com/a', 'http://a.com/a'])
      end

      it { should be_valid }
    end

    describe 'invalid paths with a scheme' do
      subject(:mappings_batch) { build(:bulk_add_batch, type: 'archive', paths: ['http://newurl/foo[1]']) }

      before { mappings_batch.should_not be_valid }
      it 'should not raise an error' do
        expect { mappings_batch.valid? }.not_to raise_error
      end
    end
  end

  describe 'creating entries' do
    let(:site) { create(:site, query_params: 'significant') }
    let!(:existing_mapping) { create(:mapping, site: site, path: '/a') }

    subject(:mappings_batch) { create(:bulk_add_batch, site: site,
                                      paths: ['/a?insignificant', '/a', '/b?significant']) }

    it 'should create an entry for each canonicalised path' do
      mappings_batch.entries.count.should == 2
      entry_paths = mappings_batch.entries.map(&:path)
      entry_paths.sort.should == ['/a', '/b?significant'].sort
    end

    it 'should relate the entry to the existing mapping' do
      entry = mappings_batch.entries.detect { |entry| entry.path == existing_mapping.path }
      entry.should_not be_nil
      entry.mapping.should == existing_mapping
    end

    it 'should create entries of the right subclass' do
      entry = mappings_batch.entries.first
      entry.should be_a(BulkAddBatchEntry)
    end
  end

  describe '#process' do
    let(:site) { create(:site) }

    subject(:mappings_batch) do
      create(:bulk_add_batch, site: site,
              paths: ['/a', '/b'],
              type: 'redirect', new_url: 'http://a.gov.uk', tag_list: ['a tag'])
    end

    include_examples 'creates mappings'
  end

  describe 'recording history', versioning: true do
    let(:site) { create(:site) }
    let(:mappings_batch) do
      create(:bulk_add_batch, site: site,
              paths: ['/a'],
              type: 'redirect', new_url: 'http://a.gov.uk', tag_list: '')
    end

    it 'should not record any change to the tag_list' do
      Transition::History.as_a_user(create(:user)) do
        mappings_batch.process
      end

      site.mappings.count.should == 1

      mapping = site.mappings.first

      version = mapping.versions.first
      version.changeset.should_not include('tag_list')
    end
  end
end
