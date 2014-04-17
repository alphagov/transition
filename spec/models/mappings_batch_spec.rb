require 'spec_helper'

describe MappingsBatch do
  describe 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:site) }
    it { should validate_presence_of(:paths) }
    it { should ensure_inclusion_of(:http_status).in_array(['301', '410']) }

    describe 'paths includes URLs for another site' do
      subject(:mappings_batch) { build(:mappings_batch, paths: ['http://another.com/foo']) }

      before { mappings_batch.should_not be_valid }
      it 'should declare them invalid' do
        mappings_batch.errors[:paths].should == ['One or more of the URLs entered are not part of this site']
      end
    end

    describe 'paths would be empty after canonicalisation' do
      subject(:mappings_batch) { build(:mappings_batch, paths: ['/']) }

      before { mappings_batch.should_not be_valid }
      it 'should declare them invalid' do
        mappings_batch.errors[:paths].should == ['Enter at least one valid path']
      end
    end

    describe 'new_url must be present if it is a redirect' do
      subject(:mappings_batch) { build(:mappings_batch, http_status: '301') }

      before { mappings_batch.should_not be_valid }
      it 'should declare it invalid' do
        mappings_batch.errors[:new_url].should == ['required when mapping is a redirect']
      end
    end

    describe 'constrains the length of new URL' do
      subject(:mappings_batch) { build(:mappings_batch, new_url: 'http://'.ljust(65536, 'x')) }

      before { mappings_batch.should_not be_valid }
      it 'should declare it invalid' do
        mappings_batch.errors[:new_url].should include('is too long (maximum is 65535 characters)')
      end
    end

    describe 'invalid new URLs' do
      subject(:mappings_batch) { build(:mappings_batch, new_url: 'newurl') }

      before { mappings_batch.should_not be_valid }
      it 'should declare it invalid' do
        mappings_batch.errors[:new_url].should == ['is not a URL']
      end
    end
  end

  describe 'filling in scheme of New URL' do
    subject(:mappings_batch) { build(:mappings_batch, new_url: 'www.gov.uk') }

    before { mappings_batch.should be_valid }
    it 'should add a scheme if none included' do
      mappings_batch.new_url.should == 'https://www.gov.uk'
    end
  end

  describe 'creating mappings' do
    let(:site) { create(:site, query_params: 'significant') }
    let!(:existing_mapping) { create(:mapping, site: site, path: '/a') }

    subject(:mappings_batch) { create(:mappings_batch, site: site,
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
  end
end
