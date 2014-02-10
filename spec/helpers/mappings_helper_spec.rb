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

  describe '#filter_by_tag_path' do
    subject { helper.filter_by_tag_path('tag') }
    let(:page){2}
    let(:tag_list){''}
    before do
      helper.stub(:params).and_return({page: page, tagged: tag_list})
    end

    context 'without any parameters' do
      before do
        helper.stub(:params).and_return({})
      end
      it { should eql({tagged: 'tag'}) }
    end

    context 'with a page parameter' do
      it { should eql({tagged: 'tag'}) }
    end

    context 'with existing tags' do
      let(:tag_list){'a,b'}
      it { should eql({tagged: 'a,b,tag'}) }
    end

    context 'with tag already present' do
      let(:tag_list){'a,tag'}
      it { should eql({tagged: 'tag'}) }
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

  describe '#existing_mappings_count' do
    let!(:exists_1) { create(:mapping, site: site, path: '/exists_1') }
    let!(:exists_2) { create(:mapping, site: site, path: '/exists_2') }

    context 'with no existing paths submitted' do
      before do
        paths_input = "/a"
        @bulk_add = View::Mappings::BulkAdder.new(site, { paths: paths_input, http_status: '410' }, '')
      end

      subject { helper.existing_mappings_count }
      it { should eql(0) }
    end

    context 'with two existing paths submitted' do
      before do
        paths_input = "/exists_1\n/exists_2\n/a\n/b"
        @bulk_add = View::Mappings::BulkAdder.new(site, { paths: paths_input, http_status: '410' }, '')
      end

      describe '#existing_mappings_count' do
        subject { helper.existing_mappings_count }
        it { should eql(2) }
      end
    end
  end
end
