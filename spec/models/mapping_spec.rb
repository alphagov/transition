require 'spec_helper'

describe Mapping do
  specify { PaperTrail.should_not be_enabled } # testing our tests a little here, but if this fails, tests will be slow

  describe 'relationships' do
    it { should belong_to(:site) }
  end

  describe '#redirect?' do
    its(:redirect?) { should be_false }
    it 'is true when http_status is 301' do
      subject.http_status = '301'
      subject.redirect?.should be_true
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:site) }
    it { should validate_presence_of(:path) }
    it { should ensure_length_of(:path).is_at_most(1024) }
    it { should validate_presence_of(:http_status) }
    it { should ensure_length_of(:http_status).is_at_most(3) }
    it 'ensures paths are unique to a site' do
      create(:mapping_410)
      lambda { build(:mapping_410).save }.should raise_error(ActiveRecord::StatementInvalid)
    end

    it { should ensure_length_of(:new_url).is_at_most(64.kilobytes - 1)}
    it { should ensure_length_of(:suggested_url).is_at_most(64.kilobytes - 1)}
    it { should ensure_length_of(:archive_url).is_at_most(64.kilobytes - 1)}

    describe 'URL validations' do
      subject(:mapping) { build(:mapping, http_status: '301', new_url: 'not-a-url', suggested_url: 'http://', archive_url: '') }

      before { mapping.should_not be_valid }

      describe 'the errors' do
        subject { mapping.errors }

        its([:new_url])       { should == ['is not a URL'] }
        its([:suggested_url]) { should == ['is not a URL'] }
        its([:archive_url])   { should be_empty }
      end
    end
  end

  describe 'the path hash' do
    let(:some_path) { '/a/b/c' }

    subject(:mapping) do
      build :mapping, path: some_path, site: build(:site), http_status: 301
    end

    before { mapping.save.should be_true }

    its(:path_hash) do
      should eql(Digest::SHA1.hexdigest(some_path))
    end
  end

  describe '.filtered_by_path' do
    before do
      site = create :site
      ['/', '/about', '/about/branding', '/other'].each do |path|
        create :mapping, path: path, site: site
      end
    end

    context 'a filter is supplied' do
      subject { Mapping.filtered_by_path('about').map(&:path) }

      it { should include('/about') }
      it { should include('/about/branding') }
      it { should_not include('/') }
      it { should_not include('/other') }
    end

    context 'no filter is supplied' do
      subject { Mapping.filtered_by_path(nil) }

      it { should have(4).mappings }
    end
  end

  describe 'The paper trail', versioning: true do
    let(:alice) { create :user }
    let(:bob)   { create :user }

    before            { PaperTrail.whodunnit = alice }
    subject(:mapping) { create :mapping }

    it { should have(1).versions }

    describe 'the last version' do
      subject { mapping.versions.last }

      its(:whodunnit) { should eql(alice.id.to_s) }
      its(:event)     { should eql('create') }
    end

    describe 'an update from Bob' do
      before do
        PaperTrail.whodunnit = bob
        mapping.update_attributes(new_url: 'http://updated.com')
      end

      it { should have(2).versions }

      describe 'the last version' do
        subject { mapping.versions.last }

        its(:whodunnit)  { should eql bob.id.to_s }
        its(:event)      { should eql 'update'}
      end
    end
  end
end
