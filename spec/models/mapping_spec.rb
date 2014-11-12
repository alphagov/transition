#encoding: utf-8

require 'spec_helper'
require 'transition/import/hits_mappings_relations'
require 'transition/history'

describe Mapping do
  specify { PaperTrail.should_not be_enabled } # testing our tests a little here, but if this fails, tests will be slow

  describe 'relationships' do
    it { should belong_to(:site) }
  end

  describe '#redirect?' do
    its(:redirect?) { should be_false }
    it 'is true when its type is redirect' do
      subject.type = 'redirect'
      subject.redirect?.should be_true
    end
  end

  describe '#archive?' do
    its(:archive?) { should be_false }
    it 'is true when its type is archive' do
      subject.type = 'archive'
      subject.archive?.should be_true
    end
  end

  describe '#unresolved?' do
    its(:unresolved?) { should be_false }
    it 'is true when its type is unresolved' do
      subject.type = 'unresolved'
      subject.unresolved?.should be_true
    end
  end

  describe 'url generation (based on mapping path and site host)' do
    subject(:mapping) { create :mapping, site: create(:site, abbr: 'cic_regulator'), path: '/some-path' }

    its(:old_url)                    { should == 'http://cic_regulator.gov.uk/some-path' }
    its(:national_archive_url)       { should == 'http://webarchive.nationalarchives.gov.uk/20120816224015/http://cic_regulator.gov.uk/some-path' }
    its(:national_archive_index_url) { should == 'http://webarchive.nationalarchives.gov.uk/*/http://cic_regulator.gov.uk/some-path' }
  end

  describe 'validations' do
    it { should validate_presence_of(:site) }
    it { should validate_presence_of(:path) }

    it { should validate_presence_of(:type) }
    it { should ensure_inclusion_of(:type).in_array(Mapping::SUPPORTED_TYPES) }

    describe 'home pages (which are handled by Site)' do
      subject(:homepage_mapping) { build(:mapping, path: '/') }

      before { homepage_mapping.should_not be_valid }
      it 'disallows homepages' do
        homepage_mapping.errors[:path].should ==
          ["It’s not currently possible to edit the mapping for a site’s homepage."]
      end
    end

    it { should ensure_length_of(:path).is_at_most(2048) }
    it 'ensures paths are unique to a site' do
      site = create(:site)
      create(:archived, path: '/foo', site: site)
      lambda { build(:archived, path: '/foo', site: site).save! }.should raise_error(ActiveRecord::RecordInvalid)
    end

    it 'constrains the length of all URL fields' do
      too_long_url = 'http://'.ljust(2049, 'x')

      [:new_url, :suggested_url, :archive_url].each do |url_attr|
        mapping = build(:mapping, url_attr => too_long_url)
        mapping.should_not be_valid
        mapping.errors[url_attr].should include('is too long (maximum is 2048 characters)')
      end
    end

    describe 'URL validations' do
      before { mapping.valid? }

      context 'oh golly, everything is wrong' do
        subject(:mapping) do
          build(:redirect, new_url: 'https://', suggested_url: 'http://', archive_url: '')
        end

        describe 'the errors' do
          subject { mapping.errors }

          its([:new_url])       { should include('is not a URL') }
          its([:suggested_url]) { should == ['is not a URL'] }
          its([:archive_url])   { should be_empty }

          context 'failure to supply a new URL for a redirect' do
            before do
              mapping.new_url = ''
              mapping.should_not be_valid
            end

            its([:new_url]) { should == ['is required'] }
          end
        end
      end

      context 'URLs with an invalid host (without a ".")' do
        subject(:mapping) do
          build(:redirect, new_url: 'newurl', suggested_url: 'suggestedurl')
        end

        describe 'the errors' do
          subject { mapping.errors }
          its([:new_url])       { should include('is not a URL') }
          its([:suggested_url]) { should == ['is not a URL'] }
        end
      end

      context 'Archive URL is not webarchive.nationalarchives.gov.uk' do
        subject(:mapping) { build(:archived, archive_url: 'http://malicious.com/foo')}

        it 'fails' do
          mapping.errors[:archive_url].should == ['must be on the National Archives domain, webarchive.nationalarchives.gov.uk']
        end
      end

      describe 'New URL whitelist checks' do
        context 'not in the whitelist' do
          subject(:mapping) { build(:redirect, new_url: 'http://m.com/foo') }

          it 'fails' do
            mapping.errors[:new_url].should == ['must be on a whitelisted domain. Contact transition-dev@digital.cabinet-office.gov.uk for more information.']
          end
        end

        context 'is in the whitelist' do
          before { create(:whitelisted_host, hostname: 'whitelisted.com') }
          subject(:mapping) { build(:redirect, new_url: 'http://whitelisted.com/a') }

          it { should be_valid }
        end

        context 'is on *.gov.uk' do
          subject(:mapping) { build(:redirect, new_url: 'http://m.gov.uk/foo') }

          it { should be_valid }
        end

        context 'is on *.mod.uk' do
          subject(:mapping) { build(:redirect, new_url: 'http://m.mod.uk/foo') }

          it { should be_valid }
        end

        context 'mapping is not a redirect' do
          subject(:mapping) { build(:archived, new_url: 'http://evil.com') }

          it { should be_valid }
          it 'still saves the value that would be invalid if it was a redirect' do
            mapping.save
            mapping.reload.new_url.should == 'http://evil.com'
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
    end

    describe 'tagging behaviour for quoting and special characters' do
      let(:mapping)      { create :mapping }

      subject(:tag_list) { mapping.tag_list }

      before { mapping.tag_list = test_input }

      # We don't like this behaviour (it keeps quotes in tags with no spaces),
      # but changing it means forking. And we can live with it.
      context 'there are double-quoted tags' do
        let(:test_input) { %("Fee fi", "FO", fum, thing:1234) }
        it { should eql(['fee fi', '"fo"', 'fum', 'thing:1234']) }
      end
      context 'there are single-quoted tags' do
        let(:test_input) { %('Fee fi', 'FO', fum, thing:1234) }
        it { should eql(['fee fi', "'fo'", 'fum', 'thing:1234']) }
      end
      context 'there are special characters' do
        let(:test_input) { %('<Fee fi>', '\\FO/', ¿fum?) }
        it { should eql(['<fee fi>', "'\\fo/'", '¿fum?']) }
      end
      context 'there are blanks' do
        let(:test_input) { %(,     ,    hello, hi    , ho) }
        it { should eql(%w(hello hi ho)) }
      end
      context 'there are only blanks' do
        let(:test_input) { %(,     ,       , ,   ) }
        it { should eql([]) }
      end
    end
  end

  describe 'scopes' do
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

    describe '.filtered_by_new_url' do
      before do
        site = create :site
        ['/a', '/about', '/about/branding', '/other'].each do |new_path|
          create :mapping, new_url: "http://f.gov.uk#{new_path}", site: site
        end
      end

      context 'a filter is supplied' do
        subject { Mapping.filtered_by_new_url('about').map(&:new_url) }

        it { should include('http://f.gov.uk/about') }
        it { should include('http://f.gov.uk/about/branding') }
        it { should_not include('http://f.gov.uk/a') }
        it { should_not include('http://f.gov.uk/other') }
      end

      context 'no filter is supplied' do
        subject { Mapping.filtered_by_path(nil) }

        it { should have(4).mappings }
      end
    end
  end

  describe 'path canonicalization and relation to hits', truncate_everything: true do
    let(:uncanonicalized_path) { '/A/b/c?significant=1&really-significant=2&insignificant=2' }
    let(:canonicalized_path)   { '/a/b/c?really-significant=2&significant=1' }
    let(:site)                 { create(:site, query_params: 'significant:really-significant')}

    subject(:mapping) do
      create(:archived, path: uncanonicalized_path, site: site)
    end

    its(:path)        { should eql(canonicalized_path) }
    its(:path_hash)   { should eql(Digest::SHA1.hexdigest(canonicalized_path)) }

    describe 'the linkage to hits' do
      let!(:hit_on_uncanonicalized) { create :hit, path: uncanonicalized_path, host: site.default_host }
      let!(:host_path_on_uncanonicalized) { create :host_path, path: uncanonicalized_path, host: site.default_host }

      let!(:hit_on_canonicalized)   { create :hit, path: canonicalized_path, host: site.default_host }
      let!(:host_path_on_canonicalized) { create :host_path, path: canonicalized_path, host: site.default_host }

      let!(:unrelated_hit) { create :hit, path: '/just-zis-guy', host: site.default_host }
      let!(:unrelated_host_path) { create :host_path, path: '/just-zis-guy', host: site.default_host }

      context 'when creating a new mapping', need_mapping_callbacks: true do
        before do
          Transition::Import::HitsMappingsRelations.refresh!
          mapping.save!
        end

        it 'links the uncanonicalized hit to the mapping' do
          hit_on_uncanonicalized.reload.mapping.should == mapping
        end

        it 'links the canonicalized hit to the mapping' do
          hit_on_canonicalized.reload.mapping.should == mapping
        end

        it 'links the uncanonicalized host_path to the mapping' do
          host_path_on_uncanonicalized.reload.mapping.should == mapping

        end

        it 'link the canonicalized host_path to the mapping' do
          host_path_on_canonicalized.reload.mapping.should == mapping
        end

        it 'updates the hit_count' do
          mapping.hit_count.should == 40
        end

        it 'should leave an unrelated hit alone' do
          unrelated_hit.reload.mapping.should be_nil
        end

        it 'should leave an unrelated host_path alone' do
          unrelated_host_path.reload.mapping.should be_nil
        end
      end
    end
  end

  describe 'nillifying blanks before validation' do
    subject(:mapping) do
      create :archived, archive_url: ''
    end

    its(:archive_url) { should be_nil }
  end

  it 'should rewrite the URLs to ensure they have a scheme before validation' do
    mapping = build(:archived, suggested_url: 'www.example.com',
                                                  archive_url: 'webarchive.nationalarchives.gov.uk',
                                                  new_url: 'www.gov.uk')

    mapping.valid? # trigger before_validation hooks

    mapping.suggested_url.should eql('http://www.example.com')
    mapping.archive_url.should eql('http://webarchive.nationalarchives.gov.uk')
    mapping.new_url.should eql('https://www.gov.uk')
  end

  it 'converts URLs supplied for path into a path, including query' do
    site = create(:site, query_params: 'q')
    mapping = create(:mapping, path: 'http://www.example.com/foobar?q=1', site: site)
    mapping.path.should == '/foobar?q=1'
  end

  describe 'The paper trail', versioning: true do
    let(:alice) { create :user, name: 'Alice' }
    let(:bob)   { create :user, name: 'Bob' }

    context 'with the correct configuration' do
      subject(:mapping) { create :mapping, as_user: alice }

      it { should have(1).versions }

      describe 'the last version' do
        subject { mapping.versions.last }

        its(:whodunnit) { should eql alice.name }
        its(:user_id)   { should eql alice.id }
        its(:event)     { should eql 'create' }
      end

      describe 'an update from Bob' do
        before do
          Transition::History.as_a_user(bob) do
            mapping.update_attributes(new_url: 'http://updated.gov.uk')
          end
        end

        it { should have(2).versions }

        describe 'the last version' do
          subject { mapping.versions.last }

          its(:whodunnit)  { should eql bob.name }
          its(:user_id)    { should eql bob.id }
          its(:event)      { should eql 'update'}
        end
      end
    end

    context 'without the correct configuration' do
      it 'should fail with an exception' do
        expect { create :mapping, as_user: nil }.to raise_error(Transition::History::PaperTrailUserNotSetError)
      end
    end
  end

  describe 'edited_by_human' do
    context 'imported from redirector' do
      subject(:mapping) { create(:mapping, from_redirector: true) }

      its(:edited_by_human?) { should be_true }
    end

    context 'has been edited by a human', versioning: true do
      let(:human) { create :user }

      subject(:mapping) { create(:mapping, as_user: human) }

      its(:edited_by_human?) { should be_true }
    end

    context 'has been edited by a robot', versioning: true do
      let(:robot) { create :user, is_robot: true }

      subject(:mapping) { create(:mapping, as_user: robot) }

      its(:edited_by_human?) { should be_false }
    end
  end

  describe 'last_editor' do
    context 'no versions exist' do
      subject(:mapping) { create(:mapping, from_redirector: true) }

      its(:last_editor) { should be_nil }
    end

    context 'versions exist', versioning: true do
      let(:user) { create :user }
      subject(:mapping) { create(:mapping, as_user: user) }

      context 'only one version exists' do
        its(:last_editor) { should eql(user) }
      end

      context 'several versions exist' do
        let(:other_user) { create :user }
        before do
          Transition::History.as_a_user(other_user) do
            mapping.update_attributes(type: 'redirect', new_url: 'http://updated.gov.uk')
            mapping.update_attributes(type: 'redirect', new_url: 'http://new.gov.uk')
          end
        end

        it { should have(3).versions }

        its(:last_editor) { should eql(other_user) }
      end
    end
  end
end
