require 'spec_helper'

describe MappingsHelper do
  let(:site)    { build(:site_with_default_host) }
  let(:hostname){ site.default_host.hostname }
  let(:mapping) { build :mapping, site: site }

  describe '#example_url' do
    context 'no host' do
      subject { helper.example_url(mapping) }

      it { should include %(<a href="http://#{hostname}) }
      it { should include '>/about/branding</a>'}
    end

    context 'include a host' do
      subject { helper.example_url(mapping, include_host: true) }

      it { should include '<a href="http://' }
      it { should include ">http://#{hostname}/about/branding</a>"}
    end
  end

  describe '#mapping_edit_tabs', versioning: true do
    let!(:mapping) { create :mapping_with_versions, site: site }
    before         { @mapping = mapping }

    subject { helper.mapping_edit_tabs active: 'Edit' }

    it { should include('<ul class="nav nav-tabs">') }
    it { should include('<li class="active"><a href="#"') }
    it { should include(%(<li><a href="#{site_mapping_versions_path(@mapping.site, @mapping)}")) }
  end

  describe '#options_for_supported_statuses' do
    it 'provides an array of supported statuses in a form compatible with FormBuilder#select' do
      helper.options_for_supported_statuses.should == [['301 Moved Permanently', '301'], ['410 Gone', '410']]
    end
  end
end
