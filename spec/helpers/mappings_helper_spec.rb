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
end
