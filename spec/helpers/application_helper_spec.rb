require 'spec_helper'

describe ApplicationHelper do
  describe '#breadcrumb' do
    let(:mapping)       { create :mapping_with_default_host }
    let(:site)          { mapping.site }
    let(:organisation)  { site.organisation }
    let(:hit)           { build :hit, host: build(:host, site: site) }

    context 'at the top level' do
      subject { helper.breadcrumb }

      it { should include('<ul class="breadcrumb">') }
      it { should include('<li class="active">Organisations') }
    end

    context 'for an organisation' do
      subject { helper.breadcrumb organisation }

      it { should include('<ul class="breadcrumb">') }
      it { should include('<li><a href="/organisations">Organisations') }
      it { should include(%(<li class="active">#{organisation.title})) }
    end

    context 'for a site' do
      subject { helper.breadcrumb site }

      it { should include('<ul class="breadcrumb">') }
      it { should include('<li><a href="/organisations">Organisations') }
      it { should include("<li><a href=\"#{organisation_path(organisation)}\">#{organisation.title}") }
      it { should include(%(<li class="active">#{site.default_host.hostname} mappings)) }
    end

    context 'for a mapping' do
      subject { helper.breadcrumb mapping }

      it { should include('<ul class="breadcrumb">') }
      it { should include('<li><a href="/organisations">Organisations') }
      it { should include("<li><a href=\"#{organisation_path(organisation)}\">#{organisation.title}") }
      it { should include(%(<li><a href="#{site_mappings_path(site)}">#{site.default_host.hostname} mappings)) }
      it { should include('<li class="active">Mapping') }
    end

    context 'for a hit' do
      subject { helper.breadcrumb hit }

      it { should include('<ul class="breadcrumb">') }
      it { should include('<li><a href="/organisations">Organisations') }
      it { should include("<li><a href=\"#{organisation_path(organisation)}\">#{organisation.title}") }
      it { should include(%(<li class="active">#{site.default_host.hostname} analytics)) }
    end

    context 'for a new mapping' do
      subject { helper.breadcrumb(Mapping.new(site: site)) }

      it { should include('<li class="active">New mapping') }
    end

    context 'for the versions in a mapping', versioning: true do
      let(:mapping) { create :mapping_with_versions }
      let(:site)    { mapping.site }

      subject { helper.breadcrumb mapping.versions.last }

      it { should include('<ul class="breadcrumb">') }
      it { should include('<li><a href="/organisations">Organisations') }
      it { should include("<li><a href=\"#{organisation_path(organisation)}\">#{organisation.title}") }
      it { should include(%(<li><a href="#{site_mappings_path(site)}">#{site.default_host.hostname} mappings)) }
      it { should include(%(<li><a href="#{edit_site_mapping_path(site, mapping)}">Mapping)) }
      it { should include('<li class="active">History') }
    end
  end
end
