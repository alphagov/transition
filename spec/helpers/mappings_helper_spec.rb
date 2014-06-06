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

  describe '#options_for_supported_types' do
    it 'provides an array of supported types in a form compatible with FormBuilder#select' do
      helper.options_for_supported_types.should == [['Redirect', 'redirect'], ['Archive', 'archive'], ['Unresolved', 'unresolved']]
    end
  end

  describe '#operation_name' do
    context 'operation is \'redirect\'' do
      subject { helper.operation_name('redirect') }
      it { should eql('Redirect') }
    end

    context 'operation is \'archive\'' do
      subject { helper.operation_name('archive') }
      it { should eql('Archive') }
    end

    context 'operation is \'tag\'' do
      subject { helper.operation_name('tag') }
      it { should eql('Tag') }
    end
  end

  describe '#friendly_hit_count' do
    subject { helper.friendly_hit_count(hit_count) }

    context 'number is small' do
      let(:hit_count) { 999 }
      it { should eql('999') }
    end

    context 'number is nil' do
      let(:hit_count) { nil }
      it { should eql('0') }
    end

    context 'number is bigger' do
      let(:hit_count) { 1000 }
      it { should eql('1,000') }
    end
  end

  describe '#friendly_hit_percentage' do
    subject { helper.friendly_hit_percentage(hit_percentage) }

    context 'greater than 10%' do
      let(:hit_percentage) { 10.26 }
      it 'rounds to 1 decimal place' do
        should eql('10.3%')
      end
    end

    context 'between 0.01% and 10%' do
      let(:hit_percentage) { 1.125 }
      it 'rounds to 2 decimal places' do
        should eql('1.13%')
      end
    end

    context 'less than 0.01%' do
      let(:hit_percentage) { 0.009 }
      it 'shows a short version' do
        should eql('< 0.01%')
      end
    end

    context 'zero' do
      let(:hit_percentage) { 0.0 }
      it { should eql('') }
    end
  end
end
