require 'spec_helper'

describe ApplicationHelper do
  let(:mapping)       { create :mapping }
  let(:site)          { mapping.site }
  let(:organisation)  { site.organisation }

  describe '#breadcrumb' do

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
      it { should include(%(<li class="active">#{site.abbr} Mappings)) }
    end

    context 'for a mapping' do
      subject { helper.breadcrumb mapping }

      it { should include('<ul class="breadcrumb">') }
      it { should include('<li><a href="/organisations">Organisations') }
      it { should include("<li><a href=\"#{organisation_path(organisation)}\">#{organisation.title}") }
      it { should include(%(<li><a href="#{site_mappings_path(site)}">#{site.abbr} Mappings)) }
      it { should include('<li class="active">Mapping') }
    end


  end
end
