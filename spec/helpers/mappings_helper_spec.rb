require 'spec_helper'

describe MappingsHelper do
  let(:site)    { build(:site) }
  let(:hostname){ site.default_host.hostname }
  let(:mapping) { build :mapping, site: site }

  describe '#created_mapping' do
    shared_examples 'it sanitises input' do
      it 'sanitises input' do
        helper.created_mapping(
          build(:archived, path: '<script>alert("abusive");</script>')
        ).should_not include('<script>')
      end
    end

    context 'mapping is an archive' do
      it 'indicates the path has been performed' do
        helper.created_mapping(build(:archived, path: '/foo')).should ==
          'Mapping created. <strong>/foo</strong> has been archived'
      end

      it_behaves_like 'it sanitises input'
    end

    context 'mapping is a redirect' do
      it 'links to the new url' do
        helper.created_mapping(build(:redirect, path: '/foo')).should ==
          'Mapping created. <strong>/foo</strong> redirects to <strong>' +
            '<a href="https://www.gov.uk/somewhere">https://www.gov.uk/somewhere</a></strong>'
      end
      it_behaves_like 'it sanitises input'
    end
  end

  describe '#mapping_edit_tabs', versioning: true do
    let!(:mapping) { create :mapping, :with_versions, site: site }
    before         { @mapping = mapping }

    subject { helper.mapping_edit_tabs active: 'Edit' }

    it { should include('<ul class="nav nav-tabs">') }
    it { should include('<li class="active"><a href="#"') }
    it { should include(%(<li><a href="#{site_mapping_versions_path(@mapping.site, @mapping)}")) }
  end

  describe '#options_for_supported_statuses' do
    it 'provides an array of supported statuses in a form compatible with FormBuilder#select' do
      helper.options_for_supported_statuses.should == [['Redirect', '301'], ['Archive', '410']]
    end
  end

  describe '#http_status_name' do
    context 'status is \'301\'' do
      subject { helper.http_status_name('301') }
      it { should eql('Redirect') }
    end

    context 'status is \'410\'' do
      subject { helper.http_status_name('410') }
      it { should eql('Archive') }
    end
  end
end
