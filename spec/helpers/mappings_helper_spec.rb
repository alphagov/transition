require 'spec_helper'

describe MappingsHelper do
  let(:site)    { build(:site) }
  let(:hostname){ site.default_host.hostname }
  let(:mapping) { build :mapping, site: site }

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

  describe '#operation_name' do
    context 'operation is \'301\'' do
      subject { helper.operation_name('301') }
      it { should eql('Redirect') }
    end

    context 'operation is \'410\'' do
      subject { helper.operation_name('410') }
      it { should eql('Archive') }
    end

    context 'operation is \'tag\'' do
      subject { helper.operation_name('tag') }
      it { should eql('Tag') }
    end
  end
end
