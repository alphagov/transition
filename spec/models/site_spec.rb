require 'spec_helper'

describe Site do
  describe 'relationships' do
    it { should belong_to(:organisation) }
    it { should have_many(:hosts) }
    it { should have_many(:mappings) }
  end

  describe 'validations' do
    it { should validate_presence_of(:abbr) }
  end

  describe '.with_mapping_count scope' do
    let!(:site_with_mappings)    { create :site }
    let!(:site_without_mappings) { create :site }
    let!(:mappings) { [create(:mapping, site: site_with_mappings),
                      create(:mapping, site: site_with_mappings)] }

    subject(:site_list) { Site.with_mapping_count }

    it 'has counts available on #mapping_count' do
      site = site_list.find { |s| s.id == site_with_mappings.id }
      site.mapping_count.should == 2
    end

    it 'correctly counts 0 for sites without mappings' do
      site = site_list.find { |s| s.id == site_without_mappings.id }
      site.mapping_count.should == 0
    end
  end

  describe '#transition_status' do
    let!(:site) { create :site }

    subject(:transition_status) { site.transition_status }

    context 'site has any host redirected by GDS' do
      before do
        site.default_host.tap do |host|
          host.cname = 'redirector-cdn.production.govuk.service.gov.uk'
          host.save
        end
      end
      it { should eql('live') }
    end

    context 'site is under supplier redirect' do
      before { site.special_redirect_strategy = 'supplier' }
      it     { should eql('indeterminate') }
    end

    context 'site is under aka redirect' do
      before { site.special_redirect_strategy = 'via_aka' }
      it     { should eql('indeterminate') }
    end

    context 'in any other case' do
      it { should eql('pre-transition') }
    end
  end

  # given that hosts are site aliases
  describe '#default_host' do
    let(:hosts) { [create(:host), create(:host)] }
    subject(:site) do
      create(:site) do |site|
        site.hosts = hosts
      end
    end

    its(:default_host) { should eql(hosts.first) }
  end

  describe '#canonical_path' do
    let(:site) do
      create(:site, query_params: "foo:bar")
    end
    subject(:canonicalized_path) { site.canonical_path(@raw_path) }

    it "should be a canonicalized path" do
      @raw_path = '/ABOUT/FUN///#noreally'
      subject.should eql('/about/fun')
    end

    it "should retain the site's significant query params" do
      @raw_path = '/ABOUT?foo=BAZ&bar=beer'
      subject.should eql('/about?bar=beer&foo=baz')
    end

    it "should not retain other query params" do
      @raw_path = '/ABOUT?foo=BAZ&rain=shine'
      subject.should eql('/about?foo=baz')
    end

    it "should handle an empty path gracefully" do
      @raw_path = '/'
      subject.should eql('')
    end
  end
end
