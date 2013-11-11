require 'spec_helper'

describe Site do
  describe 'relationships' do
    it { should belong_to(:organisation) }
    it { should have_many(:hosts) }
    it { should have_many(:mappings) }
  end

  describe 'validations' do
    it { should validate_presence_of(:abbr) }
    it { should validate_uniqueness_of(:abbr) }
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

  describe '#canonicalize_path' do
    let(:site) do
      create(:site, query_params: "foo:bar")
    end
    subject(:canonicalized_path) { site.canonicalize_path @raw_path }

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
