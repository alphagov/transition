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

  describe 'url generation (based on mapping path and site host)' do
    subject(:mapping) { create :mapping, site: create(:site_with_default_host, abbr: 'cic_regulator'), path: '/some-path' }

    its(:old_url)                    { should == 'http://cic_regulator.gov.uk/some-path' }
    its(:national_archive_url)       { should == 'http://webarchive.nationalarchives.gov.uk/20120816224015/http://cic_regulator.gov.uk/some-path' }
    its(:national_archive_index_url) { should == 'http://webarchive.nationalarchives.gov.uk/*/http://cic_regulator.gov.uk/some-path' }
  end

  describe 'validations' do
    it { should validate_presence_of(:site) }
    it { should validate_presence_of(:path) }

    describe 'home pages (which are handled by Site)' do
      subject(:homepage_mapping) { build(:mapping, path: '/') }

      before { homepage_mapping.should_not be_valid }
      it 'disallows homepages' do
        homepage_mapping.errors[:path].should ==
          ["It's not currently possible to edit the mapping for a site's homepage."]
      end
    end

    it { should ensure_length_of(:path).is_at_most(1024) }
    it { should validate_presence_of(:http_status) }
    it { should ensure_length_of(:http_status).is_at_most(3) }
    it 'ensures paths are unique to a site' do
      site = create(:site)
      create(:mapping_410, site: site)
      lambda { build(:mapping_410, site: site).save! }.should raise_error(ActiveRecord::RecordInvalid)
    end

    it { should ensure_length_of(:new_url).is_at_most(64.kilobytes - 1)}
    it { should ensure_length_of(:suggested_url).is_at_most(64.kilobytes - 1)}
    it { should ensure_length_of(:archive_url).is_at_most(64.kilobytes - 1)}

    describe 'URL validations' do
      before { mapping.should_not be_valid }

      context 'oh golly, everything is wrong' do
        subject(:mapping) do
          build(:mapping, http_status: '301', new_url: 'not-a-url', suggested_url: 'http://', archive_url: '')
        end

        describe 'the errors' do
          subject { mapping.errors }

          its([:new_url])       { should == ['is not a URL'] }
          its([:suggested_url]) { should == ['is not a URL'] }
          its([:archive_url])   { should be_empty }

          context 'failure to supply a new URL for a 301' do
            before do
              mapping.new_url = ''
              mapping.should_not be_valid
            end

            its([:new_url]) { should == ['required when mapping is a redirect'] }
          end
        end
      end

      context 'path is blank' do
        subject(:mapping) { build(:archived, path: '') }

        it 'fails' do
          mapping.errors[:path].should == ["can't be blank"]
        end
      end

      context 'path does not start with a /' do
        subject(:mapping) { build(:archived, path: 'not_a_path') }

        it 'fails' do
          mapping.errors[:path].should == ['must start with a forward slash "/"']
        end
      end

      context 'paths are abusive' do
        subject(:mapping) { build(:archived, path: '/<script>alert("eating your first-born")</script>') }

        it 'fails' do
          mapping.errors[:path].should == ['contains invalid or unsafe characters (e.g. "<")']
        end
      end
    end
  end

  describe 'values normalised or changed on save' do
    let(:uncanonicalized_path) { '/A/b/c?significant=1&really-significant=2&insignificant=2' }
    let(:canonicalized_path)   { '/a/b/c?really-significant=2&significant=1' }
    let(:site)                 { build(:site, query_params: 'significant:really-significant')}

    subject(:mapping) do
      build :mapping, path: uncanonicalized_path, site: site, http_status: '410', archive_url: ''
    end

    before { mapping.save! }

    its(:path)        { should eql(canonicalized_path) }
    its(:path_hash)   { should eql(Digest::SHA1.hexdigest(canonicalized_path)) }
    its(:archive_url) { should be_nil }
  end

  describe '.filtered_by_path' do
    before do
      site = create :site
      ['/a', '/about', '/about/branding', '/other'].each do |path|
        create :mapping, path: path, site: site
      end
    end

    context 'a filter is supplied' do
      subject { Mapping.filtered_by_path('about').map(&:path) }

      it { should include('/about') }
      it { should include('/about/branding') }
      it { should_not include('/a') }
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
